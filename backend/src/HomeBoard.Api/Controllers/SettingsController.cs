using HomeBoard.Api.Models;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SettingsController : ControllerBase
{
    private readonly HomeBoardDbContext _context;

    public SettingsController(HomeBoardDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<FamilySettingsResponseModel>> GetFamilySettings()
    {
        var settings = await _context.FamilySettings.FirstOrDefaultAsync();
        
        if (settings == null)
        {
            return NotFound(new { message = "Family settings not found" });
        }

        return Ok(new FamilySettingsResponseModel
        {
            Id = settings.Id,
            Timezone = settings.Timezone,
            PointToMoneyRate = settings.PointToMoneyRate,
            WeekStartsOn = settings.WeekStartsOn,
            IncludeAdminsInAssignments = settings.IncludeAdminsInAssignments
        });
    }

    [HttpPatch]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<FamilySettingsResponseModel>> UpdateFamilySettings(
        [FromBody] UpdateFamilySettingsRequestModel request)
    {
        var settings = await _context.FamilySettings.FirstOrDefaultAsync();
        
        if (settings == null)
        {
            return NotFound(new { message = "Family settings not found" });
        }

        // Update only provided fields
        if (request.Timezone != null)
        {
            settings.Timezone = request.Timezone;
        }

        if (request.PointToMoneyRate.HasValue)
        {
            settings.PointToMoneyRate = request.PointToMoneyRate.Value;
        }

        if (request.WeekStartsOn.HasValue)
        {
            settings.WeekStartsOn = request.WeekStartsOn.Value;
        }

        if (request.IncludeAdminsInAssignments.HasValue)
        {
            settings.IncludeAdminsInAssignments = request.IncludeAdminsInAssignments.Value;
        }

        await _context.SaveChangesAsync();

        return Ok(new FamilySettingsResponseModel
        {
            Id = settings.Id,
            Timezone = settings.Timezone,
            PointToMoneyRate = settings.PointToMoneyRate,
            WeekStartsOn = settings.WeekStartsOn,
            IncludeAdminsInAssignments = settings.IncludeAdminsInAssignments
        });
    }
}
