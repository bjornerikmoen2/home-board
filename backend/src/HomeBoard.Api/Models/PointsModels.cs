namespace HomeBoard.Api.Models;

public class LeaderboardEntryDto
{
    public Guid UserId { get; set; }
    public required string DisplayName { get; set; }
    public int TotalPoints { get; set; }
    public int Rank { get; set; }
}

public class UserPointsDto
{
    public Guid UserId { get; set; }
    public required string DisplayName { get; set; }
    public int TotalPoints { get; set; }
    public List<PointsEntryDto> RecentEntries { get; set; } = new();
}

public class PointsEntryDto
{
    public Guid Id { get; set; }
    public string SourceType { get; set; } = string.Empty;
    public int PointsDelta { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
}
