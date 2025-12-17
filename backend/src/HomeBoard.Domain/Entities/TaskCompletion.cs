using HomeBoard.Domain.Enums;

namespace HomeBoard.Domain.Entities;

public class TaskCompletion
{
    public Guid Id { get; set; }
    public Guid TaskAssignmentId { get; set; }
    public DateOnly Date { get; set; }
    public Guid CompletedByUserId { get; set; }
    public DateTime CompletedAt { get; set; }
    public TaskStatus Status { get; set; }
    public Guid? VerifiedByUserId { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public string? RejectionReason { get; set; }

    // Navigation properties
    public TaskAssignment? TaskAssignment { get; set; }
    public User? CompletedByUser { get; set; }
    public User? VerifiedByUser { get; set; }
    public ICollection<PointsLedger> PointsEntries { get; set; } = new List<PointsLedger>();
}
