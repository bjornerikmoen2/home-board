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

public class PointsTests : IDisposable
{
    // Monday 19 October 2026, 12:00 in Oslo (CEST, UTC+2).
    private static readonly DateTimeOffset MondayNoon = new(2026, 10, 19, 10, 0, 0, TimeSpan.Zero);

    private readonly HomeBoardDbContext _context;
    private readonly IntegrationService _service;
    private readonly User _ola;
    private readonly User _nora;

    public PointsTests()
    {
        var options = new DbContextOptionsBuilder<HomeBoardDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new HomeBoardDbContext(options);
        _service = new IntegrationService(_context, new FixedTime(MondayNoon));

        _context.FamilySettings.Add(new FamilySettings
        {
            Id = Guid.NewGuid(),
            Timezone = "Europe/Oslo",
            WeekStartsOn = DayOfWeek.Monday,
            PointToMoneyRate = 0.5m,
            EnableScoreboard = true
        });
        _ola = AddUser("Ola", UserRole.User);
        _nora = AddUser("Nora", UserRole.User);
        var kari = AddUser("Kari", UserRole.Admin);

        // Ola: 50 points in September, paid out on 1 October; 10 last week; 20 just after midnight today.
        AddPoints(_ola, 50, Utc(2026, 9, 30, 12));
        _context.Payouts.Add(new Payout
        {
            Id = Guid.NewGuid(), UserId = _ola.Id, PeriodStart = DateTime.MinValue, PeriodEnd = Utc(2026, 10, 1, 18),
            NetPoints = 50, PointToMoneyRate = 0.5m, MoneyPaid = 25m, PaidByUserId = kari.Id, PaidAt = Utc(2026, 10, 1, 18)
        });
        _context.UserPayoutStates.Add(new UserPayoutState { UserId = _ola.Id, LastPayoutAt = Utc(2026, 10, 1, 18), UpdatedAt = Utc(2026, 10, 1, 18) });
        AddPoints(_ola, 10, Utc(2026, 10, 14, 15));
        AddPoints(_ola, 20, Utc(2026, 10, 18, 22, 30));

        // Nora: never paid out; 15 earned and 5 taken off today.
        AddPoints(_nora, 15, Utc(2026, 10, 19, 7));
        AddPoints(_nora, -5, Utc(2026, 10, 19, 8), PointSourceType.Adjustment);

        Complete(_nora, "Feed the cat", TaskStatus.Completed, Utc(2026, 10, 19, 6));
        Complete(_ola, "Make bed", TaskStatus.Verified, Utc(2026, 10, 19, 5));
        AddPoints(kari, 100, Utc(2026, 10, 19, 7));
        _context.SaveChanges();
    }

    public void Dispose() => _context.Dispose();

    [Fact]
    public async Task GetPoints_SummarisesEachChild()
    {
        var result = await _service.GetPointsAsync();

        Assert.Equal(new DateOnly(2026, 10, 19), result.Today);
        Assert.Equal(0.5m, result.PointToMoneyRate);
        Assert.Equal(new[] { "Nora", "Ola" }, result.Users.Select(u => u.Name));

        var ola = result.Users.Single(u => u.Name == "Ola");
        Assert.Equal(30, ola.ScoreboardPoints);
        Assert.Equal(30, ola.PointsSinceLastPayout);
        Assert.Equal(15m, ola.MoneyToPay);
        Assert.Equal(Utc(2026, 10, 1, 18), ola.LastPayoutAt);
        Assert.Equal(20, ola.EarnedThisWeek);
        Assert.Equal(30, ola.EarnedThisMonth);
        Assert.Empty(ola.WaitingForApproval);

        var nora = result.Users.Single(u => u.Name == "Nora");
        Assert.Equal(10, nora.ScoreboardPoints);
        Assert.Equal(5m, nora.MoneyToPay);
        Assert.Null(nora.LastPayoutAt);
        Assert.Equal(15, nora.EarnedThisWeek);
        var waiting = Assert.Single(nora.WaitingForApproval);
        Assert.Equal(("Feed the cat", 10), (waiting.Title, waiting.Points));
    }

    [Fact]
    public async Task GetPoints_NeverPaysBelowZero()
    {
        AddPoints(_nora, -50, Utc(2026, 10, 19, 9), PointSourceType.Adjustment);
        _context.SaveChanges();

        var nora = (await _service.GetPointsAsync()).Users.Single(u => u.Name == "Nora");

        Assert.Equal(-40, nora.PointsSinceLastPayout);
        Assert.Equal(0m, nora.MoneyToPay);
    }

    [Theory]
    [InlineData(null, typeof(NotFoundResult))]
    [InlineData("wrong-key", typeof(UnauthorizedResult))]
    [InlineData("the-right-key", typeof(OkObjectResult))]
    public async Task Endpoint_NeedsTheKey(string? sentKey, Type expected)
    {
        var configured = sentKey == null ? null : "the-right-key";
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> { ["Integrations:ApiKey"] = configured })
            .Build();
        var httpContext = new DefaultHttpContext();
        httpContext.Request.Headers[IntegrationsController.ApiKeyHeader] = sentKey ?? "";
        var controller = new IntegrationsController(new TaskService(_context), _service, configuration)
        {
            ControllerContext = new ControllerContext { HttpContext = httpContext }
        };

        var result = await controller.GetPoints();

        Assert.IsType(expected, result.Result);
    }

    private static DateTime Utc(int year, int month, int day, int hour, int minute = 0) =>
        new(year, month, day, hour, minute, 0, DateTimeKind.Utc);

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

    private void AddPoints(User user, int points, DateTime createdAt, PointSourceType source = PointSourceType.TaskVerified)
    {
        _context.PointsLedger.Add(new PointsLedger
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            SourceType = source,
            PointsDelta = points,
            CreatedByUserId = user.Id,
            CreatedAt = createdAt
        });
    }

    private void Complete(User user, string title, TaskStatus status, DateTime completedAt)
    {
        var definition = new TaskDefinition
        {
            Id = Guid.NewGuid(), Title = title, DefaultPoints = 10, IsActive = true,
            CreatedByUserId = Guid.NewGuid(), CreatedAt = DateTime.UtcNow
        };
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(), TaskDefinitionId = definition.Id, TaskDefinition = definition, AssignedToUserId = user.Id,
            ScheduleType = ScheduleType.Daily, IsActive = true, CreatedAt = DateTime.UtcNow
        };
        _context.TaskDefinitions.Add(definition);
        _context.TaskAssignments.Add(assignment);
        _context.TaskCompletions.Add(new TaskCompletion
        {
            Id = Guid.NewGuid(), TaskAssignmentId = assignment.Id, Date = DateOnly.FromDateTime(completedAt),
            CompletedByUserId = user.Id, CompletedAt = completedAt, Status = status
        });
    }

    private sealed class FixedTime(DateTimeOffset utcNow) : TimeProvider
    {
        public override DateTimeOffset GetUtcNow() => utcNow;
    }
}
