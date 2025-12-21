using HomeBoard.Domain.Enums;

namespace HomeBoard.Domain.Entities;

public class User
{
    public Guid Id { get; set; }
    public required string Username { get; set; }
    public required string DisplayName { get; set; }
    public required string PasswordHash { get; set; }
    public UserRole Role { get; set; }
    public bool IsActive { get; set; }
    public string PreferredLanguage { get; set; } = "en";
    public byte[]? ProfileImage { get; set; }
    public string? ProfileImageContentType { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? LastLoginAt { get; set; }

    // Navigation properties
    public ICollection<TaskDefinition> CreatedTaskDefinitions { get; set; } = new List<TaskDefinition>();
    public ICollection<TaskAssignment> AssignedTasks { get; set; } = new List<TaskAssignment>();
    public ICollection<TaskCompletion> CompletedTasks { get; set; } = new List<TaskCompletion>();
    public ICollection<PointsLedger> PointsEntries { get; set; } = new List<PointsLedger>();
    public ICollection<RewardRedemption> RewardRedemptions { get; set; } = new List<RewardRedemption>();
}
