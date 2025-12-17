using HomeBoard.Domain.Enums;

namespace HomeBoard.Api.Models;

public class VerifyTaskRequest
{
    public int? PointsAwarded { get; set; }
}

public class RejectTaskRequest
{
    public required string Reason { get; set; }
}

public class PendingVerificationDto
{
    public Guid CompletionId { get; set; }
    public DateOnly Date { get; set; }
    public required string TaskTitle { get; set; }
    public required string CompletedByName { get; set; }
    public Guid CompletedByUserId { get; set; }
    public DateTime CompletedAt { get; set; }
    public int DefaultPoints { get; set; }
}
