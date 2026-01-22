using HomeBoard.Api.Helpers;
using HomeBoard.Api.Models;
using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Services;

public interface ITaskService
{
    Task<List<TaskDefinitionDto>> GetTaskDefinitionsAsync();
    Task<List<TaskAssignmentDto>> GetTaskAssignmentsAsync();
    Task<TaskDefinitionDto> CreateTaskDefinitionAsync(CreateTaskDefinitionRequest request, Guid createdByUserId);
    Task<TaskDefinitionDto> UpdateTaskDefinitionAsync(Guid id, UpdateTaskDefinitionRequest request);
    Task DeleteTaskDefinitionAsync(Guid id);
    Task<TaskAssignmentDto> CreateTaskAssignmentAsync(CreateTaskAssignmentRequest request);
    Task<TaskAssignmentDto> UpdateTaskAssignmentAsync(Guid id, UpdateTaskAssignmentRequest request);
    Task DeleteTaskAssignmentAsync(Guid id);
    Task<Guid> CompleteTaskAsync(Guid assignmentId, Guid userId, CompleteTaskRequest? request);
    Task<List<CalendarTaskDto>> GetCalendarTasksAsync(DateOnly startDate, DateOnly endDate, Guid userId, bool isAdmin);
    Task<List<TodayTaskDto>> GetTodayTasksAsync(Guid userId);
}

public class TaskService : ITaskService
{
    private readonly HomeBoardDbContext _context;

    public TaskService(HomeBoardDbContext context)
    {
        _context = context;
    }

    public async Task<List<TaskDefinitionDto>> GetTaskDefinitionsAsync()
    {
        return await _context.TaskDefinitions
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
    }

    public async Task<List<TaskAssignmentDto>> GetTaskAssignmentsAsync()
    {
        return await _context.TaskAssignments
            .Include(a => a.TaskDefinition)
            .Include(a => a.AssignedToUser)
            .Where(a => a.IsActive)
            .Select(a => new TaskAssignmentDto
            {
                Id = a.Id,
                TaskDefinitionId = a.TaskDefinitionId,
                TaskTitle = a.TaskDefinition!.Title,
                AssignedToUserId = a.AssignedToUserId,
                AssignedToName = a.AssignedToUser != null ? a.AssignedToUser.DisplayName : null,
                AssignedToGroup = a.AssignedToGroup,
                ScheduleType = a.ScheduleType,
                DaysOfWeek = a.DaysOfWeek,
                StartDate = a.StartDate,
                EndDate = a.EndDate,
                DueTime = a.DueTime,
                IsActive = a.IsActive
            })
            .ToListAsync();
    }

    public async Task<TaskDefinitionDto> CreateTaskDefinitionAsync(CreateTaskDefinitionRequest request, Guid createdByUserId)
    {
        var taskDefinition = new TaskDefinition
        {
            Id = Guid.NewGuid(),
            Title = request.Title,
            Description = request.Description,
            DefaultPoints = request.DefaultPoints,
            IsActive = true,
            CreatedByUserId = createdByUserId,
            CreatedAt = DateTime.UtcNow
        };

        _context.TaskDefinitions.Add(taskDefinition);
        await _context.SaveChangesAsync();

        return new TaskDefinitionDto
        {
            Id = taskDefinition.Id,
            Title = taskDefinition.Title,
            Description = taskDefinition.Description,
            DefaultPoints = taskDefinition.DefaultPoints,
            IsActive = taskDefinition.IsActive
        };
    }

