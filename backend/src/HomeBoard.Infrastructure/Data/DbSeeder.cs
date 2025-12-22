using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Infrastructure.Data;

public class DbSeeder
{
    private readonly HomeBoardDbContext _context;

    public DbSeeder(HomeBoardDbContext context)
    {
        _context = context;
    }

    public async Task SeedAsync()
    {
        // Check if database has been seeded
        if (await _context.Users.AnyAsync())
        {
            return;
        }

        // Create default admin user
        // Password: Admin123!
        var adminUser = new User
        {
            Id = Guid.NewGuid(),
            Username = "admin",
            DisplayName = "Administrator",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin123!"),
            Role = UserRole.Admin,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _context.Users.Add(adminUser);

        // Create default family settings
        var familySettings = new FamilySettings
        {
            Id = Guid.NewGuid(),
            Timezone = "Europe/Oslo",
            PointToMoneyRate = 1m,
            WeekStartsOn = DayOfWeek.Monday
        };

        _context.FamilySettings.Add(familySettings);

        await _context.SaveChangesAsync();
    }
}
