namespace HomeBoard.Api.Models;

public class PayoutPreviewDto
{
    public Guid UserId { get; set; }
    public string DisplayName { get; set; } = string.Empty;
    public DateTime? LastPayoutAt { get; set; }
    public DateTime PeriodStart { get; set; }
    public DateTime PeriodEnd { get; set; }
    public int NetPointsSinceLastPayout { get; set; }
    public decimal PointToMoneyRate { get; set; }
    public decimal MoneyToPay { get; set; }
}

public class PayoutPreviewResponseDto
{
    public List<PayoutPreviewDto> UserPayouts { get; set; } = new();
    public decimal TotalMoneyToPay { get; set; }
    public decimal PointToMoneyRate { get; set; }
}

public class ExecutePayoutRequest
{
    public List<Guid>? UserIds { get; set; }
    public string? Note { get; set; }
}

public class PayoutDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string DisplayName { get; set; } = string.Empty;
    public DateTime PeriodStart { get; set; }
    public DateTime PeriodEnd { get; set; }
    public int NetPoints { get; set; }
    public decimal PointToMoneyRate { get; set; }
    public decimal MoneyPaid { get; set; }
    public DateTime PaidAt { get; set; }
    public string? Note { get; set; }
}

public class ExecutePayoutResponseDto
{
    public List<PayoutDto> Payouts { get; set; } = new();
    public decimal TotalMoneyPaid { get; set; }
    public int UsersProcessed { get; set; }
}