    public async Task<TaskDefinitionDto> UpdateTaskDefinitionAsync(Guid id, UpdateTaskDefinitionRequest request)
    {
        var taskDefinition = await _context.TaskDefinitions.FindAsync(id);
        if (taskDefinition == null)
        {
            throw new KeyNotFoundException($"Task definition with ID {id} not found");
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

        return new TaskDefinitionDto
        {
            Id = taskDefinition.Id,
            Title = taskDefinition.Title,
            Description = taskDefinition.Description,
            DefaultPoints = taskDefinition.DefaultPoints,
            IsActive = taskDefinition.IsActive
        };
    }

    public async Task DeleteTaskDefinitionAsync(Guid id)
    {
        var taskDefinition = await _context.TaskDefinitions.FindAsync(id);
        if (taskDefinition == null)
        {
            throw new KeyNotFoundException($"Task definition with ID {id} not found");
        }

        // Soft delete - just mark as inactive
        taskDefinition.IsActive = false;
        await _context.SaveChangesAsync();
    }

    public async Task<TaskAssignmentDto> CreateTaskAssignmentAsync(CreateTaskAssignmentRequest request)
    {
        // Validate that either user or group is assigned, but not both
        if (request.AssignedToUserId.HasValue && request.AssignedToGroup.HasValue)
        {
            throw new InvalidOperationException("Cannot assign to both a specific user and a user group");
        }
        if (!request.AssignedToUserId.HasValue && !request.AssignedToGroup.HasValue)
        {
            throw new InvalidOperationException("Must assign to either a specific user or a user group");
        }

        // Validate AssignedToGroup contains a valid UserRole enum value
        if (request.AssignedToGroup.HasValue && !Enum.IsDefined(typeof(UserRole), request.AssignedToGroup.Value))
        {
            throw new InvalidOperationException($"Invalid AssignedToGroup value. Must be {(int)UserRole.Admin} (Admin) or {(int)UserRole.User} (User)");
        }

        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(),
            TaskDefinitionId = request.TaskDefinitionId,
            AssignedToUserId = request.AssignedToUserId,
            AssignedToGroup = request.AssignedToGroup,
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
        if (assignment.AssignedToUserId.HasValue)
        {
            await _context.Entry(assignment).Reference(a => a.AssignedToUser).LoadAsync();
        }

        return new TaskAssignmentDto
        {
            Id = assignment.Id,
            TaskDefinitionId = assignment.TaskDefinitionId,
            TaskTitle = assignment.TaskDefinition!.Title,
            AssignedToUserId = assignment.AssignedToUserId,
            AssignedToName = assignment.AssignedToUser?.DisplayName,
            AssignedToGroup = assignment.AssignedToGroup,
            ScheduleType = assignment.ScheduleType,
            DaysOfWeek = assignment.DaysOfWeek,
            StartDate = assignment.StartDate,
            EndDate = assignment.EndDate,
            DueTime = assignment.DueTime,
            IsActive = assignment.IsActive
        };
    }

    public async Task<TaskAssignmentDto> UpdateTaskAssignmentAsync(Guid id, UpdateTaskAssignmentRequest request)
    {
        var assignment = await _context.TaskAssignments
            .Include(a => a.TaskDefinition)
            .Include(a => a.AssignedToUser)
            .FirstOrDefaultAsync(a => a.Id == id);

        if (assignment == null)
        {
            throw new KeyNotFoundException($"Task assignment with ID {id} not found");
        }

        // Determine the target assignment and validate that either user or group is assigned, but not both
        Guid? targetUserId;
        int? targetGroup;

        if (request.AssignedToUserId.HasValue)
        {
            // Explicitly assign to a specific user and clear any group assignment
            targetUserId = request.AssignedToUserId;
            targetGroup = null;
        }
        else if (request.AssignedToGroup.HasValue)
        {
            // Explicitly assign to a user group and clear any user assignment
            targetUserId = null;
            targetGroup = request.AssignedToGroup;
        }
        else
        {
            // No change requested; keep existing assignment
            targetUserId = assignment.AssignedToUserId;
            targetGroup = assignment.AssignedToGroup;
        }

        if (targetUserId.HasValue && targetGroup.HasValue)
        {
            throw new InvalidOperationException("Cannot assign to both a specific user and a user group");
        }
        if (!targetUserId.HasValue && !targetGroup.HasValue)
        {
            throw new InvalidOperationException("Must assign to either a specific user or a user group");
        }

        // Validate AssignedToGroup contains a valid UserRole enum value
        if (targetGroup.HasValue && !Enum.IsDefined(typeof(UserRole), targetGroup.Value))
        {
            throw new InvalidOperationException($"Invalid AssignedToGroup value. Must be {(int)UserRole.Admin} (Admin) or {(int)UserRole.User} (User)");
        }

        // Update required fields (always sent from frontend)
        assignment.TaskDefinitionId = request.TaskDefinitionId ?? assignment.TaskDefinitionId;
        assignment.AssignedToUserId = targetUserId;
        assignment.AssignedToGroup = targetGroup;
        assignment.ScheduleType = request.ScheduleType ?? assignment.ScheduleType;
        assignment.DaysOfWeek = request.DaysOfWeek ?? assignment.DaysOfWeek;
        assignment.IsActive = request.IsActive ?? assignment.IsActive;

        // Update nullable fields (null means clear the value)
        assignment.StartDate = request.StartDate;
        assignment.EndDate = request.EndDate;
        assignment.DueTime = request.DueTime;

        await _context.SaveChangesAsync();

        // Reload related data
        await _context.Entry(assignment).Reference(a => a.TaskDefinition).LoadAsync();
        if (assignment.AssignedToUserId.HasValue)
        {
            await _context.Entry(assignment).Reference(a => a.AssignedToUser).LoadAsync();
        }

        return new TaskAssignmentDto
        {
            Id = assignment.Id,
            TaskDefinitionId = assignment.TaskDefinitionId,
            TaskTitle = assignment.TaskDefinition!.Title,
            AssignedToUserId = assignment.AssignedToUserId,
            AssignedToName = assignment.AssignedToUser?.DisplayName,
            AssignedToGroup = assignment.AssignedToGroup,
            ScheduleType = assignment.ScheduleType,
            DaysOfWeek = assignment.DaysOfWeek,
            StartDate = assignment.StartDate,
            EndDate = assignment.EndDate,
            DueTime = assignment.DueTime,
            IsActive = assignment.IsActive
        };
    }

    public async Task DeleteTaskAssignmentAsync(Guid id)
    {
        var assignment = await _context.TaskAssignments.FindAsync(id);
        if (assignment == null)
        {
            throw new KeyNotFoundException($"Task assignment with ID {id} not found");
        }

        // Soft delete - just mark as inactive
        assignment.IsActive = false;
        await _context.SaveChangesAsync();
    }

    public async Task<Guid> CompleteTaskAsync(Guid assignmentId, Guid userId, CompleteTaskRequest? request)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        // Get current user to check their role
        var currentUser = await _context.Users.FindAsync(userId);
        if (currentUser == null)
        {
            throw new KeyNotFoundException("User not found");
        }

        var assignment = await _context.TaskAssignments
            .Include(a => a.TaskDefinition)
            .FirstOrDefaultAsync(a => a.Id == assignmentId && a.IsActive);

        if (assignment == null)
        {
            throw new KeyNotFoundException("Task assignment not found");
        }

        // Check if user can complete this task
        bool canComplete = false;
        if (assignment.AssignedToUserId.HasValue && assignment.AssignedToUserId.Value == userId)
        {
            canComplete = true;
        }
        else if (assignment.AssignedToGroup.HasValue && assignment.AssignedToGroup.Value == (int)currentUser.Role)
        {
            // Task assigned to user's role group - user can complete
            canComplete = true;
        }

        if (!canComplete)
        {
            throw new UnauthorizedAccessException("User cannot complete this task");
        }

        // Check if already completed today
        var existingCompletion = await _context.TaskCompletions
            .FirstOrDefaultAsync(c => c.TaskAssignmentId == assignmentId && c.Date == today);

        if (existingCompletion != null)
        {
            throw new InvalidOperationException("Task already completed today");
        }

        var completion = new TaskCompletion
        {
            Id = Guid.NewGuid(),
            TaskAssignmentId = assignmentId,
            Date = today,
            CompletedByUserId = userId,
            CompletedAt = DateTime.UtcNow,
            Status = Domain.Enums.TaskStatus.Completed,
            Notes = request?.Notes,
            PhotoUrl = request?.PhotoUrl
        };

        _context.TaskCompletions.Add(completion);
        await _context.SaveChangesAsync();

        return completion.Id;
    }

