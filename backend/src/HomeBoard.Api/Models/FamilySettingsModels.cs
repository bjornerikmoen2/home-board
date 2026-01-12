namespace HomeBoard.Api.Models;

public record FamilySettingsResponseModel
{
    public Guid Id { get; init; }
    public required string Timezone { get; init; }
    public decimal PointToMoneyRate { get; init; }
    public DayOfWeek WeekStartsOn { get; init; }
    public bool IncludeAdminsInAssignments { get; init; }
}

public record UpdateFamilySettingsRequestModel
{
    public string? Timezone { get; init; }
    public decimal? PointToMoneyRate { get; init; }
    public DayOfWeek? WeekStartsOn { get; init; }
    public bool? IncludeAdminsInAssignments { get; init; }
}
