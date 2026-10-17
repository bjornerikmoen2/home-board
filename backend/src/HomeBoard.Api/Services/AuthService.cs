using HomeBoard.Api.Models;
using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Services;

public interface IAuthService
{
    /// <param name="allowNoPassword">Whether users marked NoPasswordRequired may log in with an
    /// empty password here (false for requests from the internet).</param>
    Task<(User user, bool isValid)> ValidateUserCredentialsAsync(string username, string? password, bool allowNoPassword = true);
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

    public async Task<(User user, bool isValid)> ValidateUserCredentialsAsync(string username, string? password, bool allowNoPassword = true)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Username == username && u.IsActive);

        if (user == null)
        {
            return (null!, false);
        }

        if (string.IsNullOrEmpty(password))
        {
            // Passwordless login is for children on the family tablet: never for admins, and
            // only where the caller allows it (the home network, see AuthController).
            var noPasswordOk = user.NoPasswordRequired && user.Role == UserRole.User && allowNoPassword;
            return (user, noPasswordOk);
        }

        // Verify password using BCrypt
        bool isValid = BCrypt.Net.BCrypt.Verify(password, user.PasswordHash);
        return (user, isValid);
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
            .Where(u => u.IsActive && u.NoPasswordRequired && u.Role == UserRole.User)
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
