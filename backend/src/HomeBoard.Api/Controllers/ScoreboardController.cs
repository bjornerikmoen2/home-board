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
public class ScoreboardController : ControllerBase
{
    private readonly HomeBoardDbContext _context;

    public ScoreboardController(HomeBoardDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<ScoreboardResponseModel>> GetScoreboard()
    {
        // Check if scoreboard is enabled
        var settings = await _context.FamilySettings.FirstOrDefaultAsync();
        if (settings == null || !settings.EnableScoreboard)
        {
            return NotFound(new { message = "Scoreboard is not enabled" });
        }

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var currentDayOfWeek = (DayOfWeekFlag)(1 << (int)today.DayOfWeek);

        // Get family settings for week start
        var weekStartsOn = settings.WeekStartsOn;
        var weekStart = GetStartOfWeek(today, weekStartsOn);
        var weekEnd = weekStart.AddDays(6);
        var monthStart = new DateOnly(today.Year, today.Month, 1);
        var monthEnd = monthStart.AddMonths(1).AddDays(-1);

        // Get all active users with role "User" (exclude admins)
        var users = await _context.Users
            .Where(u => u.IsActive && u.Role == UserRole.User)
            .ToListAsync();

        // Get all "all users" tasks (shared tasks for User role)
        var allUsersAssignments = await _context.TaskAssignments
            .Include(a => a.TaskDefinition)
            .Where(a => a.AssignedToGroup == (int)UserRole.User && a.IsActive)
            .Where(a => a.StartDate == null || a.StartDate <= today)
            .Where(a => a.EndDate == null || a.EndDate >= today)
            .ToListAsync();

        // Get completions for all users tasks
        var allUsersAssignmentIds = allUsersAssignments.Select(a => a.Id).ToList();
        var allUsersCompletionsThisWeek = await _context.TaskCompletions
            .Where(c => allUsersAssignmentIds.Contains(c.TaskAssignmentId) && 
                       c.Date >= weekStart && c.Date <= weekEnd)
            .ToListAsync();
        
        var allUsersCompletionsThisMonth = await _context.TaskCompletions
            .Where(c => allUsersAssignmentIds.Contains(c.TaskAssignmentId) && 
                       c.Date >= monthStart && c.Date <= monthEnd)
            .ToListAsync();

        var allUsersTodayCompletions = await _context.TaskCompletions
            .Where(c => allUsersAssignmentIds.Contains(c.TaskAssignmentId) && c.Date == today)
            .Select(c => c.TaskAssignmentId)
            .ToHashSetAsync();

        // Build all users tasks list
        var allUsersTasks = new List<ScoreboardTaskModel>();
        foreach (var assignment in allUsersAssignments)
        {
            if (ShouldShowTask(assignment, today, currentDayOfWeek, allUsersCompletionsThisWeek, allUsersCompletionsThisMonth) 
                && !allUsersTodayCompletions.Contains(assignment.Id))
            {
                allUsersTasks.Add(new ScoreboardTaskModel
                {
                    Id = assignment.Id,
                    Title = assignment.TaskDefinition!.Title,
                    Points = assignment.TaskDefinition.DefaultPoints,
                    IsAllUsersTask = true
                });
            }
        }

        // Build user scoreboards (only personal tasks)
        var userScoreboards = new List<UserScoreboardModel>();
        foreach (var user in users)
        {
            // Calculate total points for this user
            var totalPoints = await _context.PointsLedger
                .Where(p => p.UserId == user.Id)
                .SumAsync(p => p.PointsDelta);

            // Get active assignments for this specific user ONLY (not group assignments)
            var userAssignments = await _context.TaskAssignments
                .Include(a => a.TaskDefinition)
                .Where(a => a.AssignedToUserId == user.Id && a.IsActive)
                .Where(a => a.StartDate == null || a.StartDate <= today)
                .Where(a => a.EndDate == null || a.EndDate >= today)
                .ToListAsync();

            // Get completions for this user's tasks
            var assignmentIds = userAssignments.Select(a => a.Id).ToList();
            var completionsThisWeek = await _context.TaskCompletions
                .Where(c => assignmentIds.Contains(c.TaskAssignmentId) && 
                           c.Date >= weekStart && c.Date <= weekEnd)
                .ToListAsync();
            
            var completionsThisMonth = await _context.TaskCompletions
                .Where(c => assignmentIds.Contains(c.TaskAssignmentId) && 
                           c.Date >= monthStart && c.Date <= monthEnd)
                .ToListAsync();

            var todayCompletions = await _context.TaskCompletions
                .Where(c => assignmentIds.Contains(c.TaskAssignmentId) && c.Date == today)
                .Select(c => c.TaskAssignmentId)
                .ToHashSetAsync();

            // Filter personal tasks to show only pending tasks for today
            var tasks = new List<ScoreboardTaskModel>();
            foreach (var assignment in userAssignments)
            {
                if (ShouldShowTask(assignment, today, currentDayOfWeek, completionsThisWeek, completionsThisMonth)
                    && !todayCompletions.Contains(assignment.Id))
                {
                    tasks.Add(new ScoreboardTaskModel
                    {
                        Id = assignment.Id,
                        Title = assignment.TaskDefinition!.Title,
                        Points = assignment.TaskDefinition.DefaultPoints,
                        IsAllUsersTask = false
                    });
                }
            }

            userScoreboards.Add(new UserScoreboardModel
            {
                Id = user.Id,
                Name = user.DisplayName,
                Points = totalPoints,
                Tasks = tasks
            });
        }

        // Get admin user settings for theme and language
        var adminUser = await _context.Users
            .Where(u => u.Role == UserRole.Admin && u.IsActive)
            .OrderBy(u => u.CreatedAt) // Get the first admin created
            .FirstOrDefaultAsync();

        var adminPrefersDarkMode = adminUser?.PrefersDarkMode ?? false;
        var adminPreferredLanguage = adminUser?.PreferredLanguage ?? "en";

        return Ok(new ScoreboardResponseModel
        {
            Users = userScoreboards.OrderByDescending(u => u.Points).ToList(),
            AllUsersTasks = allUsersTasks,
            AdminPrefersDarkMode = adminPrefersDarkMode,
            AdminPreferredLanguage = adminPreferredLanguage
        });
    }

    private static bool ShouldShowTask(
        TaskAssignment assignment, 
        DateOnly today, 
        DayOfWeekFlag currentDayOfWeek,
        List<TaskCompletion> completionsThisWeek,
        List<TaskCompletion> completionsThisMonth)
    {
        return assignment.ScheduleType switch
        {
            ScheduleType.Daily => true,
            ScheduleType.Weekly => (assignment.DaysOfWeek & currentDayOfWeek) != 0,
            ScheduleType.Once => assignment.StartDate == today,
            ScheduleType.DuringWeek => !completionsThisWeek.Any(c => c.TaskAssignmentId == assignment.Id),
            ScheduleType.DuringMonth => !completionsThisMonth.Any(c => c.TaskAssignmentId == assignment.Id),
            _ => false
        };
    }

    private static DateOnly GetStartOfWeek(DateOnly date, DayOfWeek weekStartsOn)
    {
        var currentDayOfWeek = (int)date.DayOfWeek;
        var targetStartDay = (int)weekStartsOn;
        
        var daysToSubtract = (currentDayOfWeek - targetStartDay + 7) % 7;
        return date.AddDays(-daysToSubtract);
    }
}
