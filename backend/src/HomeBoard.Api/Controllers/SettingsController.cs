using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SettingsController : ControllerBase
{
    private readonly ISettingsService _settingsService;

    public SettingsController(ISettingsService settingsService)
    {
        _settingsService = settingsService;
    }

    [HttpGet("scoreboard-enabled")]
    [AllowAnonymous]
    public async Task<ActionResult<bool>> GetScoreboardEnabled()
    {
        var enabled = await _settingsService.GetScoreboardEnabledAsync();
        return Ok(enabled);
    }

    [HttpGet]
    public async Task<ActionResult<FamilySettingsResponseModel>> GetFamilySettings()
    {
        try
        {
            var settings = await _settingsService.GetFamilySettingsAsync();
            return Ok(settings);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpPatch]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<FamilySettingsResponseModel>> UpdateFamilySettings(
        [FromBody] UpdateFamilySettingsRequestModel request)
    {
        try
        {
            var settings = await _settingsService.UpdateFamilySettingsAsync(request);
            return Ok(settings);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }
}
