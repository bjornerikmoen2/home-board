using System.Net;
using System.Threading.RateLimiting;
using HomeBoard.Api.Controllers;
using HomeBoard.Api.Helpers;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Moq;

namespace HomeBoard.Tests.Services;

public class HardeningTests
{
    [Fact]
    public void ClientAddress_PrefersCloudflareThenTheLocalProxy()
    {
        Assert.Equal("203.0.113.7", HomeNetwork.ClientAddress(Request(new()
        {
            ["CF-Connecting-IP"] = "203.0.113.7",
            ["X-Forwarded-For"] = "198.51.100.1, 172.18.0.4"
        })));
        Assert.Equal("192.168.1.50", HomeNetwork.ClientAddress(Request(new()
        {
            ["X-Forwarded-For"] = "192.168.1.50, 172.18.0.6",
            ["X-Real-IP"] = "172.18.0.6"
        })));
        Assert.Equal("172.18.0.6", HomeNetwork.ClientAddress(Request(new() { ["X-Real-IP"] = "172.18.0.6" })));
        Assert.Equal("unknown", HomeNetwork.ClientAddress(Request(new() { ["X-Forwarded-For"] = "not-an-ip" })));

        var direct = Request(new());
        direct.HttpContext.Connection.RemoteIpAddress = IPAddress.Parse("10.0.0.9");
        Assert.Equal("10.0.0.9", HomeNetwork.ClientAddress(direct));
    }

    [Fact]
    public void LoginRateLimit_AllowsTenAttemptsPerMinutePerAddress()
    {
        using var limiter = PartitionedRateLimiter.Create<HttpContext, string>(LoginRateLimit.Partition);
        var attacker = Request(new() { ["CF-Connecting-IP"] = "203.0.113.7" }).HttpContext;
        var tablet = Request(new() { ["X-Forwarded-For"] = "192.168.1.50" }).HttpContext;

        for (var i = 0; i < LoginRateLimit.AttemptsPerMinute; i++)
        {
            Assert.True(limiter.AttemptAcquire(attacker).IsAcquired);
        }
        Assert.False(limiter.AttemptAcquire(attacker).IsAcquired);
        Assert.True(limiter.AttemptAcquire(tablet).IsAcquired);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("too-short-for-hs256")]
    public void JwtSigningKey_RefusesMissingOrShortKeys(string? key)
    {
        Assert.Throws<InvalidOperationException>(() => JwtSigningKey.Read(Configuration(key)));
    }

    [Fact]
    public void JwtSigningKey_AcceptsALongKey()
    {
        Assert.Equal(43, JwtSigningKey.Read(Configuration(new string('k', 43))).Length);
    }

    [Theory]
    [InlineData("2026-10-31", "2026-10-01")]
    [InlineData("2026-01-01", "2026-12-31")]
    public async Task Calendar_RefusesBadOrLongRanges(string start, string end)
    {
        var controller = new TasksController(Mock.Of<ITaskService>());
        var result = await controller.GetCalendarTasks(DateOnly.Parse(start), DateOnly.Parse(end));
        Assert.IsType<BadRequestObjectResult>(result.Result);
    }

    [Theory]
    [InlineData(0, typeof(BadRequestObjectResult))]
    [InlineData(-5, typeof(BadRequestObjectResult))]
    [InlineData(100000, typeof(BadRequestObjectResult))]
    [InlineData(30, typeof(OkObjectResult))]
    [InlineData(366, typeof(OkObjectResult))]
    public async Task Analytics_LimitsTheNumberOfDays(int days, Type expected)
    {
        var analytics = new Mock<IAnalyticsService>();
        analytics.Setup(a => a.GetAnalyticsAsync(It.IsAny<int>())).ReturnsAsync(new AnalyticsResponseModel());
        var result = await new AnalyticsController(analytics.Object).GetAnalytics(days);
        Assert.IsType(expected, result.Result);
    }

    private static IConfiguration Configuration(string? key) => new ConfigurationBuilder()
        .AddInMemoryCollection(new Dictionary<string, string?> { ["Jwt:SigningKey"] = key })
        .Build();

    private static HttpRequest Request(Dictionary<string, string> headers)
    {
        var context = new DefaultHttpContext();
        foreach (var (name, value) in headers)
        {
            context.Request.Headers[name] = value;
        }
        return context.Request;
    }
}
