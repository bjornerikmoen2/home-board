using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Services;

public enum ReviewOutcome
{
    Done,
    NotFound,
    /// <summary>Already verified or rejected.</summary>
    AlreadyReviewed,
    /// <summary>Points were already given for this completion.</summary>
    AlreadyAwarded
}

/// <param name="Title">The chore's title.</param>
/// <param name="CompletedBy">Display name of the person who did it.</param>
public record ReviewResult(ReviewOutcome Outcome, int PointsAwarded = 0, string? Title = null, string? CompletedBy = null);

public interface IVerificationService
{
    /// <summary>Approves a done chore and gives its points (or <paramref name="points"/>) to the person who did it.</summary>
    Task<ReviewResult> VerifyAsync(Guid completionId, Guid adminUserId, int? points = null);

    /// <summary>Rejects a done chore: no points.</summary>
    Task<ReviewResult> RejectAsync(Guid completionId, Guid adminUserId, string? reason);
}

/// <summary>
/// A parent's review of done chores, from the verification queue or from another home service
/// (see IntegrationsController).
/// </summary>
public class VerificationService : IVerificationService
{
    private readonly HomeBoardDbContext _context;

    public VerificationService(HomeBoardDbContext context)
    {
        _context = context;
    }

    public async Task<ReviewResult> VerifyAsync(Guid completionId, Guid adminUserId, int? points = null)
    {
        var completion = await Find(completionId);
        if (completion == null)
        {
            return new ReviewResult(ReviewOutcome.NotFound);
        }
        var title = completion.TaskAssignment!.TaskDefinition!.Title;
        var completedBy = completion.CompletedByUser?.DisplayName;

        if (completion.Status != Domain.Enums.TaskStatus.Completed)
        {
            return new ReviewResult(ReviewOutcome.AlreadyReviewed, Title: title, CompletedBy: completedBy);
        }

        // Idempotency check: ensure no points have been awarded for this completion
        var existingPoints = await _context.PointsLedger
            .AnyAsync(p => p.SourceType == PointSourceType.TaskVerified && p.SourceId == completionId);
        if (existingPoints)
        {
            return new ReviewResult(ReviewOutcome.AlreadyAwarded, Title: title, CompletedBy: completedBy);
        }

        var now = DateTime.UtcNow;
        completion.Status = Domain.Enums.TaskStatus.Verified;
        completion.VerifiedByUserId = adminUserId;
        completion.VerifiedAt = now;

        var pointsToAward = points ?? completion.TaskAssignment.TaskDefinition.DefaultPoints;
        _context.PointsLedger.Add(new PointsLedger
        {
            Id = Guid.NewGuid(),
            UserId = completion.CompletedByUserId,
            SourceType = PointSourceType.TaskVerified,
            SourceId = completionId,
            PointsDelta = pointsToAward,
            Note = $"Verified: {title}",
            CreatedByUserId = adminUserId,
            CreatedAt = now
        });

        await _context.SaveChangesAsync();
        return new ReviewResult(ReviewOutcome.Done, pointsToAward, title, completedBy);
    }

    public async Task<ReviewResult> RejectAsync(Guid completionId, Guid adminUserId, string? reason)
    {
        var completion = await Find(completionId);
        if (completion == null)
        {
            return new ReviewResult(ReviewOutcome.NotFound);
        }
        var title = completion.TaskAssignment!.TaskDefinition!.Title;
        var completedBy = completion.CompletedByUser?.DisplayName;

        if (completion.Status != Domain.Enums.TaskStatus.Completed)
        {
            return new ReviewResult(ReviewOutcome.AlreadyReviewed, Title: title, CompletedBy: completedBy);
        }

        completion.Status = Domain.Enums.TaskStatus.Rejected;
        completion.VerifiedByUserId = adminUserId;
        completion.VerifiedAt = DateTime.UtcNow;
        completion.RejectionReason = reason;

        await _context.SaveChangesAsync();
        return new ReviewResult(ReviewOutcome.Done, Title: title, CompletedBy: completedBy);
    }

    private Task<TaskCompletion?> Find(Guid completionId) => _context.TaskCompletions
        .Include(c => c.TaskAssignment)
        .ThenInclude(a => a!.TaskDefinition)
        .Include(c => c.CompletedByUser)
        .FirstOrDefaultAsync(c => c.Id == completionId);
}
