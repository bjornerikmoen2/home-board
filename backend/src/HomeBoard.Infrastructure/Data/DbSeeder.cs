using System.Security.Cryptography;
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

    /// <summary>
    /// Creates the first admin user ("admin") and the family settings in an empty database.
    /// The admin password is <paramref name="adminPassword"/> (setting Seed:AdminPassword) or, when
    /// that is empty, a random one. Returns the generated password so it can be shown once, or
    /// null when nothing was generated.
    /// </summary>
    public async Task<string?> SeedAsync(string? adminPassword = null)
    {
        // Check if database has been seeded
        if (await _context.Users.AnyAsync())
        {
            return null;
        }

        var generated = string.IsNullOrWhiteSpace(adminPassword)
            ? Convert.ToBase64String(RandomNumberGenerator.GetBytes(12))
            : null;

        // Create the first admin user
        var adminUser = new User
        {
            Id = Guid.NewGuid(),
            Username = "admin",
            DisplayName = "Administrator",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(generated ?? adminPassword),
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
        return generated;
    }
}
