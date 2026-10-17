using HomeBoard.Api.Helpers;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using HomeBoard.Domain.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.RateLimiting;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ITokenService _tokenService;
    private readonly bool _noPasswordFromInternet;

    public AuthController(IAuthService authService, ITokenService tokenService, IConfiguration configuration)
    {
        _authService = authService;
        _tokenService = tokenService;
        // Passwordless login (the kids on the family tablet) only works on the home network,
        // unless this setting allows it from the internet too.
        _noPasswordFromInternet = configuration.GetValue("Auth:AllowNoPasswordLoginFromInternet", false);
    }

    private bool NoPasswordAllowed => _noPasswordFromInternet || !HomeNetwork.IsFromInternet(Request);

    [HttpPost("login")]
    [EnableRateLimiting(LoginRateLimit.Policy)]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
    {
        var (user, isValid) = await _authService.ValidateUserCredentialsAsync(request.Username, request.Password, NoPasswordAllowed);

        if (!isValid)
        {
            return Unauthorized(new { message = "Invalid username or password" });
        }

        // Update last login
        await _authService.UpdateLastLoginAsync(user.Id);

        var refreshToken = await _authService.IssueRefreshTokenAsync(user.Id, passwordless: string.IsNullOrEmpty(request.Password));
        return Ok(Tokens(user, refreshToken));
    }

    /// <summary>
    /// A new access token for an expired one. The refresh token is used up: the response has the
    /// one to use next time.
    /// </summary>
    [HttpPost("refresh")]
    public async Task<ActionResult<LoginResponse>> Refresh([FromBody] RefreshTokenRequest request)
    {
        var rotated = await _authService.RotateRefreshTokenAsync(request.RefreshToken, NoPasswordAllowed);
        if (rotated is not var (user, refreshToken))
        {
            return Unauthorized(new { message = "Invalid or expired refresh token" });
        }
        return Ok(Tokens(user, refreshToken));
    }

    /// <summary>
    /// Ends the session on this device: its refresh token stops working. The access token runs
    /// out on its own within the hour.
    /// </summary>
    [HttpPost("logout")]
    public async Task<IActionResult> Logout([FromBody(EmptyBodyBehavior = EmptyBodyBehavior.Allow)] LogoutRequest? request)
    {
        if (!string.IsNullOrEmpty(request?.RefreshToken))
        {
            await _authService.RevokeRefreshTokenAsync(request.RefreshToken);
        }
        return Ok(new { message = "Logged out successfully" });
    }

    /// <summary>
    /// The users who can log in without a password, for the tablet's login screen. Empty for
    /// requests from the internet, where passwordless login is refused.
    /// </summary>
    [HttpGet("no-password-users")]
    public async Task<ActionResult<List<NoPasswordUserDto>>> GetNoPasswordUsers()
    {
        if (!NoPasswordAllowed)
        {
            return Ok(new List<NoPasswordUserDto>());
        }
        var users = await _authService.GetNoPasswordUsersAsync();
        return Ok(users);
    }

    private LoginResponse Tokens(User user, string refreshToken) => new()
    {
        AccessToken = _tokenService.GenerateAccessToken(user),
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
    };
}
