namespace HomeBoard.Api.Models;

public record ScoreboardResponseModel
{
    public required List<UserScoreboardModel> Users { get; init; }
    public required List<ScoreboardTaskModel> AllUsersTasks { get; init; }
    public bool AdminPrefersDarkMode { get; init; }
    public required string AdminPreferredLanguage { get; init; }
}

public record UserScoreboardModel
{
    public Guid Id { get; init; }
    public required string Name { get; init; }
    public int Points { get; init; }
    public required List<ScoreboardTaskModel> Tasks { get; init; }
    public string? ProfileImageUrl { get; init; }
}

public record ScoreboardTaskModel
{
    public Guid Id { get; init; }
    public required string Title { get; init; }
    public int Points { get; init; }
    public bool IsAllUsersTask { get; init; }
}
