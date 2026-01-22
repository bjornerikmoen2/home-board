using HomeBoard.Api.Models;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Services;

public interface IAnalyticsService
{
    Task<AnalyticsResponseModel> GetAnalyticsAsync(int days = 30);
}

public class AnalyticsService : IAnalyticsService
{
    private readonly HomeBoardDbContext _context;

    public AnalyticsService(HomeBoardDbContext context)
    {
        _context = context;
    }

    public async Task<AnalyticsResponseModel> GetAnalyticsAsync(int days = 30)
    {
        var startDate = DateTime.UtcNow.Date.AddDays(-days);
        var endDate = DateTime.UtcNow.Date.AddDays(1); // Include today by going to start of tomorrow

        // Get completion rates over time
        var completions = await _context.TaskCompletions
            .Where(tc => tc.CompletedAt >= startDate && tc.CompletedAt < endDate)
            .GroupBy(tc => tc.CompletedAt.Date)
            .Select(g => new
            {
                Date = g.Key,
                Count = g.Count()
            })
            .ToListAsync();

        // Get all task assignments for the period to calculate total tasks per day
        var assignments = await _context.TaskAssignments
            .Include(ta => ta.TaskDefinition)
            .Where(ta => ta.IsActive)
            .ToListAsync();

        var completionRates = new List<CompletionRateDataPoint>();
        for (var date = startDate; date < endDate; date = date.AddDays(1))
        {
            var dayOfWeek = (int)date.DayOfWeek;
            var dayFlag = 1 << dayOfWeek;

            // Count tasks assigned for this day
            var totalTasks = assignments.Count(a =>
                a.ScheduleType == ScheduleType.Daily ||
                (a.ScheduleType == ScheduleType.Weekly &&
                 ((int)a.DaysOfWeek & dayFlag) != 0));

            var completedTasks = completions.FirstOrDefault(c => c.Date == date)?.Count ?? 0;
            var rate = totalTasks > 0 ? (decimal)completedTasks / totalTasks * 100 : 0;

            completionRates.Add(new CompletionRateDataPoint
            {
                Date = date,
                TotalTasks = totalTasks,
                CompletedTasks = completedTasks,
                CompletionRate = Math.Round(rate, 2)
            });
        }

        // Get points earned (from task completions, bonuses, and adjustments that add points)
        var pointsEarned = await _context.PointsLedger
            .Where(p => p.CreatedAt >= startDate && p.CreatedAt < endDate && p.PointsDelta > 0)
            .GroupBy(p => p.CreatedAt.Date)
            .Select(g => new PointsDataPoint
            {
                Date = g.Key,
                Amount = g.Sum(p => p.PointsDelta)
            })
            .OrderBy(p => p.Date)
            .ToListAsync();

        // Get money paid out (from payouts)
        var moneyPaidOut = await _context.Payouts
            .Where(p => p.PaidAt >= startDate && p.PaidAt < endDate)
            .GroupBy(p => p.PaidAt.Date)
            .Select(g => new MoneyDataPoint
            {
                Date = g.Key,
                Amount = g.Sum(p => p.MoneyPaid)
            })
            .OrderBy(p => p.Date)
            .ToListAsync();

        // Get totals
        var totalPointsEarned = await _context.PointsLedger
            .SumAsync(p => p.PointsDelta);

        var totalPointsPaidOut = await _context.Payouts
            .SumAsync(p => (int?)p.NetPoints) ?? 0;

        var totalMoneyPaidOut = await _context.Payouts
            .SumAsync(p => (decimal?)p.MoneyPaid) ?? 0m;

        var currentBalance = totalPointsEarned - totalPointsPaidOut;

        return new AnalyticsResponseModel
        {
            CompletionRates = completionRates,
            PointsAnalytics = new PointsAnalytics
            {
                PointsEarned = pointsEarned,
                MoneyPaidOut = moneyPaidOut,
                TotalEarned = totalPointsEarned,
                TotalPaidOut = totalMoneyPaidOut,
                CurrentBalance = currentBalance
            }
        };
    }
}
