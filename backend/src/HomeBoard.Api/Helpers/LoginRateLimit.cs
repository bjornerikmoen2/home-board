using System.Threading.RateLimiting;

namespace HomeBoard.Api.Helpers;

/// <summary>
/// Limits login attempts per client address, so passwords can't be guessed quickly from the
/// internet (and each attempt's bcrypt check can't be used to load the server).
/// </summary>
public static class LoginRateLimit
{
    public const string Policy = "login";
    public const int AttemptsPerMinute = 10;

    public static RateLimitPartition<string> Partition(HttpContext context)
    {
        return RateLimitPartition.GetFixedWindowLimiter(
            HomeNetwork.ClientAddress(context.Request),
            _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = AttemptsPerMinute,
                Window = TimeSpan.FromMinutes(1),
                QueueLimit = 0
            });
    }
}
