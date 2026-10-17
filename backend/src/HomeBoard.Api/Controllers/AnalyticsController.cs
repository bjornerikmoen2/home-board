using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AnalyticsController : ControllerBase
{
    private readonly IAnalyticsService _analyticsService;

    public AnalyticsController(IAnalyticsService analyticsService)
    {
        _analyticsService = analyticsService;
    }

    /// <summary>The analytics screen offers 7, 30 and 90 days; more than a year is refused.</summary>
    public const int MaxDays = 366;

    [HttpGet]
    public async Task<ActionResult<AnalyticsResponseModel>> GetAnalytics([FromQuery] int days = 30)
    {
        if (days < 1 || days > MaxDays)
        {
            return BadRequest(new { message = $"days must be between 1 and {MaxDays}" });
        }

        var analytics = await _analyticsService.GetAnalyticsAsync(days);
        return Ok(analytics);
    }
}
