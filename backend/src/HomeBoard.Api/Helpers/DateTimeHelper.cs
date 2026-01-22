namespace HomeBoard.Api.Helpers;

public static class DateTimeHelper
{
    /// <summary>
    /// Gets the start of the week for a given date based on the configured week start day
    /// </summary>
    public static DateOnly GetStartOfWeek(DateOnly date, DayOfWeek weekStartsOn)
    {
        var currentDayOfWeek = (int)date.DayOfWeek;
        var targetStartDay = (int)weekStartsOn;
        
        // Calculate days to subtract to get to the start of the week
        var daysToSubtract = (currentDayOfWeek - targetStartDay + 7) % 7;
        return date.AddDays(-daysToSubtract);
    }

    /// <summary>
    /// Gets the end of the week for a given date based on the configured week start day
    /// </summary>
    public static DateOnly GetEndOfWeek(DateOnly date, DayOfWeek weekStartsOn)
    {
        return GetStartOfWeek(date, weekStartsOn).AddDays(6);
    }

    /// <summary>
    /// Gets the start of the month for a given date
    /// </summary>
    public static DateOnly GetStartOfMonth(DateOnly date)
    {
        return new DateOnly(date.Year, date.Month, 1);
    }

    /// <summary>
    /// Gets the end of the month for a given date
    /// </summary>
    public static DateOnly GetEndOfMonth(DateOnly date)
    {
        return GetStartOfMonth(date).AddMonths(1).AddDays(-1);
    }
}
