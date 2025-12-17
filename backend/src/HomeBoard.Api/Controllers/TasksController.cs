using System.Security.Claims;
using HomeBoard.Api.Models;
using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TasksController : ControllerBase
{
    private readonly HomeBoardDbContext _context;

    public TasksController(HomeBoardDbContext context)
    {
        _context = context;
    }

    [HttpGet("definitions")]
    public async Task<ActionResult<List<TaskDefinitionDto>>> GetTaskDefinitions()
    {
        var definitions = await _context.TaskDefinitions
            .Where(t => t.IsActive)
            .Select(t => new TaskDefinitionDto
            {
                Id = t.Id,
                Title = t.Title,
                Description = t.Description,
                DefaultPoints = t.DefaultPoints,
                IsActive = t.IsActive
            })
            .ToListAsync();

        return Ok(definitions);
    }

    [HttpGet("assignments")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<TaskAssignmentDto>>> GetTaskAssignments()
    {
        var assignments = await _context.TaskAssignments
            .Include(a => a.TaskDefinition)
            .Include(a => a.AssignedToUser)
            .Where(a => a.IsActive)
            .Select(a => new TaskAssignmentDto
            {
                Id = a.Id,
                TaskDefinitionId = a.TaskDefinitionId,
                TaskTitle = a.TaskDefinition!.Title,
                AssignedToUserId = a.AssignedToUserId,
                AssignedToName = a.AssignedToUser!.DisplayName,
                ScheduleType = a.ScheduleType,
                DaysOfWeek = a.DaysOfWeek,
                StartDate = a.StartDate,
                EndDate = a.EndDate,
                DueTime = a.DueTime,
                IsActive = a.IsActive
            })
            .ToListAsync();

        return Ok(assignments);
    }

    [HttpPost("definitions")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<TaskDefinitionDto>> CreateTaskDefinition([FromBody] CreateTaskDefinitionRequest request)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        var taskDefinition = new TaskDefinition
        {
            Id = Guid.NewGuid(),
            Title = request.Title,
            Description = request.Description,
            DefaultPoints = request.DefaultPoints,
            IsActive = true,
            CreatedByUserId = userId,
            CreatedAt = DateTime.UtcNow
        };

        _context.TaskDefinitions.Add(taskDefinition);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetTaskDefinitions), new { id = taskDefinition.Id }, new TaskDefinitionDto
        {
            Id = taskDefinition.Id,
            Title = taskDefinition.Title,
            Description = taskDefinition.Description,
            DefaultPoints = taskDefinition.DefaultPoints,
            IsActive = taskDefinition.IsActive
        });
    }

    [HttpPatch("definitions/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<TaskDefinitionDto>> UpdateTaskDefinition(Guid id, [FromBody] UpdateTaskDefinitionRequest request)
    {
        var taskDefinition = await _context.TaskDefinitions.FindAsync(id);
        if (taskDefinition == null)
        {
            return NotFound();
        }

        if (request.Title != null)
        {
            taskDefinition.Title = request.Title;
        }

        if (request.Description != null)
        {
            taskDefinition.Description = request.Description;
        }

        if (request.DefaultPoints.HasValue)
        {
            taskDefinition.DefaultPoints = request.DefaultPoints.Value;
        }

        if (request.IsActive.HasValue)
        {
            taskDefinition.IsActive = request.IsActive.Value;
        }

        await _context.SaveChangesAsync();

        return Ok(new TaskDefinitionDto
        {
            Id = taskDefinition.Id,
            Title = taskDefinition.Title,
            Description = taskDefinition.Description,
            DefaultPoints = taskDefinition.DefaultPoints,
            IsActive = taskDefinition.IsActive
        });
    }

    [HttpDelete("definitions/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteTaskDefinition(Guid id)
    {
        var taskDefinition = await _context.TaskDefinitions.FindAsync(id);
        if (taskDefinition == null)
        {
            return NotFound();
        }

        // Soft delete - just mark as inactive
        taskDefinition.IsActive = false;
        await _context.SaveChangesAsync();

        return NoContent();
    }

    [HttpPost("assignments")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<TaskAssignmentDto>> CreateTaskAssignment([FromBody] CreateTaskAssignmentRequest request)
    {
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(),
            TaskDefinitionId = request.TaskDefinitionId,
            AssignedToUserId = request.AssignedToUserId,
            ScheduleType = request.ScheduleType,
            DaysOfWeek = request.DaysOfWeek,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            DueTime = request.DueTime,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _context.TaskAssignments.Add(assignment);
        await _context.SaveChangesAsync();

        // Load related data for response
        await _context.Entry(assignment).Reference(a => a.TaskDefinition).LoadAsync();
        await _context.Entry(assignment).Reference(a => a.AssignedToUser).LoadAsync();

        return CreatedAtAction(nameof(GetTaskDefinitions), new { id = assignment.Id }, new TaskAssignmentDto
        {
            Id = assignment.Id,
            TaskDefinitionId = assignment.TaskDefinitionId,
            TaskTitle = assignment.TaskDefinition!.Title,
            AssignedToUserId = assignment.AssignedToUserId,
            AssignedToName = assignment.AssignedToUser!.DisplayName,
            ScheduleType = assignment.ScheduleType,
            DaysOfWeek = assignment.DaysOfWeek,
            StartDate = assignment.StartDate,
            EndDate = assignment.EndDate,
            DueTime = assignment.DueTime,
            IsActive = assignment.IsActive
        });
    }

    [HttpPatch("assignments/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<TaskAssignmentDto>> UpdateTaskAssignment(Guid id, [FromBody] UpdateTaskAssignmentRequest request)
    {
        var assignment = await _context.TaskAssignments
            .Include(a => a.TaskDefinition)
            .Include(a => a.AssignedToUser)
            .FirstOrDefaultAsync(a => a.Id == id);

        if (assignment == null)
        {
            return NotFound();
        }

        if (request.IsActive.HasValue)
        {
            assignment.IsActive = request.IsActive.Value;
        }

        if (request.DueTime.HasValue)
        {
            assignment.DueTime = request.DueTime.Value;
        }

        await _context.SaveChangesAsync();

        return Ok(new TaskAssignmentDto
        {
            Id = assignment.Id,
            TaskDefinitionId = assignment.TaskDefinitionId,
            TaskTitle = assignment.TaskDefinition!.Title,
            AssignedToUserId = assignment.AssignedToUserId,
            AssignedToName = assignment.AssignedToUser!.DisplayName,
            ScheduleType = assignment.ScheduleType,
            DaysOfWeek = assignment.DaysOfWeek,
            StartDate = assignment.StartDate,
            EndDate = assignment.EndDate,
            DueTime = assignment.DueTime,
            IsActive = assignment.IsActive
        });
    }

    [HttpDelete("assignments/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteTaskAssignment(Guid id)
    {
        var assignment = await _context.TaskAssignments.FindAsync(id);
        if (assignment == null)
        {
            return NotFound();
        }

        // Soft delete - just mark as inactive
        assignment.IsActive = false;
        await _context.SaveChangesAsync();

        return NoContent();
    }

    [HttpPost("{assignmentId}/complete")]
    public async Task<IActionResult> CompleteTask(Guid assignmentId)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        var assignment = await _context.TaskAssignments
            .Include(a => a.TaskDefinition)
            .FirstOrDefaultAsync(a => a.Id == assignmentId && a.AssignedToUserId == userId && a.IsActive);

        if (assignment == null)
        {
            return NotFound(new { message = "Task assignment not found" });
        }

        // Check if already completed today
        var existingCompletion = await _context.TaskCompletions
            .FirstOrDefaultAsync(c => c.TaskAssignmentId == assignmentId && c.Date == today);

        if (existingCompletion != null)
        {
            return Conflict(new { message = "Task already completed today" });
        }

        var completion = new TaskCompletion
        {
            Id = Guid.NewGuid(),
            TaskAssignmentId = assignmentId,
            Date = today,
            CompletedByUserId = userId,
            CompletedAt = DateTime.UtcNow,
            Status = Domain.Enums.TaskStatus.Completed
        };

        _context.TaskCompletions.Add(completion);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Task marked as completed", completionId = completion.Id });
    }
}
