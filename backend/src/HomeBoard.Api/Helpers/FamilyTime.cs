namespace HomeBoard.Api.Helpers;

/// <summary>
/// The family's local clock. Which day a chore belongs to, and when a week or month starts, follow
/// the family's timezone (FamilySettings.Timezone), not UTC: just after midnight in Norway it is
/// still yesterday in UTC. Timestamps such as CompletedAt stay in UTC.
/// </summary>
public static class FamilyTime
{
    /// <summary>The family's local date and time at <paramref name="utcNow"/>.</summary>
    public static DateTime LocalNow(string? timezone, DateTimeOffset utcNow)
    {
        return TimeZoneInfo.ConvertTime(utcNow, Zone(timezone)).DateTime;
    }

    /// <summary>The family's local date at <paramref name="utcNow"/>.</summary>
    public static DateOnly Today(string? timezone, DateTimeOffset utcNow)
    {
        return DateOnly.FromDateTime(LocalNow(timezone, utcNow));
    }

    /// <summary>The UTC moment a local date starts, for comparing with UTC timestamps.</summary>
    public static DateTime StartOfDayUtc(DateOnly date, string? timezone)
    {
        var localMidnight = DateTime.SpecifyKind(date.ToDateTime(TimeOnly.MinValue), DateTimeKind.Unspecified);
        return TimeZoneInfo.ConvertTimeToUtc(localMidnight, Zone(timezone));
    }

    /// <summary>The timezone, or UTC when it is missing or unknown.</summary>
    public static TimeZoneInfo Zone(string? timezone)
    {
        if (string.IsNullOrWhiteSpace(timezone))
        {
            return TimeZoneInfo.Utc;
        }
        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById(timezone);
        }
        catch (Exception ex) when (ex is TimeZoneNotFoundException or InvalidTimeZoneException)
        {
            return TimeZoneInfo.Utc;
        }
    }
}
