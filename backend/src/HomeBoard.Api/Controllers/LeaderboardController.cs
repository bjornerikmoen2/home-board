using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class LeaderboardController : ControllerBase
{
    private readonly HomeBoardDbContext _context;
    private readonly IPointsService _pointsService;

    public LeaderboardController(HomeBoardDbContext context, IPointsService pointsService)
    {
        _context = context;
        _pointsService = pointsService;
    }

    [HttpGet]
    public async Task<ActionResult<List<LeaderboardEntryDto>>> GetLeaderboard([FromQuery] string? period = "all")
    {
        DateTime? fromDate = period switch
        {
            "week" => DateTime.UtcNow.AddDays(-7),
            "month" => DateTime.UtcNow.AddMonths(-1),
            _ => null
        };

        var pointsByUser = await _pointsService.GetLeaderboardAsync(fromDate);
        var userIds = pointsByUser.Keys.ToList();

        var users = await _context.Users
            .Where(u => userIds.Contains(u.Id) && u.IsActive)
            .ToDictionaryAsync(u => u.Id, u => u);

        var leaderboard = pointsByUser
            .Where(kvp => users.ContainsKey(kvp.Key))
            .Select(kvp => new LeaderboardEntryDto
            {
                UserId = kvp.Key,
                DisplayName = users[kvp.Key].DisplayName,
                TotalPoints = kvp.Value,
                Rank = 0 // Will be set after sorting
            })
            .OrderByDescending(e => e.TotalPoints)
            .ToList();

        // Assign ranks
        for (int i = 0; i < leaderboard.Count; i++)
        {
            leaderboard[i].Rank = i + 1;
        }

        return Ok(leaderboard);
    }
}
