using HomeBoard.Api.Controllers;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Moq;

namespace HomeBoard.Tests.Services;

public class RefreshTokenTests : IDisposable
{
    private static readonly Dictionary<string, string> FromInternet = new() { ["CF-Connecting-IP"] = "203.0.113.7" };
    private static readonly Dictionary<string, string> FromHome = new() { ["X-Forwarded-For"] = "192.168.1.50" };

    private readonly HomeBoardDbContext _context;
    private readonly FakeTime _time = new(new DateTimeOffset(2026, 10, 17, 18, 0, 0, TimeSpan.Zero));

    public RefreshTokenTests()
    {
        _context = new HomeBoardDbContext(new DbContextOptionsBuilder<HomeBoardDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options);
        AddUser("ola", UserRole.User, noPassword: true);
        AddUser("parent", UserRole.Admin, password: "parent-password");
        _context.SaveChanges();
    }

    public void Dispose() => _context.Dispose();

    [Fact]
    public async Task Login_StoresOnlyAHashOfTheRefreshToken()
    {
        var login = await LogIn("parent", "parent-password");

        var stored = await _context.RefreshTokens.SingleAsync();
        Assert.NotEqual(login.RefreshToken, stored.TokenHash);
        Assert.Equal(AuthService.Hash(login.RefreshToken), stored.TokenHash);
        Assert.False(stored.Passwordless);
        Assert.Equal(_time.GetUtcNow().UtcDateTime + AuthService.RefreshTokenLifetime, stored.ExpiresAt);
    }

    [Fact]
    public async Task Refresh_GivesNewTokensAndUsesTheOldOneUp()
    {
        var login = await LogIn("parent", "parent-password");

        var refreshed = await Refresh(login.RefreshToken);
        Assert.NotNull(refreshed);
        Assert.Equal("parent", refreshed.User.Username);
        Assert.NotEqual(login.RefreshToken, refreshed.RefreshToken);

        Assert.Null(await Refresh(login.RefreshToken));
        Assert.NotNull(await Refresh(refreshed.RefreshToken));
    }

    [Fact]
    public async Task Refresh_KeepsADeviceInDailyUseLoggedIn()
    {
        var token = (await LogIn("parent", "parent-password")).RefreshToken;
        for (var day = 0; day < 40; day++)
        {
            _time.Advance(TimeSpan.FromDays(1));
            token = (await Refresh(token))!.RefreshToken;
        }

        _time.Advance(AuthService.RefreshTokenLifetime);
        Assert.Null(await Refresh(token));
    }

    [Theory]
    [InlineData("")]
    [InlineData("not-a-token")]
    public async Task Refresh_RefusesUnknownTokens(string token)
    {
        Assert.Null(await Refresh(token));
    }

    [Fact]
    public async Task Logout_RevokesTheRefreshToken()
    {
        var login = await LogIn("parent", "parent-password");

        Assert.IsType<OkObjectResult>(await Controller(FromHome).Logout(new LogoutRequest { RefreshToken = login.RefreshToken }));

        Assert.Null(await Refresh(login.RefreshToken));
        Assert.NotNull((await _context.RefreshTokens.SingleAsync()).RevokedAt);
    }

    [Fact]
    public async Task Logout_WithoutABodyStillWorks()
    {
        Assert.IsType<OkObjectResult>(await Controller(FromHome).Logout(null));
        Assert.IsType<OkObjectResult>(await Controller(FromHome).Logout(new LogoutRequest { RefreshToken = "unknown" }));
    }

    [Fact]
    public async Task PasswordlessSessions_OnlyRefreshAtHome()
    {
        var login = await LogIn("ola", "", FromHome);
        Assert.True((await _context.RefreshTokens.SingleAsync()).Passwordless);

        Assert.Null(await Refresh(login.RefreshToken, FromInternet));
        // Refused, not used up: it still works back home.
        Assert.NotNull(await Refresh(login.RefreshToken, FromHome));
    }

    [Fact]
    public async Task PasswordlessSessions_EndWhenTheChildGetsAPassword()
    {
        var login = await LogIn("ola", "", FromHome);
        (await _context.Users.SingleAsync(u => u.Username == "ola")).NoPasswordRequired = false;
        await _context.SaveChangesAsync();

        Assert.Null(await Refresh(login.RefreshToken, FromHome));
    }

    [Fact]
    public async Task Sessions_EndWhenTheUserIsDeactivated()
    {
        var login = await LogIn("parent", "parent-password");
        (await _context.Users.SingleAsync(u => u.Username == "parent")).IsActive = false;
        await _context.SaveChangesAsync();

        Assert.Null(await Refresh(login.RefreshToken));
    }

    [Fact]
    public async Task PasswordReset_EndsAllSessions()
    {
        var phone = await LogIn("parent", "parent-password");
        var laptop = await LogIn("parent", "parent-password");
        var parent = await _context.Users.SingleAsync(u => u.Username == "parent");

        await new UserService(_context).ResetPasswordAsync(parent.Id, "new-password");

        Assert.Null(await Refresh(phone.RefreshToken));
        Assert.Null(await Refresh(laptop.RefreshToken));
    }

    [Fact]
    public async Task Login_CleansUpOldTokens()
    {
        var first = await LogIn("parent", "parent-password");
        await Controller(FromHome).Logout(new LogoutRequest { RefreshToken = first.RefreshToken });
        await LogIn("parent", "parent-password");

        Assert.Single(await _context.RefreshTokens.ToListAsync());
    }

    private async Task<LoginResponse> LogIn(string username, string password, Dictionary<string, string>? headers = null)
    {
        var result = await Controller(headers ?? FromHome).Login(new LoginRequest { Username = username, Password = password });
        return Assert.IsType<LoginResponse>(Assert.IsType<OkObjectResult>(result.Result).Value);
    }

    private async Task<LoginResponse?> Refresh(string token, Dictionary<string, string>? headers = null)
    {
        var result = await Controller(headers ?? FromHome).Refresh(new RefreshTokenRequest { RefreshToken = token });
        if (result.Result is UnauthorizedObjectResult)
        {
            return null;
        }
        return Assert.IsType<LoginResponse>(Assert.IsType<OkObjectResult>(result.Result).Value);
    }

    private AuthController Controller(Dictionary<string, string> headers)
    {
        var tokens = new Mock<ITokenService>();
        tokens.Setup(t => t.GenerateAccessToken(It.IsAny<User>())).Returns("access");
        var context = new DefaultHttpContext();
        foreach (var (name, value) in headers)
        {
            context.Request.Headers[name] = value;
        }
        return new AuthController(new AuthService(_context, _time), tokens.Object, new ConfigurationBuilder().Build())
        {
            ControllerContext = new ControllerContext { HttpContext = context }
        };
    }

    private void AddUser(string username, UserRole role, bool noPassword = false, string? password = null)
    {
        _context.Users.Add(new User
        {
            Id = Guid.NewGuid(),
            Username = username,
            DisplayName = username,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(password ?? Guid.NewGuid().ToString()),
            Role = role,
            IsActive = true,
            NoPasswordRequired = noPassword,
            CreatedAt = DateTime.UtcNow
        });
    }

    private sealed class FakeTime(DateTimeOffset now) : TimeProvider
    {
        private DateTimeOffset _now = now;
        public override DateTimeOffset GetUtcNow() => _now;
        public void Advance(TimeSpan by) => _now += by;
    }
}
