namespace HomeBoard.Domain.Entities;

public class Payout
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public DateTime PeriodStart { get; set; }
    public DateTime PeriodEnd { get; set; }
    public int NetPoints { get; set; }
    public decimal PointToMoneyRate { get; set; }
    public decimal MoneyPaid { get; set; }
    public Guid PaidByUserId { get; set; }
    public DateTime PaidAt { get; set; }
    public string? Note { get; set; }

    // Navigation properties
    public User? User { get; set; }
    public User? PaidByUser { get; set; }
}
