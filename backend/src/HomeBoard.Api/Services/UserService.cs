using HomeBoard.Api.Models;
using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Services;

public interface IUserService
{
    Task<List<UserDto>> GetUsersAsync();
    Task<UserDto> CreateUserAsync(CreateUserRequest request);
    Task<UserDto> UpdateUserAsync(Guid id, UpdateUserRequest request);
    Task ResetPasswordAsync(Guid id, string newPassword);
    Task<int> ResetPointsAsync(Guid id, Guid adminUserId);
    Task<int> AwardBonusPointsAsync(Guid id, int points, string? description, Guid adminUserId);
    Task<byte[]?> GetProfileImageAsync(Guid id);
    Task<string?> GetProfileImageContentTypeAsync(Guid id);
    Task DeleteUserAsync(Guid id);
}

public class UserService : IUserService
{
    private readonly HomeBoardDbContext _context;

    public UserService(HomeBoardDbContext context)
    {
        _context = context;
    }

    public async Task<List<UserDto>> GetUsersAsync()
    {
        return await _context.Users
            .Where(u => u.IsActive)
            .Select(u => new UserDto
            {
                Id = u.Id,
                Username = u.Username,
                DisplayName = u.DisplayName,
                Role = u.Role.ToString(),
                PreferredLanguage = u.PreferredLanguage,
                PrefersDarkMode = u.PrefersDarkMode,
                NoPasswordRequired = u.NoPasswordRequired,
                ProfileImageUrl = u.ProfileImage != null ? $"/api/users/{u.Id}/profile-image" : null
            })
            .ToListAsync();
    }

    public async Task<UserDto> CreateUserAsync(CreateUserRequest request)
    {
        // Check if username already exists
        if (await _context.Users.AnyAsync(u => u.Username == request.Username))
        {
            throw new InvalidOperationException("Username already exists");
        }

        // Validate password requirements
        if (!request.NoPasswordRequired && string.IsNullOrWhiteSpace(request.Password))
        {
            throw new InvalidOperationException("Password is required when 'No Password Required' is not enabled");
        }

        byte[]? profileImageData = null;
        string? contentType = null;
        
        if (request.ProfileImage != null)
        {
            // Validate image type
            var allowedTypes = new[] { "image/jpeg", "image/png", "image/gif", "image/webp" };
            if (!allowedTypes.Contains(request.ProfileImage.ContentType))
            {
                throw new InvalidOperationException("Invalid image type. Only JPEG, PNG, GIF, and WebP are allowed.");
            }
            
            // Validate size (max 5MB)
            if (request.ProfileImage.Length > 5 * 1024 * 1024)
            {
                throw new InvalidOperationException("Image size must be less than 5MB.");
            }
            
            using var memoryStream = new MemoryStream();
            await request.ProfileImage.CopyToAsync(memoryStream);
            profileImageData = memoryStream.ToArray();
            contentType = request.ProfileImage.ContentType;
        }

        // For no-password users, use a dummy hash (they won't use it)
        var passwordHash = request.NoPasswordRequired 
            ? BCrypt.Net.BCrypt.HashPassword(Guid.NewGuid().ToString()) 
            : BCrypt.Net.BCrypt.HashPassword(request.Password!);

        var user = new User
        {
            Id = Guid.NewGuid(),
            Username = request.Username,
            DisplayName = request.DisplayName,
            PasswordHash = passwordHash,
            Role = request.Role,
            NoPasswordRequired = request.NoPasswordRequired,
            PreferredLanguage = request.PreferredLanguage ?? "en",
            ProfileImage = profileImageData,
            ProfileImageContentType = contentType,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return new UserDto
        {
            Id = user.Id,
            Username = user.Username,
            DisplayName = user.DisplayName,
            Role = user.Role.ToString(),
            PreferredLanguage = user.PreferredLanguage,
            PrefersDarkMode = user.PrefersDarkMode,
            NoPasswordRequired = user.NoPasswordRequired,
            ProfileImageUrl = user.ProfileImage != null ? $"/api/users/{user.Id}/profile-image" : null
        };
    }

    public async Task<UserDto> UpdateUserAsync(Guid id, UpdateUserRequest request)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            throw new KeyNotFoundException($"User with ID {id} not found");
        }

        if (request.DisplayName != null)
        {
            user.DisplayName = request.DisplayName;
        }

        if (request.IsActive.HasValue)
        {
            user.IsActive = request.IsActive.Value;
        }

        if (request.Role.HasValue)
        {
            // Prevent changing the last admin's role
            if (user.Role == UserRole.Admin && request.Role.Value != UserRole.Admin)
            {
                var adminCount = await _context.Users.CountAsync(u => u.Role == UserRole.Admin && u.IsActive);
                if (adminCount <= 1)
                {
                    throw new InvalidOperationException("Cannot change the last admin's role");
                }
            }
            user.Role = request.Role.Value;
        }

