namespace HomeBoard.Api.Models;

public class AnalyticsResponseModel
{
    public List<CompletionRateDataPoint> CompletionRates { get; set; } = new();
    public PointsAnalytics PointsAnalytics { get; set; } = new();
}

public class CompletionRateDataPoint
{
    public DateTime Date { get; set; }
    public int TotalTasks { get; set; }
    public int CompletedTasks { get; set; }
    public decimal CompletionRate { get; set; }
}

public class PointsAnalytics
{
    public List<PointsDataPoint> PointsEarned { get; set; } = new();
    public List<PointsDataPoint> PointsRedeemed { get; set; } = new();
    public int TotalEarned { get; set; }
    public int TotalRedeemed { get; set; }
    public int CurrentBalance { get; set; }
}

public class PointsDataPoint
{
    public DateTime Date { get; set; }
    public int Amount { get; set; }
}
