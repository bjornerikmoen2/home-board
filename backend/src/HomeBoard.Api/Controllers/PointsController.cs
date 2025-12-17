using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/users")]
[Authorize]
public class PointsController : ControllerBase
{
    private readonly HomeBoardDbContext _context;
    private readonly IPointsService _pointsService;

    public PointsController(HomeBoardDbContext context, IPointsService pointsService)
    {
        _context = context;
        _pointsService = pointsService;
    }

    [HttpGet("{id}/points")]
    public async Task<ActionResult<UserPointsDto>> GetUserPoints(Guid id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            return NotFound();
        }

        var totalPoints = await _pointsService.GetUserTotalPointsAsync(id);
        var history = await _pointsService.GetUserPointsHistoryAsync(id, 20);

        return Ok(new UserPointsDto
        {
            UserId = user.Id,
            DisplayName = user.DisplayName,
            TotalPoints = totalPoints,
            RecentEntries = history.Select(p => new PointsEntryDto
            {
                Id = p.Id,
                SourceType = p.SourceType.ToString(),
                PointsDelta = p.PointsDelta,
                Note = p.Note,
                CreatedAt = p.CreatedAt
            }).ToList()
        });
    }
}
