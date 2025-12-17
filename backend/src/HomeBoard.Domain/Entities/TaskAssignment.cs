using HomeBoard.Domain.Enums;

namespace HomeBoard.Domain.Entities;

public class TaskAssignment
{
    public Guid Id { get; set; }
    public Guid TaskDefinitionId { get; set; }
    public Guid AssignedToUserId { get; set; }
    public ScheduleType ScheduleType { get; set; }
    public DayOfWeekFlag DaysOfWeek { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public TimeOnly? DueTime { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }

    // Navigation properties
    public TaskDefinition? TaskDefinition { get; set; }
    public User? AssignedToUser { get; set; }
    public ICollection<TaskCompletion> Completions { get; set; } = new List<TaskCompletion>();
}
