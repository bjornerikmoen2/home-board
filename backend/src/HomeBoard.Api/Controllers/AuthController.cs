using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly HomeBoardDbContext _context;
    private readonly ITokenService _tokenService;

    public AuthController(HomeBoardDbContext context, ITokenService tokenService)
    {
        _context = context;
        _tokenService = tokenService;
    }

    [HttpPost("login")]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Username == request.Username && u.IsActive);

        if (user == null)
        {
            return Unauthorized(new { message = "Invalid username or password" });
        }

        // Verify password using BCrypt
        if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized(new { message = "Invalid username or password" });
        }

        // Update last login
        user.LastLoginAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        var accessToken = _tokenService.GenerateAccessToken(user);
        var refreshToken = _tokenService.GenerateRefreshToken();

        return Ok(new LoginResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken,
            User = new UserDto
            {
                Id = user.Id,
                Username = user.Username,
                DisplayName = user.DisplayName,
                Role = user.Role.ToString()
            }
        });
    }

    [HttpPost("refresh")]
    public async Task<ActionResult<LoginResponse>> Refresh([FromBody] RefreshTokenRequest request)
    {
        // In a production app, refresh tokens should be stored and validated
        // For now, we'll return Unauthorized
        return Unauthorized(new { message = "Refresh token functionality not fully implemented" });
    }

    [HttpPost("logout")]
    public IActionResult Logout()
    {
        // In a production app, invalidate the refresh token here
        return Ok(new { message = "Logged out successfully" });
    }
}
