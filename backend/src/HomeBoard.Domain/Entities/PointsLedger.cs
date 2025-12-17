using HomeBoard.Domain.Enums;

namespace HomeBoard.Domain.Entities;

public class PointsLedger
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public PointSourceType SourceType { get; set; }
    public Guid? SourceId { get; set; }
    public int PointsDelta { get; set; }
    public string? Note { get; set; }
    public Guid CreatedByUserId { get; set; }
    public DateTime CreatedAt { get; set; }

    // Navigation properties
    public User? User { get; set; }
    public User? CreatedByUser { get; set; }
}
