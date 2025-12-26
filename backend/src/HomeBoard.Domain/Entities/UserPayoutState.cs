namespace HomeBoard.Domain.Entities;

public class UserPayoutState
{
    public Guid UserId { get; set; }
    public DateTime? LastPayoutAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    // Navigation property
    public User? User { get; set; }
}