        if (request.PreferredLanguage != null)
        {
            user.PreferredLanguage = request.PreferredLanguage;
        }

        if (request.PrefersDarkMode.HasValue)
        {
            user.PrefersDarkMode = request.PrefersDarkMode.Value;
        }

        if (request.NoPasswordRequired.HasValue)
        {
            user.NoPasswordRequired = request.NoPasswordRequired.Value;
        }
        
        if (request.RemoveProfileImage == true)
        {
            user.ProfileImage = null;
            user.ProfileImageContentType = null;
        }
        else if (request.ProfileImage != null)
        {
            // Validate image type
            var allowedTypes = new[] { "image/jpeg", "image/png", "image/gif", "image/webp" };
            if (!allowedTypes.Contains(request.ProfileImage.ContentType))
            {
                throw new InvalidOperationException("Invalid image type. Only JPEG, PNG, GIF, and WebP are allowed.");
            }
            
            // Validate size (max 5MB)
            if (request.ProfileImage.Length > 5 * 1024 * 1024)
            {
                throw new InvalidOperationException("Image size must be less than 5MB.");
            }
            
            using var memoryStream = new MemoryStream();
            await request.ProfileImage.CopyToAsync(memoryStream);
            user.ProfileImage = memoryStream.ToArray();
            user.ProfileImageContentType = request.ProfileImage.ContentType;
        }

        await _context.SaveChangesAsync();

        return new UserDto
        {
            Id = user.Id,
            Username = user.Username,
            DisplayName = user.DisplayName,
            Role = user.Role.ToString(),
            PreferredLanguage = user.PreferredLanguage,
            PrefersDarkMode = user.PrefersDarkMode,
            NoPasswordRequired = user.NoPasswordRequired,
            ProfileImageUrl = user.ProfileImage != null ? $"/api/users/{user.Id}/profile-image" : null
        };
    }

    public async Task ResetPasswordAsync(Guid id, string newPassword)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            throw new KeyNotFoundException($"User with ID {id} not found");
        }

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
        await _context.SaveChangesAsync();
    }

    public async Task<int> ResetPointsAsync(Guid id, Guid adminUserId)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            throw new KeyNotFoundException($"User with ID {id} not found");
        }

        // Get the user's current total points
        var currentPoints = await _context.PointsLedger
            .Where(p => p.UserId == id)
            .SumAsync(p => p.PointsDelta);

        // If user has points, create an adjustment entry to zero them out
        if (currentPoints != 0)
        {
            var adjustmentEntry = new PointsLedger
            {
                Id = Guid.NewGuid(),
                UserId = id,
                SourceType = PointSourceType.Adjustment,
                SourceId = null,
                PointsDelta = -currentPoints,
                Note = "Points reset by admin",
                CreatedByUserId = adminUserId,
                CreatedAt = DateTime.UtcNow
            };

            _context.PointsLedger.Add(adjustmentEntry);
            await _context.SaveChangesAsync();
        }

        return currentPoints;
    }

    public async Task<int> AwardBonusPointsAsync(Guid id, int points, string? description, Guid adminUserId)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            throw new KeyNotFoundException($"User with ID {id} not found");
        }

        if (points <= 0)
        {
            throw new InvalidOperationException("Points must be greater than zero");
        }

        // Create a bonus points entry
        var bonusEntry = new PointsLedger
        {
            Id = Guid.NewGuid(),
            UserId = id,
            SourceType = PointSourceType.Bonus,
            SourceId = null,
            PointsDelta = points,
            Note = string.IsNullOrWhiteSpace(description) ? "Bonus" : description,
            CreatedByUserId = adminUserId,
            CreatedAt = DateTime.UtcNow
        };

        _context.PointsLedger.Add(bonusEntry);
        await _context.SaveChangesAsync();

        return points;
    }

    public async Task<byte[]?> GetProfileImageAsync(Guid id)
    {
        var user = await _context.Users.FindAsync(id);
        return user?.ProfileImage;
    }

    public async Task<string?> GetProfileImageContentTypeAsync(Guid id)
    {
        var user = await _context.Users.FindAsync(id);
        return user?.ProfileImageContentType;
    }

    public async Task DeleteUserAsync(Guid id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            throw new KeyNotFoundException($"User with ID {id} not found");
        }

        // Prevent deleting the last admin
        if (user.Role == UserRole.Admin)
        {
            var adminCount = await _context.Users.CountAsync(u => u.Role == UserRole.Admin && u.IsActive);
            if (adminCount <= 1)
            {
                throw new InvalidOperationException("Cannot delete the last admin user");
            }
        }

        // Soft delete - just mark as inactive
        user.IsActive = false;
        await _context.SaveChangesAsync();
    }
}
