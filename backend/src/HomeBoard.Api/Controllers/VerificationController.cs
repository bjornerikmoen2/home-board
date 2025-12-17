using System.Security.Claims;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class VerificationController : ControllerBase
{
    private readonly HomeBoardDbContext _context;
    private readonly IPointsService _pointsService;

    public VerificationController(HomeBoardDbContext context, IPointsService pointsService)
    {
        _context = context;
        _pointsService = pointsService;
    }

    [HttpGet("pending")]
    public async Task<ActionResult<List<PendingVerificationDto>>> GetPendingVerifications()
    {
        var pending = await _context.TaskCompletions
            .Include(c => c.TaskAssignment)
            .ThenInclude(a => a!.TaskDefinition)
            .Include(c => c.CompletedByUser)
            .Where(c => c.Status == TaskStatus.Completed)
            .OrderBy(c => c.CompletedAt)
            .Select(c => new PendingVerificationDto
            {
                CompletionId = c.Id,
                Date = c.Date,
                TaskTitle = c.TaskAssignment!.TaskDefinition!.Title,
                CompletedByName = c.CompletedByUser!.DisplayName,
                CompletedByUserId = c.CompletedByUserId,
                CompletedAt = c.CompletedAt,
                DefaultPoints = c.TaskAssignment.TaskDefinition.DefaultPoints
            })
            .ToListAsync();

        return Ok(pending);
    }

    [HttpPost("{completionId}/verify")]
    public async Task<IActionResult> VerifyCompletion(Guid completionId, [FromBody] VerifyTaskRequest? request)
    {
        var adminUserId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        var completion = await _context.TaskCompletions
            .Include(c => c.TaskAssignment)
            .ThenInclude(a => a!.TaskDefinition)
            .FirstOrDefaultAsync(c => c.Id == completionId);

        if (completion == null)
        {
            return NotFound();
        }

        if (completion.Status != TaskStatus.Completed)
        {
            return BadRequest(new { message = "Task completion has already been verified or rejected" });
        }

        // Idempotency check: ensure no points have been awarded for this completion
        var existingPoints = await _context.PointsLedger
            .AnyAsync(p => p.SourceType == PointSourceType.TaskVerified && p.SourceId == completionId);

        if (existingPoints)
        {
            return BadRequest(new { message = "Points already awarded for this completion" });
        }

        // Update completion status
        completion.Status = TaskStatus.Verified;
        completion.VerifiedByUserId = adminUserId;
        completion.VerifiedAt = DateTime.UtcNow;

        // Award points
        var pointsToAward = request?.PointsAwarded ?? completion.TaskAssignment!.TaskDefinition!.DefaultPoints;
        await _pointsService.AddPointsAsync(
            completion.CompletedByUserId,
            PointSourceType.TaskVerified,
            pointsToAward,
            completionId,
            $"Verified: {completion.TaskAssignment.TaskDefinition.Title}",
            adminUserId
        );

        await _context.SaveChangesAsync();

        return Ok(new { message = "Task verified and points awarded", pointsAwarded = pointsToAward });
    }

    [HttpPost("{completionId}/reject")]
    public async Task<IActionResult> RejectCompletion(Guid completionId, [FromBody] RejectTaskRequest request)
    {
        var adminUserId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        var completion = await _context.TaskCompletions
            .FirstOrDefaultAsync(c => c.Id == completionId);

        if (completion == null)
        {
            return NotFound();
        }

        if (completion.Status != TaskStatus.Completed)
        {
            return BadRequest(new { message = "Task completion has already been verified or rejected" });
        }

        completion.Status = TaskStatus.Rejected;
        completion.VerifiedByUserId = adminUserId;
        completion.VerifiedAt = DateTime.UtcNow;
        completion.RejectionReason = request.Reason;

        await _context.SaveChangesAsync();

        return Ok(new { message = "Task rejected" });
    }
}
