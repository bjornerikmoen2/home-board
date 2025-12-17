namespace HomeBoard.Domain.Entities;

public class TaskDefinition
{
    public Guid Id { get; set; }
    public required string Title { get; set; }
    public string? Description { get; set; }
    public int DefaultPoints { get; set; }
    public bool IsActive { get; set; }
    public Guid CreatedByUserId { get; set; }
    public DateTime CreatedAt { get; set; }

    // Navigation properties
    public User? CreatedByUser { get; set; }
    public ICollection<TaskAssignment> Assignments { get; set; } = new List<TaskAssignment>();
}
