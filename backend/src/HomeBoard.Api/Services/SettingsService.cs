using HomeBoard.Api.Models;
using HomeBoard.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Services;

public interface ISettingsService
{
    Task<bool> GetScoreboardEnabledAsync();
    Task<FamilySettingsResponseModel> GetFamilySettingsAsync();
    Task<FamilySettingsResponseModel> UpdateFamilySettingsAsync(UpdateFamilySettingsRequestModel request);
}

public class SettingsService : ISettingsService
{
    private readonly HomeBoardDbContext _context;

    public SettingsService(HomeBoardDbContext context)
    {
        _context = context;
    }

    public async Task<bool> GetScoreboardEnabledAsync()
    {
        var settings = await _context.FamilySettings.FirstOrDefaultAsync();
        return settings?.EnableScoreboard ?? false;
    }

    public async Task<FamilySettingsResponseModel> GetFamilySettingsAsync()
    {
        var settings = await _context.FamilySettings.FirstOrDefaultAsync();
        
        if (settings == null)
        {
            throw new KeyNotFoundException("Family settings not found");
        }

        return new FamilySettingsResponseModel
        {
            Id = settings.Id,
            Timezone = settings.Timezone,
            PointToMoneyRate = settings.PointToMoneyRate,
            WeekStartsOn = settings.WeekStartsOn,
            EnableScoreboard = settings.EnableScoreboard,
            IncludeAdminsInAssignments = settings.IncludeAdminsInAssignments
        };
    }

    public async Task<FamilySettingsResponseModel> UpdateFamilySettingsAsync(UpdateFamilySettingsRequestModel request)
    {
        var settings = await _context.FamilySettings.FirstOrDefaultAsync();
        
        if (settings == null)
        {
            throw new KeyNotFoundException("Family settings not found");
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

        if (request.EnableScoreboard.HasValue)
        {
            settings.EnableScoreboard = request.EnableScoreboard.Value;
        }

        if (request.IncludeAdminsInAssignments.HasValue)
        {
            settings.IncludeAdminsInAssignments = request.IncludeAdminsInAssignments.Value;
        }

        await _context.SaveChangesAsync();

        return new FamilySettingsResponseModel
        {
            Id = settings.Id,
            Timezone = settings.Timezone,
            PointToMoneyRate = settings.PointToMoneyRate,
            WeekStartsOn = settings.WeekStartsOn,
            EnableScoreboard = settings.EnableScoreboard,
            IncludeAdminsInAssignments = settings.IncludeAdminsInAssignments
        };
    }
}
