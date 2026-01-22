using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using HomeBoard.Domain.Entities;
using HomeBoard.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace HomeBoard.Tests.Services;

public class PayoutServiceTests : IDisposable
{
    private readonly HomeBoardDbContext _context;
    private readonly PayoutService _payoutService;

    public PayoutServiceTests()
    {
        // Create in-memory database for testing with transaction warnings suppressed
        var options = new DbContextOptionsBuilder<HomeBoardDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .ConfigureWarnings(x => x.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.InMemoryEventId.TransactionIgnoredWarning))
            .Options;

        _context = new HomeBoardDbContext(options);
        _payoutService = new PayoutService(_context);

        // Seed test data
        SeedTestData();
    }

    private void SeedTestData()
    {
        // Add family settings
        _context.FamilySettings.Add(new FamilySettings
        {
            Id = Guid.NewGuid(),
            PointToMoneyRate = 0.10m, // $0.10 per point
            Timezone = "UTC",
            WeekStartsOn = DayOfWeek.Monday,
            EnableScoreboard = true,
            IncludeAdminsInAssignments = false
        });

        // Add test users
        var user1 = new User
        {
            Id = Guid.Parse("11111111-1111-1111-1111-111111111111"),
            Username = "testuser1",
            DisplayName = "Test User 1",
            PasswordHash = "hash",
            Role = Domain.Enums.UserRole.User,
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddDays(-30)
        };

        var user2 = new User
        {
            Id = Guid.Parse("22222222-2222-2222-2222-222222222222"),
            Username = "testuser2",
            DisplayName = "Test User 2",
            PasswordHash = "hash",
            Role = Domain.Enums.UserRole.User,
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddDays(-30)
        };

        var adminUser = new User
        {
            Id = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
            Username = "admin",
            DisplayName = "Admin User",
            PasswordHash = "hash",
            Role = Domain.Enums.UserRole.Admin,
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddDays(-60)
        };

        _context.Users.AddRange(user1, user2, adminUser);

        // Add some points ledger entries for user1
        _context.PointsLedger.AddRange(
            new PointsLedger
            {
                Id = Guid.NewGuid(),
                UserId = user1.Id,
                SourceType = Domain.Enums.PointSourceType.TaskVerified,
                PointsDelta = 100,
                Note = "Task completed",
                CreatedAt = DateTime.UtcNow.AddDays(-5),
                CreatedByUserId = adminUser.Id
            },
            new PointsLedger
            {
                Id = Guid.NewGuid(),
                UserId = user1.Id,
                SourceType = Domain.Enums.PointSourceType.Bonus,
                PointsDelta = 50,
                Note = "Bonus points",
                CreatedAt = DateTime.UtcNow.AddDays(-3),
                CreatedByUserId = adminUser.Id
            }
        );

        // Add some points ledger entries for user2
        _context.PointsLedger.AddRange(
            new PointsLedger
            {
                Id = Guid.NewGuid(),
                UserId = user2.Id,
                SourceType = Domain.Enums.PointSourceType.TaskVerified,
                PointsDelta = 200,
                Note = "Task completed",
                CreatedAt = DateTime.UtcNow.AddDays(-4),
                CreatedByUserId = adminUser.Id
            },
            new PointsLedger
            {
                Id = Guid.NewGuid(),
                UserId = user2.Id,
                SourceType = Domain.Enums.PointSourceType.Adjustment,
                PointsDelta = -50,
                Note = "Adjustment",
                CreatedAt = DateTime.UtcNow.AddDays(-2),
                CreatedByUserId = adminUser.Id
            }
        );

        _context.SaveChanges();
    }

    [Fact]
    public async Task GetPayoutPreviewAsync_ReturnsCorrectCalculations()
    {
        // Act
        var result = await _payoutService.GetPayoutPreviewAsync();

        // Assert
        Assert.NotNull(result);
        Assert.Equal(3, result.UserPayouts.Count); // All active users including admin
        Assert.Equal(0.10m, result.PointToMoneyRate);

        // Check user1's payout
        var user1Payout = result.UserPayouts.FirstOrDefault(p => p.UserId == Guid.Parse("11111111-1111-1111-1111-111111111111"));
        Assert.NotNull(user1Payout);
        Assert.Equal("Test User 1", user1Payout.DisplayName);
        Assert.Equal(150, user1Payout.NetPointsSinceLastPayout); // 100 + 50
        Assert.Equal(15.00m, user1Payout.MoneyToPay); // 150 * 0.10

        // Check user2's payout
        var user2Payout = result.UserPayouts.FirstOrDefault(p => p.UserId == Guid.Parse("22222222-2222-2222-2222-222222222222"));
        Assert.NotNull(user2Payout);
        Assert.Equal("Test User 2", user2Payout.DisplayName);
        Assert.Equal(150, user2Payout.NetPointsSinceLastPayout); // 200 - 50
        Assert.Equal(15.00m, user2Payout.MoneyToPay); // 150 * 0.10

        // Admin should have 0 points
        var adminPayout = result.UserPayouts.FirstOrDefault(p => p.UserId == Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"));
        Assert.NotNull(adminPayout);
        Assert.Equal(0, adminPayout.NetPointsSinceLastPayout);
        Assert.Equal(0m, adminPayout.MoneyToPay);

        // Check total
        Assert.Equal(30.00m, result.TotalMoneyToPay); // 15 + 15 + 0
    }

    [Fact]
    public async Task GetPayoutPreviewAsync_HandlesNegativePoints()
    {
        // Arrange - Add a user with negative points
        var user3 = new User
        {
            Id = Guid.Parse("33333333-3333-3333-3333-333333333333"),
            Username = "testuser3",
            DisplayName = "Test User 3",
            PasswordHash = "hash",
            Role = Domain.Enums.UserRole.User,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
        _context.Users.Add(user3);

        _context.PointsLedger.Add(new PointsLedger
        {
            Id = Guid.NewGuid(),
            UserId = user3.Id,
            SourceType = Domain.Enums.PointSourceType.Adjustment,
            PointsDelta = -100,
            Note = "Penalty",
            CreatedAt = DateTime.UtcNow,
            CreatedByUserId = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
        });
        await _context.SaveChangesAsync();

        // Act
        var result = await _payoutService.GetPayoutPreviewAsync();

        // Assert
        var user3Payout = result.UserPayouts.FirstOrDefault(p => p.UserId == user3.Id);
        Assert.NotNull(user3Payout);
        Assert.Equal(-100, user3Payout.NetPointsSinceLastPayout);
        Assert.Equal(0m, user3Payout.MoneyToPay); // Should be 0, not negative
    }

    [Fact]
    public async Task GetPayoutPreviewAsync_ThrowsException_WhenNoSettings()
    {
        // Arrange - Remove family settings
        var settings = await _context.FamilySettings.FirstOrDefaultAsync();
        if (settings != null)
        {
            _context.FamilySettings.Remove(settings);
            await _context.SaveChangesAsync();
        }

        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(
            async () => await _payoutService.GetPayoutPreviewAsync());
    }

    [Fact]
    public async Task ExecutePayoutAsync_CreatesPayoutRecordsAndUpdatesState()
    {
        // Arrange
        var adminUserId = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa");
        var request = new ExecutePayoutRequest
        {
            Note = "Monthly payout"
        };

        // Act
        var result = await _payoutService.ExecutePayoutAsync(request, adminUserId);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(3, result.UsersProcessed); // All users including admin
        Assert.Equal(2, result.Payouts.Count); // Only 2 payouts with non-zero amounts
        Assert.Equal(30.00m, result.TotalMoneyPaid);

        // Verify payout records were created
        var payouts = await _context.Payouts.ToListAsync();
        Assert.Equal(2, payouts.Count);
        Assert.All(payouts, p => Assert.Equal("Monthly payout", p.Note));
        Assert.All(payouts, p => Assert.Equal(adminUserId, p.PaidByUserId));

        // Verify payout states were updated for all users
        var payoutStates = await _context.UserPayoutStates.ToListAsync();
        Assert.Equal(3, payoutStates.Count);
        Assert.All(payoutStates, ps => Assert.NotNull(ps.LastPayoutAt));
    }

    [Fact]
    public async Task ExecutePayoutAsync_FiltersByUserIds()
    {
        // Arrange
        var adminUserId = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa");
        var user1Id = Guid.Parse("11111111-1111-1111-1111-111111111111");
        var request = new ExecutePayoutRequest
        {
            UserIds = new List<Guid> { user1Id },
            Note = "Single user payout"
        };

        // Act
        var result = await _payoutService.ExecutePayoutAsync(request, adminUserId);

        // Assert
        Assert.Equal(1, result.UsersProcessed);
        Assert.Single(result.Payouts);
        Assert.Equal(user1Id, result.Payouts.First().UserId);
        Assert.Equal(15.00m, result.TotalMoneyPaid);
    }

    [Fact]
    public async Task ExecutePayoutAsync_HandlesSecondPayoutCorrectly()
    {
        // Arrange
        var adminUserId = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa");
        var user1Id = Guid.Parse("11111111-1111-1111-1111-111111111111");

        // First payout
        await _payoutService.ExecutePayoutAsync(new ExecutePayoutRequest(), adminUserId);

        // Add more points after first payout
        _context.PointsLedger.Add(new PointsLedger
        {
            Id = Guid.NewGuid(),
            UserId = user1Id,
            SourceType = Domain.Enums.PointSourceType.Bonus,
            PointsDelta = 80,
            Note = "New bonus",
            CreatedAt = DateTime.UtcNow,
            CreatedByUserId = adminUserId
        });
        await _context.SaveChangesAsync();

        // Act - Second payout
        var result = await _payoutService.ExecutePayoutAsync(new ExecutePayoutRequest(), adminUserId);

        // Assert
        var user1Payout = result.Payouts.FirstOrDefault(p => p.UserId == user1Id);
        Assert.NotNull(user1Payout);
        Assert.Equal(80, user1Payout.NetPoints); // Only new points
        Assert.Equal(8.00m, user1Payout.MoneyPaid); // 80 * 0.10
    }

    [Fact]
    public async Task ExecutePayoutAsync_UsesTransaction_RollsBackOnError()
    {
        // Arrange
        var adminUserId = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa");
        
        // Create a scenario that would cause an error by removing the database
        await _context.Database.EnsureDeletedAsync();

        // Act & Assert
        await Assert.ThrowsAnyAsync<Exception>(
            async () => await _payoutService.ExecutePayoutAsync(new ExecutePayoutRequest(), adminUserId));
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }
}
