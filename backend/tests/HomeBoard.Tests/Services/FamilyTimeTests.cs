using HomeBoard.Api.Controllers;
using HomeBoard.Api.Helpers;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Tests.Services;

/// <summary>
/// "Today" follows the family's timezone: at 00:30 on Sunday 18 October 2026 in Oslo (CEST,
/// UTC+2) it is still Saturday 22:30 in UTC.
/// </summary>
public class FamilyTimeTests : IDisposable
{
    private const string Oslo = "Europe/Oslo";
    private static readonly DateTimeOffset JustAfterMidnight = new(2026, 10, 17, 22, 30, 0, TimeSpan.Zero);
    private static readonly DateOnly Saturday = new(2026, 10, 17);
    private static readonly DateOnly Sunday = new(2026, 10, 18);

    private readonly HomeBoardDbContext _context;
    private readonly FixedTime _clock = new(JustAfterMidnight);
    private readonly User _ola;

    public FamilyTimeTests()
    {
        var options = new DbContextOptionsBuilder<HomeBoardDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new HomeBoardDbContext(options);
        _context.FamilySettings.Add(new FamilySettings
        {
            Id = Guid.NewGuid(),
            Timezone = Oslo,
            WeekStartsOn = DayOfWeek.Monday,
            EnableScoreboard = true
        });
        _ola = new User
        {
            Id = Guid.NewGuid(),
            Username = "ola",
            DisplayName = "Ola",
            PasswordHash = "hash",
            Role = UserRole.User,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
        _context.Users.Add(_ola);
        _context.SaveChanges();
    }

    public void Dispose() => _context.Dispose();

    [Fact]
    public void Today_IsTheLocalDate()
    {
        Assert.Equal(Sunday, FamilyTime.Today(Oslo, JustAfterMidnight));
        Assert.Equal(Saturday, FamilyTime.Today("UTC", JustAfterMidnight));
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("Not/AZone")]
    public void Today_FallsBackToUtc(string? timezone)
    {
        Assert.Equal(Saturday, FamilyTime.Today(timezone, JustAfterMidnight));
    }

    [Fact]
    public void StartOfDayUtc_FollowsSummerAndWinterTime()
    {
        Assert.Equal(new DateTime(2026, 10, 18, 22, 0, 0, DateTimeKind.Utc), FamilyTime.StartOfDayUtc(new DateOnly(2026, 10, 19), Oslo));
        Assert.Equal(new DateTime(2026, 11, 1, 23, 0, 0, DateTimeKind.Utc), FamilyTime.StartOfDayUtc(new DateOnly(2026, 11, 2), Oslo));
        Assert.Equal(DateTimeKind.Utc, FamilyTime.StartOfDayUtc(Sunday, Oslo).Kind);
    }

    [Fact]
    public async Task CompletingAChoreAfterMidnight_CountsForTheNewDay()
    {
        var daily = Assign("Make bed", ScheduleType.Daily);
        var service = new TaskService(_context, _clock);

        var completionId = await service.CompleteTaskAsync(daily.Id, _ola.Id, null);

        var completion = await _context.TaskCompletions.SingleAsync(c => c.Id == completionId);
        Assert.Equal(Sunday, completion.Date);
        Assert.Equal(JustAfterMidnight.UtcDateTime, completion.CompletedAt);
    }

    [Fact]
    public async Task TodayList_ShowsTheNewDaysChoresAfterMidnight()
    {
        Assign("Sunday chore", ScheduleType.Weekly, DayOfWeekFlag.Sunday);
        Assign("Saturday chore", ScheduleType.Weekly, DayOfWeekFlag.Saturday);

        var tasks = await new TaskService(_context, _clock).GetTodayTasksAsync(_ola.Id);

        Assert.Equal(new[] { "Sunday chore" }, tasks.Select(t => t.Title));
    }

    [Fact]
    public async Task Scoreboard_ShowsTheNewDaysChoresAfterMidnight()
    {
        Assign("Sunday chore", ScheduleType.Weekly, DayOfWeekFlag.Sunday);
        Assign("Saturday chore", ScheduleType.Weekly, DayOfWeekFlag.Saturday);

        var scoreboard = await new ScoreboardService(_context, _clock).GetScoreboardAsync();

        Assert.Equal(new[] { "Sunday chore" }, scoreboard.Users.Single().Tasks.Select(t => t.Title));
    }

    [Fact]
    public async Task Leaderboard_WeeksStartAtLocalMidnight()
    {
        // Monday 19 October, 12:00 in Oslo. Points at 00:30 Monday belong to this week, points at
        // 23:30 Sunday to the previous one, although both are on Sunday in UTC.
        var monday = new FixedTime(new DateTimeOffset(2026, 10, 19, 10, 0, 0, TimeSpan.Zero));
        AddPoints(10, new DateTime(2026, 10, 18, 22, 30, 0, DateTimeKind.Utc));
        AddPoints(5, new DateTime(2026, 10, 18, 21, 30, 0, DateTimeKind.Utc));
        var controller = new LeaderboardController(_context, new PointsService(_context), monday);

        Assert.Equal(10, await PointsFor(controller, "week"));
        Assert.Equal(5, await PointsFor(controller, "previousWeek"));
        Assert.Equal(15, await PointsFor(controller, "month"));
    }

    private async Task<int> PointsFor(LeaderboardController controller, string period)
    {
        var result = await controller.GetLeaderboard(period);
        var entries = Assert.IsType<List<LeaderboardEntryDto>>(Assert.IsType<OkObjectResult>(result.Result).Value);
        return entries.SingleOrDefault()?.TotalPoints ?? 0;
    }

    private TaskAssignment Assign(string title, ScheduleType schedule, DayOfWeekFlag days = DayOfWeekFlag.None)
    {
        var definition = new TaskDefinition
        {
            Id = Guid.NewGuid(),
            Title = title,
            DefaultPoints = 10,
            IsActive = true,
            CreatedByUserId = Guid.NewGuid(),
            CreatedAt = DateTime.UtcNow
        };
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(),
            TaskDefinitionId = definition.Id,
            TaskDefinition = definition,
            AssignedToUserId = _ola.Id,
            ScheduleType = schedule,
            DaysOfWeek = days,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
        _context.TaskDefinitions.Add(definition);
        _context.TaskAssignments.Add(assignment);
        _context.SaveChanges();
        return assignment;
    }

    private void AddPoints(int points, DateTime createdAt)
    {
        _context.PointsLedger.Add(new PointsLedger
        {
            Id = Guid.NewGuid(),
            UserId = _ola.Id,
            SourceType = PointSourceType.Bonus,
            PointsDelta = points,
            CreatedByUserId = _ola.Id,
            CreatedAt = createdAt
        });
        _context.SaveChanges();
    }

    private sealed class FixedTime(DateTimeOffset utcNow) : TimeProvider
    {
        public override DateTimeOffset GetUtcNow() => utcNow;
    }
}