    public async Task<List<CalendarTaskDto>> GetCalendarTasksAsync(DateOnly startDate, DateOnly endDate, Guid userId, bool isAdmin)
    {
        // Get current user to check their role
        var currentUser = await _context.Users.FindAsync(userId);
        if (currentUser == null)
        {
            throw new KeyNotFoundException("User not found");
        }

        // Get family settings for week start configuration
        var familySettings = await _context.FamilySettings.FirstOrDefaultAsync();
        var weekStartsOn = familySettings?.WeekStartsOn ?? DayOfWeek.Monday;

        // Get all active assignments for the user (or all if admin)
        var assignmentsQuery = _context.TaskAssignments
            .Include(a => a.TaskDefinition)
            .Include(a => a.AssignedToUser)
            .Where(a => a.IsActive && a.TaskDefinition!.IsActive);

        if (!isAdmin)
        {
            // Include assignments where user is directly assigned OR assigned to their role group
            assignmentsQuery = assignmentsQuery.Where(a => 
                a.AssignedToUserId == userId || 
                a.AssignedToGroup == (int)currentUser.Role);
        }

        var assignments = await assignmentsQuery.ToListAsync();

        // Get existing completions in the date range
        var completions = await _context.TaskCompletions
            .Where(c => c.Date >= startDate && c.Date <= endDate)
            .ToListAsync();

        var calendarTasks = new List<CalendarTaskDto>();

        // Generate tasks for each date in the range
        for (var date = startDate; date <= endDate; date = date.AddDays(1))
        {
            var dayOfWeek = (int)date.DayOfWeek;
            var dayFlag = 1 << dayOfWeek;

            foreach (var assignment in assignments)
            {
                // Check date range constraints
                if (assignment.StartDate.HasValue && date < assignment.StartDate.Value)
                    continue;
                if (assignment.EndDate.HasValue && date > assignment.EndDate.Value)
                    continue;

                bool isScheduledForDate = false;

                // Check if task is scheduled for this date based on schedule type
                switch (assignment.ScheduleType)
                {
                    case ScheduleType.Daily:
                        isScheduledForDate = ((int)assignment.DaysOfWeek & dayFlag) != 0;
                        break;
                    
                    case ScheduleType.Weekly:
                        isScheduledForDate = ((int)assignment.DaysOfWeek & dayFlag) != 0;
                        break;
                    
                    case ScheduleType.Once:
                        isScheduledForDate = assignment.StartDate == date;
                        break;
                    
                    case ScheduleType.DuringWeek:
                        // Show on first day of week and every day until completed
                        var weekStart = DateTimeHelper.GetStartOfWeek(date, weekStartsOn);
                        var weekEnd = weekStart.AddDays(6);
                        var completionThisWeek = completions.FirstOrDefault(
                            c => c.TaskAssignmentId == assignment.Id && 
                                 c.Date >= weekStart && c.Date <= weekEnd);
                        // Show if not completed this week and date is on or after the week start day
                        isScheduledForDate = completionThisWeek == null && date >= weekStart;
                        break;
                    
                    case ScheduleType.DuringMonth:
                        // Show on first day of month and every day until completed
                        var monthStart = new DateOnly(date.Year, date.Month, 1);
                        var monthEnd = monthStart.AddMonths(1).AddDays(-1);
                        var completionThisMonth = completions.FirstOrDefault(
                            c => c.TaskAssignmentId == assignment.Id && 
                                 c.Date >= monthStart && c.Date <= monthEnd);
                        // Show if not completed this month
                        isScheduledForDate = completionThisMonth == null && date >= monthStart;
                        break;
                }

                if (isScheduledForDate)
                {
                    var completion = completions.FirstOrDefault(
                        c => c.TaskAssignmentId == assignment.Id && c.Date == date);

                    calendarTasks.Add(new CalendarTaskDto
                    {
                        AssignmentId = assignment.Id,
                        Date = date,
                        Title = assignment.TaskDefinition!.Title,
                        Description = assignment.TaskDefinition.Description,
                        AssignedToUserId = assignment.AssignedToUserId,
                        AssignedToName = assignment.AssignedToUser?.DisplayName,
                        AssignedToGroup = assignment.AssignedToGroup,
                        DueTime = assignment.DueTime,
                        DefaultPoints = assignment.TaskDefinition.DefaultPoints,
                        IsCompleted = completion != null,
                        CompletionId = completion?.Id,
                        Status = completion?.Status
                    });
                }
            }
        }

        return calendarTasks.OrderBy(t => t.Date).ThenBy(t => t.DueTime).ToList();
    }

