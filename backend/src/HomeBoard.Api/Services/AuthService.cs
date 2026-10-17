using System.Security.Cryptography;
using System.Text;
using HomeBoard.Api.Models;
using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Services;

public interface IAuthService
{
    /// <param name="allowNoPassword">Whether users marked NoPasswordRequired may log in with an
    /// empty password here (false for requests from the internet).</param>
    Task<(User user, bool isValid)> ValidateUserCredentialsAsync(string username, string? password, bool allowNoPassword = true);
    Task UpdateLastLoginAsync(Guid userId);
    Task<List<NoPasswordUserDto>> GetNoPasswordUsersAsync();

    /// <summary>A new refresh token for a user who just logged in.</summary>
    Task<string> IssueRefreshTokenAsync(Guid userId, bool passwordless);

    /// <summary>
    /// Swaps a valid refresh token for a new one (the old one stops working). Null when the token
    /// is unknown, expired, revoked or its user can no longer log in that way.
    /// </summary>
    /// <param name="allowNoPassword">As for login: false for requests from the internet.</param>
    Task<(User user, string refreshToken)?> RotateRefreshTokenAsync(string refreshToken, bool allowNoPassword = true);

    /// <summary>Logs a device out: its refresh token stops working. Unknown tokens are ignored.</summary>
    Task RevokeRefreshTokenAsync(string refreshToken);
}

public class AuthService : IAuthService
{
    /// <summary>
    /// How long a refresh token works; each refresh starts a new period, so a device in daily use
    /// stays logged in.
    /// </summary>
    public static readonly TimeSpan RefreshTokenLifetime = TimeSpan.FromDays(30);

    private readonly HomeBoardDbContext _context;
    private readonly TimeProvider _time;

    public AuthService(HomeBoardDbContext context, TimeProvider? timeProvider = null)
    {
        _context = context;
        _time = timeProvider ?? TimeProvider.System;
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
            return (user, CanLogInWithoutPassword(user, allowNoPassword));
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

    public async Task<string> IssueRefreshTokenAsync(Guid userId, bool passwordless)
    {
        var now = _time.GetUtcNow().UtcDateTime;

        // Expired and revoked tokens are of no use any more.
        var old = await _context.RefreshTokens
            .Where(t => t.UserId == userId && (t.ExpiresAt < now || t.RevokedAt != null))
            .ToListAsync();
        _context.RefreshTokens.RemoveRange(old);

        var token = WebEncoders.Base64UrlEncode(RandomNumberGenerator.GetBytes(32));
        _context.RefreshTokens.Add(new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TokenHash = Hash(token),
            Passwordless = passwordless,
            CreatedAt = now,
            ExpiresAt = now + RefreshTokenLifetime
        });
        await _context.SaveChangesAsync();
        return token;
    }

    public async Task<(User user, string refreshToken)?> RotateRefreshTokenAsync(string refreshToken, bool allowNoPassword = true)
    {
        var now = _time.GetUtcNow().UtcDateTime;
        var hash = Hash(refreshToken);
        var stored = await _context.RefreshTokens
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.TokenHash == hash);

        if (stored?.User == null || stored.RevokedAt != null || stored.ExpiresAt <= now || !stored.User.IsActive)
        {
            return null;
        }
        // The same rules as a passwordless login, checked again: the child may have been given a
        // password since, or the request may come from the internet.
        if (stored.Passwordless && !CanLogInWithoutPassword(stored.User, allowNoPassword))
        {
            return null;
        }

        stored.RevokedAt = now;
        var replacement = await IssueRefreshTokenAsync(stored.UserId, stored.Passwordless);
        return (stored.User, replacement);
    }

    public async Task RevokeRefreshTokenAsync(string refreshToken)
    {
        var hash = Hash(refreshToken);
        var stored = await _context.RefreshTokens.FirstOrDefaultAsync(t => t.TokenHash == hash);
        if (stored is { RevokedAt: null })
        {
            stored.RevokedAt = _time.GetUtcNow().UtcDateTime;
            await _context.SaveChangesAsync();
        }
    }

    /// <summary>
    /// Passwordless login is for children on the family tablet: never for admins, and only where
    /// the caller allows it (the home network, see AuthController).
    /// </summary>
    private static bool CanLogInWithoutPassword(User user, bool allowNoPassword) =>
        user.NoPasswordRequired && user.Role == UserRole.User && allowNoPassword;

    /// <summary>SHA-256 of the token as 64 hex digits, the form it is stored in.</summary>
    public static string Hash(string refreshToken) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(refreshToken)));
}
