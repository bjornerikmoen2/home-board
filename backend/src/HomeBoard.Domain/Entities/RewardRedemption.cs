using HomeBoard.Domain.Enums;

namespace HomeBoard.Domain.Entities;

public class RewardRedemption
{
    public Guid Id { get; set; }
    public Guid RewardId { get; set; }
    public Guid UserId { get; set; }
    public DateTime RedeemedAt { get; set; }
    public RedemptionStatus Status { get; set; }
    public Guid? HandledByUserId { get; set; }
    public DateTime? HandledAt { get; set; }

    // Navigation properties
    public Reward? Reward { get; set; }
    public User? User { get; set; }
    public User? HandledByUser { get; set; }
}
