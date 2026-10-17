namespace HomeBoard.Api.Models;

/// <summary>
/// Chores for a range of days, for other home services (e.g. a personal assistant) to read.
/// </summary>
public class ChoresResponse
{
    public required string Timezone { get; set; }
    public DateOnly Today { get; set; }
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public required List<ChoreDto> Chores { get; set; }
}

public class ChoreDto
{
    public DateOnly Date { get; set; }
    public Guid AssignmentId { get; set; }
    public required string Title { get; set; }
    public string? Description { get; set; }
    public int Points { get; set; }

    /// <summary>daily, weekly, once, during_week or during_month</summary>
    public required string Schedule { get; set; }

    public TimeOnly? DueTime { get; set; }

    /// <summary>Display name of the person the chore is assigned to; null for group chores.</summary>
    public string? AssignedTo { get; set; }

    /// <summary>"kids" or "parents" for a chore shared by everyone in that group.</summary>
    public string? AssignedToGroup { get; set; }

    /// <summary>todo, done (waiting for a parent to check it), verified or rejected</summary>
    public required string Status { get; set; }

    public string? CompletedBy { get; set; }
    public DateTime? CompletedAt { get; set; }
}
