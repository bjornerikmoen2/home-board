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

    /// <summary>Set once the chore is done; what approving or rejecting it takes.</summary>
    public Guid? CompletionId { get; set; }
}

/// <summary>
/// Each child's points: what the scoreboard shows, what the next payout would be, what was earned
/// this week and month, and the done chores still waiting for a parent to approve them.
/// </summary>
public class PointsResponse
{
    public required string Timezone { get; set; }
    public DateOnly Today { get; set; }
    public decimal PointToMoneyRate { get; set; }
    public required List<ChildPointsDto> Users { get; set; }
}

public class ChildPointsDto
{
    public Guid UserId { get; set; }
    public required string Name { get; set; }

    /// <summary>All points minus those paid out, as on the scoreboard.</summary>
    public int ScoreboardPoints { get; set; }

    /// <summary>Net points since the last payout, and what paying them out would cost (as in the payout preview).</summary>
    public int PointsSinceLastPayout { get; set; }
    public decimal MoneyToPay { get; set; }
    public DateTime? LastPayoutAt { get; set; }

    /// <summary>Points earned (positive entries only) since the start of the family's week and month.</summary>
    public int EarnedThisWeek { get; set; }
    public int EarnedThisMonth { get; set; }

    /// <summary>Done chores a parent hasn't approved yet; their points count once approved.</summary>
    public required List<WaitingChoreDto> WaitingForApproval { get; set; }
}

public class WaitingChoreDto
{
    public Guid CompletionId { get; set; }
    public DateOnly Date { get; set; }
    public required string Title { get; set; }
    public int Points { get; set; }
    public DateTime CompletedAt { get; set; }
}

/// <summary>A done chore approved or rejected by another home service.</summary>
public class ReviewResponse
{
    public required string Message { get; set; }
    public required string Title { get; set; }
    public string? CompletedBy { get; set; }
    public int PointsAwarded { get; set; }
}

/// <summary>Bonus points given by another home service.</summary>
public class BonusResponse
{
    public required string Message { get; set; }
    public required string Name { get; set; }
    public int PointsAwarded { get; set; }
}
