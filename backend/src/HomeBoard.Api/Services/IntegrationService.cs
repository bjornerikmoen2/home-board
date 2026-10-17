using HomeBoard.Api.Helpers;
using HomeBoard.Api.Models;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Services;

public interface IIntegrationService
{
    Task<PointsResponse> GetPointsAsync();
}

/// <summary>
/// Read-only summaries for other home services (see IntegrationsController).
/// </summary>
public class IntegrationService : IIntegrationService
{
    private readonly HomeBoardDbContext _context;
    private readonly TimeProvider _time;

    public IntegrationService(HomeBoardDbContext context, TimeProvider? timeProvider = null)
    {
        _context = context;
        _time = timeProvider ?? TimeProvider.System;
    }

    /// <summary>
    /// Points of every active child (User role). The numbers match the scoreboard (points minus
    /// payouts) and the payout preview (net points since the last payout, never paid below zero).
    /// </summary>
    public async Task<PointsResponse> GetPointsAsync()
    {
        var settings = await _context.FamilySettings.FirstOrDefaultAsync();
        var timezone = settings?.Timezone ?? "UTC";
        var rate = settings?.PointToMoneyRate ?? 0m;
        var today = FamilyTime.Today(timezone, _time.GetUtcNow());
        var weekStart = FamilyTime.StartOfDayUtc(DateTimeHelper.GetStartOfWeek(today, settings?.WeekStartsOn ?? DayOfWeek.Monday), timezone);
        var monthStart = FamilyTime.StartOfDayUtc(DateTimeHelper.GetStartOfMonth(today), timezone);

        var children = await _context.Users
            .Where(u => u.IsActive && u.Role == UserRole.User)
            .OrderBy(u => u.DisplayName)
            .ToListAsync();

        var result = new List<ChildPointsDto>();
        foreach (var child in children)
        {
            var ledger = await _context.PointsLedger
                .Where(p => p.UserId == child.Id)
                .Select(p => new { p.PointsDelta, p.CreatedAt })
                .ToListAsync();
            var paidOut = await _context.Payouts
                .Where(p => p.UserId == child.Id)
                .SumAsync(p => (int?)p.NetPoints) ?? 0;
            var lastPayoutAt = (await _context.UserPayoutStates.FirstOrDefaultAsync(s => s.UserId == child.Id))?.LastPayoutAt;
            var sinceLastPayout = ledger.Where(p => lastPayoutAt == null || p.CreatedAt > lastPayoutAt).Sum(p => p.PointsDelta);

            var waiting = await _context.TaskCompletions
                .Where(c => c.CompletedByUserId == child.Id && c.Status == Domain.Enums.TaskStatus.Completed)
                .OrderBy(c => c.CompletedAt)
                .Select(c => new WaitingChoreDto
                {
                    Date = c.Date,
                    Title = c.TaskAssignment!.TaskDefinition!.Title,
                    Points = c.TaskAssignment.TaskDefinition.DefaultPoints,
                    CompletedAt = c.CompletedAt
                })
                .ToListAsync();

            result.Add(new ChildPointsDto
            {
                Name = child.DisplayName,
                ScoreboardPoints = ledger.Sum(p => p.PointsDelta) - paidOut,
                PointsSinceLastPayout = sinceLastPayout,
                MoneyToPay = Math.Max(sinceLastPayout, 0) * rate,
                LastPayoutAt = lastPayoutAt,
                EarnedThisWeek = ledger.Where(p => p.PointsDelta > 0 && p.CreatedAt >= weekStart).Sum(p => p.PointsDelta),
                EarnedThisMonth = ledger.Where(p => p.PointsDelta > 0 && p.CreatedAt >= monthStart).Sum(p => p.PointsDelta),
                WaitingForApproval = waiting
            });
        }

        return new PointsResponse
        {
            Timezone = timezone,
            Today = today,
            PointToMoneyRate = rate,
            Users = result
        };
    }
}