    public async Task<List<TodayTaskDto>> GetTodayTasksAsync(Guid userId)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var currentDayOfWeek = (DayOfWeekFlag)(1 << (int)today.DayOfWeek);

        // Get current user to check their role
        var currentUser = await _context.Users.FindAsync(userId);
        if (currentUser == null)
        {
            throw new KeyNotFoundException("User not found");
        }

        // Get family settings for week start configuration and timezone
        var familySettings = await _context.FamilySettings.FirstOrDefaultAsync();
        var weekStartsOn = familySettings?.WeekStartsOn ?? DayOfWeek.Monday;
        var timezone = familySettings?.Timezone ?? "UTC";
        var timeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById(timezone);
        var currentTimeInZone = TimeZoneInfo.ConvertTime(DateTime.UtcNow, timeZoneInfo);
        var currentTime = TimeOnly.FromDateTime(currentTimeInZone);

        // Get active assignments for this user or their role group
        var assignments = await _context.TaskAssignments
            .Include(a => a.TaskDefinition)
            .Where(a => (a.AssignedToUserId == userId || a.AssignedToGroup == (int)currentUser.Role) && a.IsActive)
            .Where(a => a.StartDate == null || a.StartDate <= today)
            .Where(a => a.EndDate == null || a.EndDate >= today)
            .ToListAsync();

