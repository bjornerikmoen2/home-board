using System.Security.Claims;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class VerificationController : ControllerBase
{
    private readonly HomeBoardDbContext _context;
    private readonly IVerificationService _verificationService;

    public VerificationController(HomeBoardDbContext context, IVerificationService verificationService)
    {
        _context = context;
        _verificationService = verificationService;
    }

    [HttpGet("pending")]
    public async Task<ActionResult> GetPendingVerifications()
    {
        var pending = await _context.TaskCompletions
            .Include(c => c.TaskAssignment)
            .ThenInclude(a => a!.TaskDefinition)
            .Include(c => c.CompletedByUser)
            .Where(c => c.Status == Domain.Enums.TaskStatus.Completed)
            .OrderBy(c => c.CompletedAt)
            .Select(c => new
            {
                id = c.Id,
                taskTitle = c.TaskAssignment!.TaskDefinition!.Title,
                taskDescription = c.TaskAssignment.TaskDefinition.Description,
                points = c.TaskAssignment.TaskDefinition.DefaultPoints,
                completedByUserId = c.CompletedByUserId,
                completedByUserName = c.CompletedByUser!.DisplayName,
                completedAt = c.CompletedAt,
                date = c.Date,
                notes = c.Notes,
                photoUrl = c.PhotoUrl
            })
            .ToListAsync();

        return Ok(pending);
    }

    [HttpPost("{completionId}/verify")]
    public async Task<IActionResult> VerifyCompletion(Guid completionId, [FromBody] VerifyTaskRequest? request)
    {
        var adminUserId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        var result = await _verificationService.VerifyAsync(completionId, adminUserId, request?.PointsAwarded);
        return result.Outcome switch
        {
            ReviewOutcome.NotFound => NotFound(),
            ReviewOutcome.AlreadyReviewed => BadRequest(new { message = "Task completion has already been verified or rejected" }),
            ReviewOutcome.AlreadyAwarded => BadRequest(new { message = "Points already awarded for this completion" }),
            _ => Ok(new { message = "Task verified and points awarded", pointsAwarded = result.PointsAwarded })
        };
    }

    [HttpPost("{completionId}/reject")]
    public async Task<IActionResult> RejectCompletion(Guid completionId, [FromBody] RejectTaskRequest request)
    {
        var adminUserId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        var result = await _verificationService.RejectAsync(completionId, adminUserId, request.Reason);
        return result.Outcome switch
        {
            ReviewOutcome.NotFound => NotFound(),
            ReviewOutcome.Done => Ok(new { message = "Task rejected" }),
            _ => BadRequest(new { message = "Task completion has already been verified or rejected" })
        };
    }
}
