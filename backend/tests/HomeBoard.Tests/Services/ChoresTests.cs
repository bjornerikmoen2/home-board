using HomeBoard.Api.Controllers;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using TaskStatus = HomeBoard.Domain.Enums.TaskStatus;

namespace HomeBoard.Tests.Services;

public class ChoresTests : IDisposable
{
    // A week starting on Monday 12 October 2026.
    private static readonly DateOnly Monday = new(2026, 10, 12);
    private static readonly DateOnly Tuesday = Monday.AddDays(1);
    private static readonly DateOnly Wednesday = Monday.AddDays(2);

    private readonly HomeBoardDbContext _context;
    private readonly TaskService _taskService;
    private readonly User _ola;
    private readonly User _nora;

    public ChoresTests()
    {
        var options = new DbContextOptionsBuilder<HomeBoardDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new HomeBoardDbContext(options);
        _taskService = new TaskService(_context);

        _context.FamilySettings.Add(new FamilySettings
        {
            Id = Guid.NewGuid(),
            Timezone = "UTC",
            WeekStartsOn = DayOfWeek.Monday,
            EnableScoreboard = true
        });
        _ola = AddUser("Ola", UserRole.User);
        _nora = AddUser("Nora", UserRole.User);
        var kari = AddUser("Kari", UserRole.Admin);

        var makeBed = Assign("Make bed", ScheduleType.Daily, user: _ola);
        Assign("Feed the cat", ScheduleType.Weekly, user: _nora, days: DayOfWeekFlag.Monday | DayOfWeekFlag.Wednesday);
        var vacuum = Assign("Vacuum room", ScheduleType.DuringWeek, user: _ola);
        var dishwasher = Assign("Empty dishwasher", ScheduleType.Daily, group: UserRole.User);
        Assign("Bake buns", ScheduleType.Once, user: _nora, start: Wednesday);
        Assign("Old chore", ScheduleType.Daily, user: _ola, active: false);
        Assign("Mow the lawn", ScheduleType.Daily, user: kari, end: Monday);

        Complete(makeBed, Monday, _ola, TaskStatus.Verified);
        Complete(dishwasher, Monday, _nora, TaskStatus.Completed);
        Complete(vacuum, Tuesday, _ola, TaskStatus.Completed);
        _context.SaveChanges();
    }

    public void Dispose() => _context.Dispose();

    [Fact]
    public async Task GetChores_ListsEachDaysChoresWithStatus()
    {
        var result = await _taskService.GetChoresAsync(Monday, Monday);

        Assert.Equal("UTC", result.Timezone);
        Assert.Equal(
            new[]
            {
                "Kari: Mow the lawn (todo)",
                "Nora: Feed the cat (todo)",
                "Ola: Make bed (verified by Ola)",
                "Ola: Vacuum room (todo)",
                "kids: Empty dishwasher (done by Nora)",
            },
            result.Chores.Select(Describe).OrderBy(s => s, StringComparer.Ordinal));
    }

    [Fact]
    public async Task GetChores_DuringWeekChoreShowsUntilTheDayItIsDone()
    {
        var result = await _taskService.GetChoresAsync(Monday, Wednesday);
        var vacuum = result.Chores.Where(c => c.Title == "Vacuum room").ToList();

        Assert.Equal(new[] { Monday, Tuesday }, vacuum.Select(c => c.Date));
        Assert.Equal(new[] { "todo", "done" }, vacuum.Select(c => c.Status));
        Assert.Equal("during_week", vacuum[0].Schedule);
    }

    [Fact]
    public async Task GetChores_WeeklyOnceAndEndedChoresOnlyOnTheirDays()
    {
        var wednesday = (await _taskService.GetChoresAsync(Wednesday, Wednesday)).Chores;

        Assert.Contains(wednesday, c => c.Title == "Feed the cat");
        Assert.Contains(wednesday, c => c.Title == "Bake buns" && c.Schedule == "once");
        Assert.DoesNotContain(wednesday, c => c.Title == "Mow the lawn" || c.Title == "Old chore");
        var tuesday = (await _taskService.GetChoresAsync(Tuesday, Tuesday)).Chores;
        Assert.DoesNotContain(tuesday, c => c.Title is "Feed the cat" or "Bake buns");
    }