        // Get the start of week and month for "During" schedule types
        var weekStart = DateTimeHelper.GetStartOfWeek(today, weekStartsOn);
        var weekEnd = weekStart.AddDays(6);
        var monthStart = new DateOnly(today.Year, today.Month, 1);
        var monthEnd = monthStart.AddMonths(1).AddDays(-1);

        // Get completions for this week and month (for "During" schedule types)
        var assignmentIds = assignments.Select(a => a.Id).ToList();
        var completionsThisWeek = await _context.TaskCompletions
            .Include(c => c.CompletedByUser)
            .Where(c => assignmentIds.Contains(c.TaskAssignmentId) && 
                       c.Date >= weekStart && c.Date <= weekEnd)
            .ToListAsync();
        
        var completionsThisMonth = await _context.TaskCompletions
            .Include(c => c.CompletedByUser)
            .Where(c => assignmentIds.Contains(c.TaskAssignmentId) && 
                       c.Date >= monthStart && c.Date <= monthEnd)
            .ToListAsync();

        // Get completions for today
        var todayCompletions = await _context.TaskCompletions
            .Include(c => c.CompletedByUser)
            .Where(c => assignmentIds.Contains(c.TaskAssignmentId) && c.Date == today)
            .ToDictionaryAsync(c => c.TaskAssignmentId, c => c);

        // Filter by schedule and build result
        var result = new List<TodayTaskDto>();
        foreach (var a in assignments)
        {
            bool shouldShow = TaskScheduleHelper.ShouldShowTask(
                a, 
                today,
                currentTime,
                currentDayOfWeek, 
                completionsThisWeek, 
                completionsThisMonth, 
                showCompletedTasks: true);
            
            if (shouldShow)
            {
                var completion = todayCompletions.ContainsKey(a.Id) ? todayCompletions[a.Id] : null;
                
                result.Add(new TodayTaskDto
                {
                    AssignmentId = a.Id,
                    Title = a.TaskDefinition!.Title,
                    Description = a.TaskDefinition.Description,
                    Points = a.TaskDefinition.DefaultPoints,
                    DueTime = a.DueTime,
                    IsCompleted = completion != null,
                    CompletionId = completion?.Id,
                    Status = completion?.Status,
                    CompletedByName = completion != null && a.AssignedToGroup.HasValue 
                        ? completion.CompletedByUser?.DisplayName 
                        : null
                });
            }
        }

        return result;
    }

}
