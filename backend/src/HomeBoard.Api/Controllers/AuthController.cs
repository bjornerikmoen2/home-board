using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ITokenService _tokenService;

    public AuthController(IAuthService authService, ITokenService tokenService)
    {
        _authService = authService;
        _tokenService = tokenService;
    }

    [HttpPost("login")]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
    {
        var (user, isValid) = await _authService.ValidateUserCredentialsAsync(request.Username, request.Password!);

        if (!isValid)
        {
            return Unauthorized(new { message = "Invalid username or password" });
        }

        // Update last login
        await _authService.UpdateLastLoginAsync(user.Id);

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
                Role = user.Role.ToString(),
                PreferredLanguage = user.PreferredLanguage,
                PrefersDarkMode = user.PrefersDarkMode,
                ProfileImageUrl = user.ProfileImage != null ? $"/api/users/{user.Id}/profile-image" : null
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

    [HttpGet("no-password-users")]
    public async Task<ActionResult<List<NoPasswordUserDto>>> GetNoPasswordUsers()
    {
        var users = await _authService.GetNoPasswordUsersAsync();
        return Ok(users);
    }
}
