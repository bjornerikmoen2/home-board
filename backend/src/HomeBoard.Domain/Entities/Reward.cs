namespace HomeBoard.Domain.Entities;

public class Reward
{
    public Guid Id { get; set; }
    public required string Title { get; set; }
    public string? Description { get; set; }
    public int CostPoints { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }

    // Navigation properties
    public ICollection<RewardRedemption> Redemptions { get; set; } = new List<RewardRedemption>();
}
