using System.Net;
using HomeBoard.Api.Controllers;
using HomeBoard.Api.Helpers;
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

public class SecurityTests : IDisposable
{
    // What the API sees: through the Cloudflare Tunnel, and on the home network through the local proxy.
    private static readonly Dictionary<string, string> FromInternet = new()
    {
        ["CF-Connecting-IP"] = "203.0.113.7",
        ["X-Forwarded-For"] = "203.0.113.7, 172.18.0.4",
        ["X-Real-IP"] = "172.18.0.4"
    };
    private static readonly Dictionary<string, string> FromHome = new()
    {
        ["X-Forwarded-For"] = "192.168.1.50, 172.18.0.6",
        ["X-Real-IP"] = "172.18.0.6"
    };

    private readonly HomeBoardDbContext _context;

    public SecurityTests()
    {
        var options = new DbContextOptionsBuilder<HomeBoardDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new HomeBoardDbContext(options);
        AddUser("ola", UserRole.User, noPassword: true);
        AddUser("parent", UserRole.Admin, password: "parent-password");
        // An admin flagged as passwordless by older data must still need a password.
        AddUser("oldadmin", UserRole.Admin, noPassword: true);
        _context.SaveChanges();
    }

    public void Dispose() => _context.Dispose();

    [Theory]
    [InlineData("203.0.113.7", true)]
    [InlineData("8.8.8.8:443", true)]
    [InlineData("2001:4860:4860::8888", true)]
    [InlineData("[2001:4860:4860::8888]:443", true)]
    [InlineData("192.168.1.50", false)]
    [InlineData("10.0.0.3", false)]
    [InlineData("172.18.0.4", false)]
    [InlineData("100.101.102.103", false)]
    [InlineData("127.0.0.1", false)]
    [InlineData("fd12:3456::1", false)]
    [InlineData("fe80::1", false)]
    [InlineData("::ffff:192.168.1.5", false)]
    public void IsPublic(string address, bool expected)
    {
        var host = address.StartsWith('[') ? address[1..address.IndexOf(']')] : address.Count(c => c == ':') == 1 ? address.Split(':')[0] : address;
        Assert.Equal(expected, HomeNetwork.IsPublic(IPAddress.Parse(host)));
    }

    [Fact]
    public void IsFromInternet_LooksAtEveryAddress()
    {
        Assert.True(HomeNetwork.IsFromInternet(Request(FromInternet)));
        Assert.False(HomeNetwork.IsFromInternet(Request(FromHome)));
        Assert.False(HomeNetwork.IsFromInternet(Request(new())));
        var remote = Request(new());
        remote.HttpContext.Connection.RemoteIpAddress = IPAddress.Parse("198.51.100.20");
        Assert.True(HomeNetwork.IsFromInternet(remote));
    }

    [Fact]
    public async Task NoPasswordLogin_WorksAtHome()
    {
        var result = await Controller(FromHome).Login(new LoginRequest { Username = "ola", Password = "" });
        Assert.IsType<OkObjectResult>(result.Result);
    }

    [Fact]
    public async Task NoPasswordLogin_IsRefusedFromTheInternet()
    {
        var result = await Controller(FromInternet).Login(new LoginRequest { Username = "ola", Password = null });
        Assert.IsType<UnauthorizedObjectResult>(result.Result);
    }

    [Fact]
    public async Task NoPasswordLogin_FromTheInternetCanBeAllowed()
    {
        var result = await Controller(FromInternet, allowFromInternet: true).Login(new LoginRequest { Username = "ola" });
        Assert.IsType<OkObjectResult>(result.Result);
    }

    [Theory]
    [InlineData("oldadmin", "")]
    [InlineData("parent", "")]
    [InlineData("parent", null)]
    [InlineData("parent", "wrong")]
    public async Task Admins_AlwaysNeedTheirPassword(string username, string? password)
    {
        var result = await Controller(FromHome).Login(new LoginRequest { Username = username, Password = password });
        Assert.IsType<UnauthorizedObjectResult>(result.Result);
    }

    [Fact]
    public async Task PasswordLogin_StillWorksFromTheInternet()
    {
        var result = await Controller(FromInternet).Login(new LoginRequest { Username = "parent", Password = "parent-password" });
        Assert.IsType<OkObjectResult>(result.Result);
    }

    [Fact]
    public async Task NoPasswordUsers_OnlyChildrenAndOnlyAtHome()
    {
        var atHome = Assert.IsType<OkObjectResult>((await Controller(FromHome).GetNoPasswordUsers()).Result);
        Assert.Equal(new[] { "ola" }, Assert.IsType<List<NoPasswordUserDto>>(atHome.Value).Select(u => u.Username));

        var outside = Assert.IsType<OkObjectResult>((await Controller(FromInternet).GetNoPasswordUsers()).Result);
        Assert.Empty(Assert.IsType<List<NoPasswordUserDto>>(outside.Value));
    }

    [Fact]
    public async Task Admins_CannotBeMadePasswordless()
    {
        var users = new UserService(_context);
        await Assert.ThrowsAsync<InvalidOperationException>(() => users.CreateUserAsync(new CreateUserRequest
        {
            Username = "newparent", DisplayName = "New parent", Role = UserRole.Admin, NoPasswordRequired = true
        }));

        var parent = await _context.Users.SingleAsync(u => u.Username == "parent");
        await Assert.ThrowsAsync<InvalidOperationException>(() => users.UpdateUserAsync(parent.Id, new UpdateUserRequest { NoPasswordRequired = true }));
    }

    [Fact]
    public async Task Seeder_UsesTheConfiguredPasswordOrGeneratesOne()
    {
        var configured = NewContext();
        Assert.Null(await new DbSeeder(configured).SeedAsync("configured-secret"));
        Assert.True(BCrypt.Net.BCrypt.Verify("configured-secret", (await configured.Users.SingleAsync()).PasswordHash));

        var generated = NewContext();
        var password = await new DbSeeder(generated).SeedAsync(null);
        Assert.False(string.IsNullOrWhiteSpace(password));
        Assert.True(BCrypt.Net.BCrypt.Verify(password, (await generated.Users.SingleAsync()).PasswordHash));
        Assert.False(BCrypt.Net.BCrypt.Verify("Admin123!", (await generated.Users.SingleAsync()).PasswordHash));

        Assert.Null(await new DbSeeder(generated).SeedAsync(null));
    }

    private AuthController Controller(Dictionary<string, string> headers, bool allowFromInternet = false)
    {
        var tokens = new Mock<ITokenService>();
        tokens.Setup(t => t.GenerateAccessToken(It.IsAny<User>())).Returns("access");
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Auth:AllowNoPasswordLoginFromInternet"] = allowFromInternet ? "true" : null
            })
            .Build();
        return new AuthController(new AuthService(_context), tokens.Object, configuration)
        {
            ControllerContext = new ControllerContext { HttpContext = Request(headers).HttpContext }
        };
    }

    private static HttpRequest Request(Dictionary<string, string> headers)
    {
        var context = new DefaultHttpContext();
        foreach (var (name, value) in headers)
        {
            context.Request.Headers[name] = value;
        }
        return context.Request;
    }

    private static HomeBoardDbContext NewContext() => new(
        new DbContextOptionsBuilder<HomeBoardDbContext>().UseInMemoryDatabase(Guid.NewGuid().ToString()).Options);

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
}
