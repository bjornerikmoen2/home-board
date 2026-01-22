using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ScoreboardController : ControllerBase
{
    private readonly IScoreboardService _scoreboardService;

    public ScoreboardController(IScoreboardService scoreboardService)
    {
        _scoreboardService = scoreboardService;
    }

    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<ScoreboardResponseModel>> GetScoreboard()
    {
        try
        {
            var scoreboard = await _scoreboardService.GetScoreboardAsync();
            return Ok(scoreboard);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }
}
