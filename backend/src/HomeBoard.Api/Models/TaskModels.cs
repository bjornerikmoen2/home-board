using HomeBoard.Domain.Enums;

namespace HomeBoard.Api.Models;

public class CreateTaskDefinitionRequest
{
    public required string Title { get; set; }
    public string? Description { get; set; }
    public int DefaultPoints { get; set; }
}

public class CreateTaskAssignmentRequest
{
    public Guid TaskDefinitionId { get; set; }
    public Guid AssignedToUserId { get; set; }
    public ScheduleType ScheduleType { get; set; }
    public DayOfWeekFlag DaysOfWeek { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public TimeOnly? DueTime { get; set; }
}

public class UpdateTaskAssignmentRequest
{
    public bool? IsActive { get; set; }
    public TimeOnly? DueTime { get; set; }
}

public class TaskDefinitionDto
{
    public Guid Id { get; set; }
    public required string Title { get; set; }
    public string? Description { get; set; }
    public int DefaultPoints { get; set; }
    public bool IsActive { get; set; }
}

public class TaskAssignmentDto
{
    public Guid Id { get; set; }
    public Guid TaskDefinitionId { get; set; }
    public required string TaskTitle { get; set; }
    public Guid AssignedToUserId { get; set; }
    public required string AssignedToName { get; set; }
    public ScheduleType ScheduleType { get; set; }
    public DayOfWeekFlag DaysOfWeek { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public TimeOnly? DueTime { get; set; }
    public bool IsActive { get; set; }
}

public class TodayTaskDto
{
    public Guid AssignmentId { get; set; }
    public required string Title { get; set; }
    public string? Description { get; set; }
    public int Points { get; set; }
    public TimeOnly? DueTime { get; set; }
    public bool IsCompleted { get; set; }
    public Guid? CompletionId { get; set; }
    public TaskStatus? Status { get; set; }
}
