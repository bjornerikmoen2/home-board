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