    [Fact]
    public async Task GetChores_GroupChoresHaveNoSinglePerson()
    {
        var dishwasher = (await _taskService.GetChoresAsync(Monday, Monday)).Chores.Single(c => c.Title == "Empty dishwasher");

        Assert.Null(dishwasher.AssignedTo);
        Assert.Equal("kids", dishwasher.AssignedToGroup);
        Assert.Equal("Nora", dishwasher.CompletedBy);
    }

    [Theory]
    [InlineData("2026-10-13", "2026-10-12")]
    [InlineData("2026-10-01", "2026-12-31")]
    public async Task GetChores_RejectsBadRanges(string start, string end)
    {
        await Assert.ThrowsAsync<ArgumentException>(
            () => _taskService.GetChoresAsync(DateOnly.Parse(start), DateOnly.Parse(end)));
    }

    [Fact]
    public async Task Endpoint_IsHiddenWithoutAConfiguredKey()
    {
        var result = await Controller(configuredKey: null, sentKey: "anything").GetChores(Monday, Monday);
        Assert.IsType<NotFoundResult>(result.Result);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("wrong-key")]
    [InlineData("the-right-key-but-longer")]
    public async Task Endpoint_RefusesAWrongKey(string? sentKey)
    {
        var result = await Controller(configuredKey: "the-right-key", sentKey).GetChores(Monday, Monday);
        Assert.IsType<UnauthorizedResult>(result.Result);
    }

    [Fact]
    public async Task Endpoint_ReturnsChoresForTheRightKey()
    {
        var result = await Controller(configuredKey: "the-right-key", sentKey: "the-right-key").GetChores(Monday, Tuesday);

        var ok = Assert.IsType<OkObjectResult>(result.Result);
        var chores = Assert.IsType<ChoresResponse>(ok.Value);
        Assert.Equal(Tuesday, chores.EndDate);
    }

    [Fact]
    public async Task Endpoint_ReportsBadRanges()
    {
        var result = await Controller(configuredKey: "the-right-key", sentKey: "the-right-key").GetChores(Tuesday, Monday);
        Assert.IsType<BadRequestObjectResult>(result.Result);
    }

    private IntegrationsController Controller(string? configuredKey, string? sentKey)
    {
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> { ["Integrations:ApiKey"] = configuredKey })
            .Build();
        var httpContext = new DefaultHttpContext();
        if (sentKey != null)
        {
            httpContext.Request.Headers[IntegrationsController.ApiKeyHeader] = sentKey;
        }
        return new IntegrationsController(_taskService, new IntegrationService(_context), configuration)
        {
            ControllerContext = new ControllerContext { HttpContext = httpContext }
        };
    }

    private static string Describe(ChoreDto chore)
    {
        var by = chore.CompletedBy != null ? $" by {chore.CompletedBy}" : "";
        return $"{chore.AssignedTo ?? chore.AssignedToGroup}: {chore.Title} ({chore.Status}{by})";
    }

    private User AddUser(string name, UserRole role)
    {
        var user = new User
        {
            Id = Guid.NewGuid(),
            Username = name.ToLowerInvariant(),
            DisplayName = name,
            PasswordHash = "hash",
            Role = role,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
        _context.Users.Add(user);
        return user;
    }

    private TaskAssignment Assign(
        string title,
        ScheduleType schedule,
        User? user = null,
        UserRole? group = null,
        DayOfWeekFlag days = DayOfWeekFlag.None,
        DateOnly? start = null,
        DateOnly? end = null,
        bool active = true)
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
            AssignedToUserId = user?.Id,
            AssignedToGroup = (int?)group,
            ScheduleType = schedule,
            DaysOfWeek = days,
            StartDate = start,
            EndDate = end,
            IsActive = active,
            CreatedAt = DateTime.UtcNow
        };
        _context.TaskDefinitions.Add(definition);
        _context.TaskAssignments.Add(assignment);
        return assignment;
    }

    private void Complete(TaskAssignment assignment, DateOnly date, User by, TaskStatus status)
    {
        _context.TaskCompletions.Add(new TaskCompletion
        {
            Id = Guid.NewGuid(),
            TaskAssignmentId = assignment.Id,
            Date = date,
            CompletedByUserId = by.Id,
            CompletedAt = date.ToDateTime(new TimeOnly(17, 0), DateTimeKind.Utc),
            Status = status
        });
    }
}
