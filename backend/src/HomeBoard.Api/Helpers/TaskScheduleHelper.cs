using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;

namespace HomeBoard.Api.Helpers;

public static class TaskScheduleHelper
{
    public static bool ShouldShowTask(
        TaskAssignment assignment, 
        DateOnly today,
        TimeOnly currentTime,
        DayOfWeekFlag currentDayOfWeek,
        List<TaskCompletion> completionsThisWeek,
        List<TaskCompletion> completionsThisMonth,
        bool showCompletedTasks = false)
    {
        // Filter out tasks where the due time has passed
        if (assignment.DueTime.HasValue && currentTime > assignment.DueTime.Value)
        {
            return false;
        }

        return assignment.ScheduleType switch
        {
            ScheduleType.Daily => true,
            ScheduleType.Weekly => (assignment.DaysOfWeek & currentDayOfWeek) != 0,
            ScheduleType.Once => assignment.StartDate == today,
            ScheduleType.DuringWeek => ShouldShowDuringWeekTask(assignment.Id, today, completionsThisWeek, showCompletedTasks),
            ScheduleType.DuringMonth => ShouldShowDuringMonthTask(assignment.Id, today, completionsThisMonth, showCompletedTasks),
            _ => false
        };
    }

    /// <summary>
    /// Whether an assignment is a chore on the given date, counted the way the kids' "today" list
    /// counts it but without hiding chores whose due time has passed. "During week/month" chores
    /// count every day until they are done, and on the day they were done.
    /// </summary>
    public static bool IsChoreOn(
        TaskAssignment assignment,
        DateOnly date,
        List<TaskCompletion> completions,
        DayOfWeek weekStartsOn)
    {
        if (assignment.StartDate.HasValue && date < assignment.StartDate.Value)
        {
            return false;
        }
        if (assignment.EndDate.HasValue && date > assignment.EndDate.Value)
        {
            return false;
        }

        // Only completions up to this date count, so a chore done later in its week or month
        // still shows as to do on the days before.
        var weekStart = DateTimeHelper.GetStartOfWeek(date, weekStartsOn);
        var monthStart = DateTimeHelper.GetStartOfMonth(date);
        var dayOfWeek = (DayOfWeekFlag)(1 << (int)date.DayOfWeek);

        return assignment.ScheduleType switch
        {
            ScheduleType.Daily => true,
            ScheduleType.Weekly => (assignment.DaysOfWeek & dayOfWeek) != 0,
            ScheduleType.Once => assignment.StartDate == date,
            ScheduleType.DuringWeek => ShouldShowDuringWeekTask(
                assignment.Id, date, completions.Where(c => c.Date >= weekStart && c.Date <= date).ToList(), showCompletedTasks: true),
            ScheduleType.DuringMonth => ShouldShowDuringMonthTask(
                assignment.Id, date, completions.Where(c => c.Date >= monthStart && c.Date <= date).ToList(), showCompletedTasks: true),
            _ => false
        };
    }

    private static bool ShouldShowDuringWeekTask(
        Guid assignmentId,
        DateOnly today,
        List<TaskCompletion> completionsThisWeek,
        bool showCompletedTasks)
    {
        var weekCompletion = completionsThisWeek.FirstOrDefault(c => c.TaskAssignmentId == assignmentId);
        
        if (weekCompletion == null)
        {
            return true; // Not completed this week
        }
        
        // If showCompletedTasks is true, show on completion day
        return showCompletedTasks && weekCompletion.Date == today;
    }

    private static bool ShouldShowDuringMonthTask(
        Guid assignmentId,
        DateOnly today,
        List<TaskCompletion> completionsThisMonth,
        bool showCompletedTasks)
    {
        var monthCompletion = completionsThisMonth.FirstOrDefault(c => c.TaskAssignmentId == assignmentId);
        
        if (monthCompletion == null)
        {
            return true; // Not completed this month
        }
        
        // If showCompletedTasks is true, show on completion day
        return showCompletedTasks && monthCompletion.Date == today;
    }
}
