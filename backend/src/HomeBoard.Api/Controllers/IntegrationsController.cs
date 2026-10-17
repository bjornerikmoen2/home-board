using System.Security.Cryptography;
using System.Text;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeBoard.Api.Controllers;

/// <summary>
/// Read-only data for other home services, such as a personal assistant. Protected by a shared
/// API key (setting Integrations:ApiKey, sent in the X-Api-Key header) instead of a user login;
/// every endpoint answers 404 while no key is configured.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[AllowAnonymous]
public class IntegrationsController : ControllerBase
{
    public const string ApiKeyHeader = "X-Api-Key";

    private readonly ITaskService _taskService;
    private readonly string? _apiKey;

    public IntegrationsController(ITaskService taskService, IConfiguration configuration)
    {
        _taskService = taskService;
        _apiKey = configuration["Integrations:ApiKey"];
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
        if (!HasValidApiKey())
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

    private bool HasValidApiKey()
    {
        var given = Encoding.UTF8.GetBytes(Request.Headers[ApiKeyHeader].ToString());
        var expected = Encoding.UTF8.GetBytes(_apiKey!);
        return CryptographicOperations.FixedTimeEquals(given, expected);
    }
}
