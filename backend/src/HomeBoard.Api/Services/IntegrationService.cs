using HomeBoard.Api.Helpers;
using HomeBoard.Api.Models;
using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Services;

public interface IIntegrationService
{
    Task<PointsResponse> GetPointsAsync();

    /// <summary>
    /// The parent that changes from other home services are recorded under: the active admin with
    /// this username, or the first admin created when none is given. Null when there is none.
    /// </summary>
    Task<Guid?> FindActingAdminAsync(string? username);

    Task<ReviewResult> ApproveChoreAsync(Guid completionId, int? points, Guid adminUserId);
    Task<ReviewResult> RejectChoreAsync(Guid completionId, string? reason, Guid adminUserId);

    /// <summary>Gives an active child bonus points; returns the child's name, or null when there is no such child.</summary>
    Task<string?> AwardBonusPointsAsync(Guid userId, int points, string? description, Guid adminUserId);
}

/// <summary>
/// Summaries for other home services, and the few changes they may make (see IntegrationsController).
/// </summary>
public class IntegrationService : IIntegrationService
{
    private readonly HomeBoardDbContext _context;
    private readonly TimeProvider _time;
    private readonly IVerificationService _verification;

    public IntegrationService(HomeBoardDbContext context, TimeProvider? timeProvider = null, IVerificationService? verification = null)
    {
        _context = context;
        _time = timeProvider ?? TimeProvider.System;
        _verification = verification ?? new VerificationService(context);
    }

    public async Task<Guid?> FindActingAdminAsync(string? username)
    {
        var admins = _context.Users.Where(u => u.IsActive && u.Role == UserRole.Admin);
        var admin = string.IsNullOrEmpty(username)
            ? await admins.OrderBy(u => u.CreatedAt).FirstOrDefaultAsync()
            : await admins.FirstOrDefaultAsync(u => u.Username == username);
        return admin?.Id;
    }

    public Task<ReviewResult> ApproveChoreAsync(Guid completionId, int? points, Guid adminUserId) =>
        _verification.VerifyAsync(completionId, adminUserId, points);

    public Task<ReviewResult> RejectChoreAsync(Guid completionId, string? reason, Guid adminUserId) =>
        _verification.RejectAsync(completionId, adminUserId, reason);

    public async Task<string?> AwardBonusPointsAsync(Guid userId, int points, string? description, Guid adminUserId)
    {
        var child = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId && u.IsActive && u.Role == UserRole.User);
        if (child == null)
        {
            return null;
        }

        _context.PointsLedger.Add(new PointsLedger
        {
            Id = Guid.NewGuid(),
            UserId = child.Id,
            SourceType = PointSourceType.Bonus,
            PointsDelta = points,
            Note = string.IsNullOrWhiteSpace(description) ? "Bonus" : description.Trim(),
            CreatedByUserId = adminUserId,
            CreatedAt = _time.GetUtcNow().UtcDateTime
        });
        await _context.SaveChangesAsync();
        return child.DisplayName;
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
                    CompletionId = c.Id,
                    Date = c.Date,
                    Title = c.TaskAssignment!.TaskDefinition!.Title,
                    Points = c.TaskAssignment.TaskDefinition.DefaultPoints,
                    CompletedAt = c.CompletedAt
                })
                .ToListAsync();

            result.Add(new ChildPointsDto
            {
                UserId = child.Id,
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
