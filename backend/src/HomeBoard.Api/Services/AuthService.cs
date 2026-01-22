using HomeBoard.Api.Models;
using HomeBoard.Domain.Entities;
using HomeBoard.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Services;

public interface IAuthService
{
    Task<(User user, bool isValid)> ValidateUserCredentialsAsync(string username, string password);
    Task UpdateLastLoginAsync(Guid userId);
    Task<List<NoPasswordUserDto>> GetNoPasswordUsersAsync();
}

public class AuthService : IAuthService
{
    private readonly HomeBoardDbContext _context;

    public AuthService(HomeBoardDbContext context)
    {
        _context = context;
    }

    public async Task<(User user, bool isValid)> ValidateUserCredentialsAsync(string username, string password)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Username == username && u.IsActive);

        if (user == null)
        {
            return (null!, false);
        }

        // For users with no password required, allow login with empty password
        if (user.NoPasswordRequired)
        {
            if (string.IsNullOrEmpty(password))
            {
                return (user, true);
            }
            else
            {
                // If password provided, still verify it
                bool isValid = BCrypt.Net.BCrypt.Verify(password, user.PasswordHash);
                return (user, isValid);
            }
        }
        else
        {
            // Verify password using BCrypt
            bool isValid = BCrypt.Net.BCrypt.Verify(password, user.PasswordHash);
            return (user, isValid);
        }
    }

    public async Task UpdateLastLoginAsync(Guid userId)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user != null)
        {
            user.LastLoginAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }
    }

    public async Task<List<NoPasswordUserDto>> GetNoPasswordUsersAsync()
    {
        return await _context.Users
            .Where(u => u.IsActive && u.NoPasswordRequired)
            .Select(u => new NoPasswordUserDto
            {
                Id = u.Id,
                Username = u.Username,
                DisplayName = u.DisplayName,
                ProfileImageUrl = u.ProfileImage != null ? $"/api/users/{u.Id}/profile-image" : null
            })
            .ToListAsync();
    }
}
