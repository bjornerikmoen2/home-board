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

/// <summary>Approving chores and giving bonus points from another home service.</summary>
public class IntegrationWriteTests : IDisposable
{
    private const string ReadKey = "the-read-key";
    private const string WriteKey = "the-write-key";

    private readonly HomeBoardDbContext _context;
    private readonly User _ola;
    private readonly User _kari;
    private readonly User _per;
    private readonly Guid _bedMade;

    public IntegrationWriteTests()
    {
        _context = new HomeBoardDbContext(new DbContextOptionsBuilder<HomeBoardDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);
        _kari = AddUser("Kari", UserRole.Admin, new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc));
        _per = AddUser("Per", UserRole.Admin, new DateTime(2026, 2, 1, 0, 0, 0, DateTimeKind.Utc));
        _ola = AddUser("Ola", UserRole.User, new DateTime(2026, 3, 1, 0, 0, 0, DateTimeKind.Utc));
        _bedMade = Complete(_ola, "Make bed", points: 5);
        _context.SaveChanges();
    }

    public void Dispose() => _context.Dispose();

    [Theory]
    [InlineData(null, WriteKey, typeof(NotFoundResult))]
    [InlineData(WriteKey, "", typeof(UnauthorizedResult))]
    [InlineData(WriteKey, "wrong", typeof(UnauthorizedResult))]
    [InlineData(WriteKey, ReadKey, typeof(UnauthorizedResult))]
    public async Task Changes_NeedTheWriteKey(string? configuredWriteKey, string sentKey, Type expected)
    {
        var controller = Controller(sentKey, configuredWriteKey);

        Assert.IsType(expected, (await controller.ApproveChore(_bedMade, null)).Result);
        Assert.IsType(expected, (await controller.RejectChore(_bedMade, null)).Result);
        Assert.IsType(expected, (await controller.AwardBonusPoints(_ola.Id, new BonusPointsRequest { Points = 5 })).Result);
        Assert.Empty(_context.PointsLedger);
    }

    [Fact]
    public async Task TheWriteKeyCantRead()
    {
        Assert.IsType<UnauthorizedResult>((await Controller(WriteKey).GetPoints()).Result);
    }

    [Fact]
    public async Task Approve_GivesThePointsOnce()
    {
        var result = Ok<ReviewResponse>(await Controller(WriteKey).ApproveChore(_bedMade, null));
        Assert.Equal(("Make bed", "Ola", 5), (result.Title, result.CompletedBy, result.PointsAwarded));

        var completion = await _context.TaskCompletions.SingleAsync();
        Assert.Equal(TaskStatus.Verified, completion.Status);
        Assert.Equal(_kari.Id, completion.VerifiedByUserId);  // the first admin
        var entry = await _context.PointsLedger.SingleAsync();
        Assert.Equal((_ola.Id, 5, PointSourceType.TaskVerified, _bedMade, _kari.Id), (entry.UserId, entry.PointsDelta, entry.SourceType, entry.SourceId, entry.CreatedByUserId));

        var again = await Controller(WriteKey).ApproveChore(_bedMade, null);
        var conflict = Assert.IsType<ConflictObjectResult>(again.Result);
        Assert.Contains("'Make bed' by Ola was already approved or rejected", conflict.Value!.ToString());
        Assert.Single(_context.PointsLedger);
    }

    [Fact]
    public async Task Approve_WithOtherPoints()
    {
        var result = Ok<ReviewResponse>(await Controller(WriteKey).ApproveChore(_bedMade, new VerifyTaskRequest { PointsAwarded = 8 }));
        Assert.Equal(8, result.PointsAwarded);
        Assert.Equal(8, (await _context.PointsLedger.SingleAsync()).PointsDelta);

        var negative = await Controller(WriteKey).ApproveChore(Complete(_ola, "Feed the cat"), new VerifyTaskRequest { PointsAwarded = -1 });
        Assert.IsType<BadRequestObjectResult>(negative.Result);
    }

    [Fact]
    public async Task Approve_UnknownCompletion()
    {
        Assert.IsType<NotFoundObjectResult>((await Controller(WriteKey).ApproveChore(Guid.NewGuid(), null)).Result);
    }

    [Fact]
    public async Task Approve_RecordedUnderTheConfiguredParent()
    {
        Ok<ReviewResponse>(await Controller(WriteKey, actAs: "per").ApproveChore(_bedMade, null));
        Assert.Equal(_per.Id, (await _context.PointsLedger.SingleAsync()).CreatedByUserId);
    }

    [Theory]
    [InlineData("ola")]
    [InlineData("nobody")]
    public async Task Approve_RefusedWhenTheConfiguredParentIsNoAdmin(string actAs)
    {
        var result = await Controller(WriteKey, actAs: actAs).ApproveChore(_bedMade, null);
        var error = Assert.IsType<ObjectResult>(result.Result);
        Assert.Equal(StatusCodes.Status500InternalServerError, error.StatusCode);
        Assert.Empty(_context.PointsLedger);
    }

    [Fact]
    public async Task Reject_GivesNoPoints()
    {
        var result = Ok<ReviewResponse>(await Controller(WriteKey).RejectChore(_bedMade, new RejectTaskRequest { Reason = "Still unmade" }));
        Assert.Equal(("Make bed", 0), (result.Title, result.PointsAwarded));

        var completion = await _context.TaskCompletions.SingleAsync();
        Assert.Equal((TaskStatus.Rejected, "Still unmade"), (completion.Status, completion.RejectionReason));
        Assert.Empty(_context.PointsLedger);
        Assert.IsType<ConflictObjectResult>((await Controller(WriteKey).ApproveChore(_bedMade, null)).Result);
    }

    [Fact]
    public async Task Bonus_GoesToAChild()
    {
        var result = Ok<BonusResponse>(await Controller(WriteKey).AwardBonusPoints(_ola.Id,
            new BonusPointsRequest { Points = 15, Description = "Carried the shopping" }));
        Assert.Equal(("Ola", 15), (result.Name, result.PointsAwarded));

        var entry = await _context.PointsLedger.SingleAsync();
        Assert.Equal((_ola.Id, 15, PointSourceType.Bonus, "Carried the shopping", _kari.Id),
            (entry.UserId, entry.PointsDelta, entry.SourceType, entry.Note, entry.CreatedByUserId));
    }

    [Fact]
    public async Task Bonus_OnlyPositiveAndOnlyForChildren()
    {
        var controller = Controller(WriteKey);
        Assert.IsType<BadRequestObjectResult>((await controller.AwardBonusPoints(_ola.Id, new BonusPointsRequest { Points = 0 })).Result);
        Assert.IsType<BadRequestObjectResult>((await controller.AwardBonusPoints(_ola.Id, new BonusPointsRequest { Points = -5 })).Result);
        Assert.IsType<NotFoundObjectResult>((await controller.AwardBonusPoints(_kari.Id, new BonusPointsRequest { Points = 5 })).Result);
        Assert.IsType<NotFoundObjectResult>((await controller.AwardBonusPoints(Guid.NewGuid(), new BonusPointsRequest { Points = 5 })).Result);
        Assert.Empty(_context.PointsLedger);
    }

    [Fact]
    public async Task Points_TellWhatToApprove()
    {
        var points = Ok<PointsResponse>(await Controller(ReadKey).GetPoints());
        var ola = Assert.Single(points.Users);
        Assert.Equal(_ola.Id, ola.UserId);
        Assert.Equal(_bedMade, Assert.Single(ola.WaitingForApproval).CompletionId);
    }

    private static T Ok<T>(ActionResult<T> result) =>
        Assert.IsType<T>(Assert.IsType<OkObjectResult>(result.Result).Value);

    private IntegrationsController Controller(string sentKey, string? writeKey = WriteKey, string? actAs = null)
    {
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Integrations:ApiKey"] = ReadKey,
                ["Integrations:WriteApiKey"] = writeKey,
                ["Integrations:ActAsUser"] = actAs
            })
            .Build();
        var httpContext = new DefaultHttpContext();
        httpContext.Request.Headers[IntegrationsController.ApiKeyHeader] = sentKey;
        return new IntegrationsController(new TaskService(_context), new IntegrationService(_context), configuration)
        {
            ControllerContext = new ControllerContext { HttpContext = httpContext }
        };
    }

    private User AddUser(string name, UserRole role, DateTime createdAt)
    {
        var user = new User
        {
            Id = Guid.NewGuid(),
            Username = name.ToLowerInvariant(),
            DisplayName = name,
            PasswordHash = "hash",
            Role = role,
            IsActive = true,
            CreatedAt = createdAt
        };
        _context.Users.Add(user);
        return user;
    }

    private Guid Complete(User user, string title, int points = 10)
    {
        var definition = new TaskDefinition
        {
            Id = Guid.NewGuid(), Title = title, DefaultPoints = points, IsActive = true,
            CreatedByUserId = _kari.Id, CreatedAt = DateTime.UtcNow
        };
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(), TaskDefinitionId = definition.Id, TaskDefinition = definition, AssignedToUserId = user.Id,
            ScheduleType = ScheduleType.Daily, IsActive = true, CreatedAt = DateTime.UtcNow
        };
        var completion = new TaskCompletion
        {
            Id = Guid.NewGuid(), TaskAssignmentId = assignment.Id, Date = new DateOnly(2026, 10, 19),
            CompletedByUserId = user.Id, CompletedAt = DateTime.UtcNow, Status = TaskStatus.Completed
        };
        _context.TaskDefinitions.Add(definition);
        _context.TaskAssignments.Add(assignment);
        _context.TaskCompletions.Add(completion);
        _context.SaveChanges();
        return completion.Id;
    }
}
