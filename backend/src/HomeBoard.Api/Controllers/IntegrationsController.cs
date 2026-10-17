using System.Security.Cryptography;
using System.Text;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace HomeBoard.Api.Controllers;

/// <summary>
/// Data for other home services, such as a personal assistant. Protected by shared API keys sent
/// in the X-Api-Key header instead of a user login:
/// - Integrations:ApiKey reads chores and points;
/// - Integrations:WriteApiKey approves or rejects done chores and gives bonus points, recorded
///   under the admin named by Integrations:ActAsUser (or else the first admin).
/// Endpoints answer 404 while their key is not configured.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[AllowAnonymous]
public class IntegrationsController : ControllerBase
{
    public const string ApiKeyHeader = "X-Api-Key";

    private readonly ITaskService _taskService;
    private readonly IIntegrationService _integrationService;
    private readonly string? _apiKey;
    private readonly string? _writeApiKey;
    private readonly string? _actAsUser;

    public IntegrationsController(ITaskService taskService, IIntegrationService integrationService, IConfiguration configuration)
    {
        _taskService = taskService;
        _integrationService = integrationService;
        _apiKey = configuration["Integrations:ApiKey"];
        _writeApiKey = configuration["Integrations:WriteApiKey"];
        _actAsUser = configuration["Integrations:ActAsUser"];
    }

    /// <summary>
    /// Chores of all family members per day, with their status. Default range: today.
    /// </summary>
    [HttpGet("chores")]
    public async Task<ActionResult<ChoresResponse>> GetChores(
        [FromQuery] DateOnly? startDate,
        [FromQuery] DateOnly? endDate)
    {
        if (string.IsNullOrEmpty(_apiKey))
        {
            return NotFound();
        }
        if (!HasValidApiKey(_apiKey))
        {
            return Unauthorized();
        }

        try
        {
            return Ok(await _taskService.GetChoresAsync(startDate, endDate));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Each child's points (scoreboard, next payout, this week and month) and the done chores still
    /// waiting for a parent's approval.
    /// </summary>
    [HttpGet("points")]
    public async Task<ActionResult<PointsResponse>> GetPoints()
    {
        if (string.IsNullOrEmpty(_apiKey))
        {
            return NotFound();
        }
        if (!HasValidApiKey(_apiKey))
        {
            return Unauthorized();
        }

        return Ok(await _integrationService.GetPointsAsync());
    }

    /// <summary>
    /// Approves a done chore, as a parent would in the verification queue: the person who did it
    /// gets the chore's points, or `pointsAwarded` when given.
    /// </summary>
    [HttpPost("completions/{completionId}/approve")]
    public async Task<ActionResult<ReviewResponse>> ApproveChore(
        Guid completionId,
        [FromBody(EmptyBodyBehavior = EmptyBodyBehavior.Allow)] VerifyTaskRequest? request)
    {
        var (adminId, refused) = await AuthorizeWriteAsync();
        if (refused != null)
        {
            return refused;
        }
        if (request?.PointsAwarded < 0)
        {
            return BadRequest(new { message = "pointsAwarded can't be negative" });
        }

        return Reviewed(await _integrationService.ApproveChoreAsync(completionId, request?.PointsAwarded, adminId), "Chore approved");
    }

    /// <summary>
    /// Rejects a done chore that wasn't really done: no points.
    /// </summary>
    [HttpPost("completions/{completionId}/reject")]
    public async Task<ActionResult<ReviewResponse>> RejectChore(
        Guid completionId,
        [FromBody(EmptyBodyBehavior = EmptyBodyBehavior.Allow)] RejectTaskRequest? request)
    {
        var (adminId, refused) = await AuthorizeWriteAsync();
        if (refused != null)
        {
            return refused;
        }

        return Reviewed(await _integrationService.RejectChoreAsync(completionId, request?.Reason, adminId), "Chore rejected");
    }

    /// <summary>
    /// Gives a child bonus points, e.g. for helping out without being asked.
    /// </summary>
    [HttpPost("users/{userId}/bonus-points")]
    public async Task<ActionResult<BonusResponse>> AwardBonusPoints(Guid userId, [FromBody] BonusPointsRequest request)
    {
        var (adminId, refused) = await AuthorizeWriteAsync();
        if (refused != null)
        {
            return refused;
        }
        if (request.Points <= 0)
        {
            return BadRequest(new { message = "Points must be greater than zero" });
        }

        var name = await _integrationService.AwardBonusPointsAsync(userId, request.Points, request.Description, adminId);
        if (name == null)
        {
            return NotFound(new { message = "No active child with this id" });
        }
        return Ok(new BonusResponse { Message = "Bonus points awarded", Name = name, PointsAwarded = request.Points });
    }

    /// <summary>
    /// For the endpoints that change data: the write key must match, and there must be an admin
    /// to record the change under.
    /// </summary>
    private async Task<(Guid AdminId, ActionResult? Refused)> AuthorizeWriteAsync()
    {
        if (string.IsNullOrEmpty(_writeApiKey))
        {
            return (default, NotFound());
        }
        if (!HasValidApiKey(_writeApiKey))
        {
            return (default, Unauthorized());
        }

        var adminId = await _integrationService.FindActingAdminAsync(_actAsUser);
        if (adminId == null)
        {
            var message = string.IsNullOrEmpty(_actAsUser)
                ? "There is no active admin to record the change under"
                : $"Integrations:ActAsUser '{_actAsUser}' is not an active admin";
            return (default, StatusCode(StatusCodes.Status500InternalServerError, new { message }));
        }
        return (adminId.Value, null);
    }

    private ActionResult<ReviewResponse> Reviewed(ReviewResult result, string message) => result.Outcome switch
    {
        ReviewOutcome.NotFound => NotFound(new { message = "No done chore with this completion id" }),
        ReviewOutcome.AlreadyReviewed => Conflict(new { message = $"'{result.Title}' by {result.CompletedBy} was already approved or rejected" }),
        ReviewOutcome.AlreadyAwarded => Conflict(new { message = $"Points were already given for '{result.Title}' by {result.CompletedBy}" }),
        _ => Ok(new ReviewResponse
        {
            Message = message,
            Title = result.Title!,
            CompletedBy = result.CompletedBy,
            PointsAwarded = result.PointsAwarded
        })
    };

    private bool HasValidApiKey(string expectedKey)
    {
        var given = Encoding.UTF8.GetBytes(Request.Headers[ApiKeyHeader].ToString());
        var expected = Encoding.UTF8.GetBytes(expectedKey);
        return CryptographicOperations.FixedTimeEquals(given, expected);
    }
}
