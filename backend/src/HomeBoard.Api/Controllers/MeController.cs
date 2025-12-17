using System.Security.Claims;
using HomeBoard.Api.Models;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class MeController : ControllerBase
{
    private readonly HomeBoardDbContext _context;

    public MeController(HomeBoardDbContext context)
    {
        _context = context;
    }

    [HttpGet("today")]
    public async Task<ActionResult<List<TodayTaskDto>>> GetTodayTasks()
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var currentDayOfWeek = (DayOfWeekFlag)(1 << (int)today.DayOfWeek);

        // Get active assignments for this user
        var assignments = await _context.TaskAssignments
            .Include(a => a.TaskDefinition)
            .Where(a => a.AssignedToUserId == userId && a.IsActive)
            .Where(a => a.StartDate == null || a.StartDate <= today)
            .Where(a => a.EndDate == null || a.EndDate >= today)
            .ToListAsync();

        // Filter by schedule
        var todayAssignments = assignments.Where(a =>
            a.ScheduleType == Domain.Enums.ScheduleType.Daily ||
            (a.ScheduleType == Domain.Enums.ScheduleType.Weekly && (a.DaysOfWeek & currentDayOfWeek) != 0) ||
            (a.ScheduleType == Domain.Enums.ScheduleType.Once && a.StartDate == today)
        ).ToList();

        // Get completions for today
        var assignmentIds = todayAssignments.Select(a => a.Id).ToList();
        var completions = await _context.TaskCompletions
            .Where(c => assignmentIds.Contains(c.TaskAssignmentId) && c.Date == today)
            .ToDictionaryAsync(c => c.TaskAssignmentId, c => c);

        var result = todayAssignments.Select(a => new TodayTaskDto
        {
            AssignmentId = a.Id,
            Title = a.TaskDefinition!.Title,
            Description = a.TaskDefinition.Description,
            Points = a.TaskDefinition.DefaultPoints,
            DueTime = a.DueTime,
            IsCompleted = completions.ContainsKey(a.Id),
            CompletionId = completions.ContainsKey(a.Id) ? completions[a.Id].Id : null,
            Status = completions.ContainsKey(a.Id) ? completions[a.Id].Status : null
        }).ToList();

        return Ok(result);
    }
}
