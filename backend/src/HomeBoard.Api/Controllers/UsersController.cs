using HomeBoard.Api.Models;
using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class UsersController : ControllerBase
{
    private readonly HomeBoardDbContext _context;

    public UsersController(HomeBoardDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<List<UserDto>>> GetUsers()
    {
        var users = await _context.Users
            .Where(u => u.IsActive)
            .Select(u => new UserDto
            {
                Id = u.Id,
                Username = u.Username,
                DisplayName = u.DisplayName,
                Role = u.Role.ToString(),
                PreferredLanguage = u.PreferredLanguage,
                PrefersDarkMode = u.PrefersDarkMode,
                ProfileImageUrl = u.ProfileImage != null ? $"/api/users/{u.Id}/profile-image" : null
            })
            .ToListAsync();

        return Ok(users);
    }

    [HttpPost]
    public async Task<ActionResult<UserDto>> CreateUser([FromForm] CreateUserRequest request)
    {
        // Check if username already exists
        if (await _context.Users.AnyAsync(u => u.Username == request.Username))
        {
            return Conflict(new { message = "Username already exists" });
        }

        // Validate password requirements
        if (!request.NoPasswordRequired && string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { message = "Password is required when 'No Password Required' is not enabled" });
        }

        byte[]? profileImageData = null;
        string? contentType = null;
        
        if (request.ProfileImage != null)
        {
            // Validate image type
            var allowedTypes = new[] { "image/jpeg", "image/png", "image/gif", "image/webp" };
            if (!allowedTypes.Contains(request.ProfileImage.ContentType))
            {
                return BadRequest(new { message = "Invalid image type. Only JPEG, PNG, GIF, and WebP are allowed." });
            }
            
            // Validate size (max 5MB)
            if (request.ProfileImage.Length > 5 * 1024 * 1024)
            {
                return BadRequest(new { message = "Image size must be less than 5MB." });
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

        return CreatedAtAction(nameof(GetUsers), new { id = user.Id }, new UserDto
        {
            Id = user.Id,
            Username = user.Username,
            DisplayName = user.DisplayName,
            Role = user.Role.ToString(),
            PreferredLanguage = user.PreferredLanguage,
            PrefersDarkMode = user.PrefersDarkMode,
            ProfileImageUrl = user.ProfileImage != null ? $"/api/users/{user.Id}/profile-image" : null
        });
    }

    [HttpPatch("{id}")]
    public async Task<ActionResult<UserDto>> UpdateUser(Guid id, [FromForm] UpdateUserRequest request)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            return NotFound();
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
            if (user.Role == Domain.Enums.UserRole.Admin && request.Role.Value != Domain.Enums.UserRole.Admin)
            {
                var adminCount = await _context.Users.CountAsync(u => u.Role == Domain.Enums.UserRole.Admin && u.IsActive);
                if (adminCount <= 1)
                {
                    return BadRequest(new { message = "Cannot change the last admin's role" });
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
                return BadRequest(new { message = "Invalid image type. Only JPEG, PNG, GIF, and WebP are allowed." });
            }
            
            // Validate size (max 5MB)
            if (request.ProfileImage.Length > 5 * 1024 * 1024)
            {
                return BadRequest(new { message = "Image size must be less than 5MB." });
            }
            
            using var memoryStream = new MemoryStream();
            await request.ProfileImage.CopyToAsync(memoryStream);
            user.ProfileImage = memoryStream.ToArray();
            user.ProfileImageContentType = request.ProfileImage.ContentType;
        }

        await _context.SaveChangesAsync();

        return Ok(new UserDto
        {
            Id = user.Id,
            Username = user.Username,
            DisplayName = user.DisplayName,
            Role = user.Role.ToString(),
            PreferredLanguage = user.PreferredLanguage,
            PrefersDarkMode = user.PrefersDarkMode,
            ProfileImageUrl = user.ProfileImage != null ? $"/api/users/{user.Id}/profile-image" : null
        });
    }

    [HttpPost("{id}/reset-password")]
    public async Task<IActionResult> ResetPassword(Guid id, [FromBody] ResetPasswordRequest request)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            return NotFound();
        }

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Password reset successfully" });
    }

    [HttpPost("{id}/reset-points")]
    public async Task<IActionResult> ResetPoints(Guid id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            return NotFound();
        }

        // Get current user ID (the admin performing the reset)
        var adminUserId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(adminUserId))
        {
            return Unauthorized();
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
                CreatedByUserId = Guid.Parse(adminUserId),
                CreatedAt = DateTime.UtcNow
            };

            _context.PointsLedger.Add(adjustmentEntry);
            await _context.SaveChangesAsync();
        }

        return Ok(new { message = "Points reset successfully", pointsReset = currentPoints });
    }

    [HttpPost("{id}/bonus-points")]
    public async Task<IActionResult> AwardBonusPoints(Guid id, [FromBody] BonusPointsRequest request)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            return NotFound();
        }

        if (request.Points <= 0)
        {
            return BadRequest(new { message = "Points must be greater than zero" });
        }

        // Get current user ID (the admin awarding the bonus)
        var adminUserId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(adminUserId))
        {
            return Unauthorized();
        }

        // Create a bonus points entry
        var bonusEntry = new PointsLedger
        {
            Id = Guid.NewGuid(),
            UserId = id,
            SourceType = PointSourceType.Bonus,
            SourceId = null,
            PointsDelta = request.Points,
            Note = string.IsNullOrWhiteSpace(request.Description) ? "Bonus" : request.Description,
            CreatedByUserId = Guid.Parse(adminUserId),
            CreatedAt = DateTime.UtcNow
        };

        _context.PointsLedger.Add(bonusEntry);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Bonus points awarded successfully", pointsAwarded = request.Points });
    }

    [HttpGet("{id}/profile-image")]
    [AllowAnonymous]
    public async Task<IActionResult> GetProfileImage(Guid id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null || user.ProfileImage == null)
        {
            return NotFound();
        }

        return File(user.ProfileImage, user.ProfileImageContentType ?? "image/jpeg");
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUser(Guid id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            return NotFound();
        }

        // Prevent deleting the last admin
        if (user.Role == Domain.Enums.UserRole.Admin)
        {
            var adminCount = await _context.Users.CountAsync(u => u.Role == Domain.Enums.UserRole.Admin && u.IsActive);
            if (adminCount <= 1)
            {
                return BadRequest(new { message = "Cannot delete the last admin user" });
            }
        }

        // Soft delete - just mark as inactive
        user.IsActive = false;
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
