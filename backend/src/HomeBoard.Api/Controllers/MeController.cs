using System.Security.Claims;
using HomeBoard.Api.Models;
using HomeBoard.Domain.Enums;
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

        // Get family settings for week start configuration
        var familySettings = await _context.FamilySettings.FirstOrDefaultAsync();
        var weekStartsOn = familySettings?.WeekStartsOn ?? DayOfWeek.Monday;

        // Get active assignments for this user
        var assignments = await _context.TaskAssignments
            .Include(a => a.TaskDefinition)
            .Where(a => a.AssignedToUserId == userId && a.IsActive)
            .Where(a => a.StartDate == null || a.StartDate <= today)
            .Where(a => a.EndDate == null || a.EndDate >= today)
            .ToListAsync();

        // Get the start of week and month for "During" schedule types
        var weekStart = GetStartOfWeek(today, weekStartsOn);
        var weekEnd = weekStart.AddDays(6);
        var monthStart = new DateOnly(today.Year, today.Month, 1);
        var monthEnd = monthStart.AddMonths(1).AddDays(-1);

        // Get completions for this week and month
        var assignmentIds = assignments.Select(a => a.Id).ToList();
        var completionsThisWeek = await _context.TaskCompletions
            .Where(c => assignmentIds.Contains(c.TaskAssignmentId) && 
                       c.Date >= weekStart && c.Date <= weekEnd)
            .ToListAsync();
        
        var completionsThisMonth = await _context.TaskCompletions
            .Where(c => assignmentIds.Contains(c.TaskAssignmentId) && 
                       c.Date >= monthStart && c.Date <= monthEnd)
            .ToListAsync();

        // Filter by schedule
        var todayAssignments = new List<Domain.Entities.TaskAssignment>();
        foreach (var a in assignments)
        {
            bool shouldShow = false;
            
            switch (a.ScheduleType)
            {
                case Domain.Enums.ScheduleType.Daily:
                    shouldShow = true;
                    break;
                    
                case Domain.Enums.ScheduleType.Weekly:
                    shouldShow = (a.DaysOfWeek & currentDayOfWeek) != 0;
                    break;
                    
                case Domain.Enums.ScheduleType.Once:
                    shouldShow = a.StartDate == today;
                    break;
                    
                case Domain.Enums.ScheduleType.DuringWeek:
                    // Show if not completed this week
                    var completedThisWeek = completionsThisWeek.Any(c => c.TaskAssignmentId == a.Id);
                    shouldShow = !completedThisWeek;
                    break;
                    
                case Domain.Enums.ScheduleType.DuringMonth:
                    // Show if not completed this month
                    var completedThisMonth = completionsThisMonth.Any(c => c.TaskAssignmentId == a.Id);
                    shouldShow = !completedThisMonth;
                    break;
            }
            
            if (shouldShow)
            {
                todayAssignments.Add(a);
            }
        }

        // Get completions for today
        var todayCompletions = await _context.TaskCompletions
            .Where(c => assignmentIds.Contains(c.TaskAssignmentId) && c.Date == today)
            .ToDictionaryAsync(c => c.TaskAssignmentId, c => c);

        var result = todayAssignments.Select(a => new TodayTaskDto
        {
            AssignmentId = a.Id,
            Title = a.TaskDefinition!.Title,
            Description = a.TaskDefinition.Description,
            Points = a.TaskDefinition.DefaultPoints,
            DueTime = a.DueTime,
            IsCompleted = todayCompletions.ContainsKey(a.Id),
            CompletionId = todayCompletions.ContainsKey(a.Id) ? todayCompletions[a.Id].Id : null,
            Status = todayCompletions.ContainsKey(a.Id) ? todayCompletions[a.Id].Status : null
        }).ToList();

        return Ok(result);
    }

    private static DateOnly GetStartOfWeek(DateOnly date, DayOfWeek weekStartsOn)
    {
        var currentDayOfWeek = (int)date.DayOfWeek;
        var targetStartDay = (int)weekStartsOn;
        
        // Calculate days to subtract to get to the start of the week
        var daysToSubtract = (currentDayOfWeek - targetStartDay + 7) % 7;
        return date.AddDays(-daysToSubtract);
    }

    [HttpPatch("language")]
    public async Task<IActionResult> UpdateLanguage([FromBody] UpdateLanguageRequest request)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return NotFound();
        }

        user.PreferredLanguage = request.PreferredLanguage;
        await _context.SaveChangesAsync();

        return Ok(new { preferredLanguage = user.PreferredLanguage });
    }

    [HttpPatch("dark-mode")]
    public async Task<IActionResult> UpdateDarkMode([FromBody] UpdateDarkModeRequest request)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return NotFound();
        }

        user.PrefersDarkMode = request.PrefersDarkMode;
        await _context.SaveChangesAsync();

        return Ok(new { prefersDarkMode = user.PrefersDarkMode });
    }
}

public class UpdateLanguageRequest
{
    public required string PreferredLanguage { get; set; }
}

public class UpdateDarkModeRequest
{
    public required bool PrefersDarkMode { get; set; }
}

