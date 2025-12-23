using HomeBoard.Api.Models;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AnalyticsController : ControllerBase
{
    private readonly HomeBoardDbContext _context;

    public AnalyticsController(HomeBoardDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<AnalyticsResponseModel>> GetAnalytics([FromQuery] int days = 30)
    {
        var startDate = DateTime.UtcNow.Date.AddDays(-days);
        var endDate = DateTime.UtcNow.Date;

        // Get completion rates over time
        var completions = await _context.TaskCompletions
            .Where(tc => tc.CompletedAt >= startDate && tc.CompletedAt <= endDate)
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
        for (var date = startDate; date <= endDate; date = date.AddDays(1))
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

        // Get points earned (from task completions)
        var pointsEarned = await _context.PointsLedger
            .Where(p => p.CreatedAt >= startDate && p.CreatedAt <= endDate && p.SourceType == PointSourceType.TaskVerified)
            .GroupBy(p => p.CreatedAt.Date)
            .Select(g => new PointsDataPoint
            {
                Date = g.Key,
                Amount = g.Sum(p => p.PointsDelta)
            })
            .OrderBy(p => p.Date)
            .ToListAsync();

        // Get points redeemed (from reward redemptions)
        var pointsRedeemed = await _context.PointsLedger
            .Where(p => p.CreatedAt >= startDate && p.CreatedAt <= endDate && p.SourceType == PointSourceType.RewardRedeemed)
            .GroupBy(p => p.CreatedAt.Date)
            .Select(g => new PointsDataPoint
            {
                Date = g.Key,
                Amount = Math.Abs(g.Sum(p => p.PointsDelta)) // Make positive for display
            })
            .OrderBy(p => p.Date)
            .ToListAsync();

        // Get totals
        var totalEarned = await _context.PointsLedger
            .Where(p => p.SourceType == PointSourceType.TaskVerified)
            .SumAsync(p => p.PointsDelta);

        var totalRedeemed = await _context.PointsLedger
            .Where(p => p.SourceType == PointSourceType.RewardRedeemed)
            .SumAsync(p => Math.Abs(p.PointsDelta));

        var currentBalance = await _context.PointsLedger
            .SumAsync(p => p.PointsDelta);

        return Ok(new AnalyticsResponseModel
        {
            CompletionRates = completionRates,
            PointsAnalytics = new PointsAnalytics
            {
                PointsEarned = pointsEarned,
                PointsRedeemed = pointsRedeemed,
                TotalEarned = totalEarned,
                TotalRedeemed = totalRedeemed,
                CurrentBalance = currentBalance
            }
        });
    }
}
