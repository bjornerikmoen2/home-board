namespace HomeBoard.Domain.Entities;

public class FamilySettings
{
    public Guid Id { get; set; }
    public required string Timezone { get; set; }
    public decimal PointToMoneyRate { get; set; }
    public DayOfWeek WeekStartsOn { get; set; }
    public bool EnableScoreboard { get; set; }
    public bool IncludeAdminsInAssignments { get; set; }
}
