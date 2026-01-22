using HomeBoard.Api.Helpers;
using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using Xunit;

namespace HomeBoard.Tests.Helpers;

public class TaskScheduleHelperTests
{
    private readonly DateOnly _today = new DateOnly(2026, 1, 22); // Thursday
    private readonly TimeOnly _currentTime = new TimeOnly(14, 30); // 2:30 PM
    private readonly DayOfWeekFlag _thursday = DayOfWeekFlag.Thursday;

    [Fact]
    public void ShouldShowTask_Daily_AlwaysReturnsTrue()
    {
        // Arrange
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(),
            ScheduleType = ScheduleType.Daily
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            new List<TaskCompletion>(),
            new List<TaskCompletion>());

        // Assert
        Assert.True(result);
    }

    [Theory]
    [InlineData(DayOfWeekFlag.Thursday, true)]  // Matches current day
    [InlineData(DayOfWeekFlag.Monday, false)]   // Different day
    [InlineData(DayOfWeekFlag.Monday | DayOfWeekFlag.Thursday, true)] // Multiple days including today
    public void ShouldShowTask_Weekly_ChecksDayOfWeek(DayOfWeekFlag daysOfWeek, bool expected)
    {
        // Arrange
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(),
            ScheduleType = ScheduleType.Weekly,
            DaysOfWeek = daysOfWeek
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            new List<TaskCompletion>(),
            new List<TaskCompletion>());

        // Assert
        Assert.Equal(expected, result);
    }

    [Theory]
    [InlineData("2026-01-22", true)]  // Today
    [InlineData("2026-01-23", false)] // Tomorrow
    [InlineData("2026-01-21", false)] // Yesterday
    public void ShouldShowTask_Once_OnlyShowsOnStartDate(string startDateStr, bool expected)
    {
        // Arrange
        var startDate = DateOnly.Parse(startDateStr);
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(),
            ScheduleType = ScheduleType.Once,
            StartDate = startDate
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            new List<TaskCompletion>(),
            new List<TaskCompletion>());

        // Assert
        Assert.Equal(expected, result);
    }

    [Fact]
    public void ShouldShowTask_DuringWeek_ShowsWhenNotCompleted()
    {
        // Arrange
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(),
            ScheduleType = ScheduleType.DuringWeek
        };

        var completionsThisWeek = new List<TaskCompletion>(); // No completions

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            completionsThisWeek,
            new List<TaskCompletion>());

        // Assert
        Assert.True(result);
    }

    [Fact]
    public void ShouldShowTask_DuringWeek_HidesWhenCompletedThisWeek_WithShowCompletedTasksFalse()
    {
        // Arrange
        var assignmentId = Guid.NewGuid();
        var assignment = new TaskAssignment
        {
            Id = assignmentId,
            ScheduleType = ScheduleType.DuringWeek
        };

        var completionsThisWeek = new List<TaskCompletion>
        {
            new TaskCompletion
            {
                TaskAssignmentId = assignmentId,
                Date = new DateOnly(2026, 1, 20) // Completed earlier this week (Tuesday)
            }
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            completionsThisWeek,
            new List<TaskCompletion>(),
            showCompletedTasks: false);

        // Assert
        Assert.False(result);
    }

    [Fact]
    public void ShouldShowTask_DuringWeek_ShowsOnCompletionDay_WithShowCompletedTasksTrue()
    {
        // Arrange
        var assignmentId = Guid.NewGuid();
        var assignment = new TaskAssignment
        {
            Id = assignmentId,
            ScheduleType = ScheduleType.DuringWeek
        };

        var completionsThisWeek = new List<TaskCompletion>
        {
            new TaskCompletion
            {
                TaskAssignmentId = assignmentId,
                Date = _today // Completed today
            }
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            completionsThisWeek,
            new List<TaskCompletion>(),
            showCompletedTasks: true);

        // Assert
        Assert.True(result);
    }

    [Fact]
    public void ShouldShowTask_DuringWeek_HidesAfterCompletionDay_WithShowCompletedTasksTrue()
    {
        // Arrange
        var assignmentId = Guid.NewGuid();
        var assignment = new TaskAssignment
        {
            Id = assignmentId,
            ScheduleType = ScheduleType.DuringWeek
        };

        var completionsThisWeek = new List<TaskCompletion>
        {
            new TaskCompletion
            {
                TaskAssignmentId = assignmentId,
                Date = new DateOnly(2026, 1, 20) // Completed earlier this week (Tuesday)
            }
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            completionsThisWeek,
            new List<TaskCompletion>(),
            showCompletedTasks: true);

        // Assert
        Assert.False(result);
    }

    [Fact]
    public void ShouldShowTask_DuringMonth_ShowsWhenNotCompleted()
    {
        // Arrange
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(),
            ScheduleType = ScheduleType.DuringMonth
        };

        var completionsThisMonth = new List<TaskCompletion>(); // No completions

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            new List<TaskCompletion>(),
            completionsThisMonth);

        // Assert
        Assert.True(result);
    }

    [Fact]
    public void ShouldShowTask_DuringMonth_HidesWhenCompletedThisMonth_WithShowCompletedTasksFalse()
    {
        // Arrange
        var assignmentId = Guid.NewGuid();
        var assignment = new TaskAssignment
        {
            Id = assignmentId,
            ScheduleType = ScheduleType.DuringMonth
        };

        var completionsThisMonth = new List<TaskCompletion>
        {
            new TaskCompletion
            {
                TaskAssignmentId = assignmentId,
                Date = new DateOnly(2026, 1, 10) // Completed earlier this month
            }
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            new List<TaskCompletion>(),
            completionsThisMonth,
            showCompletedTasks: false);

        // Assert
        Assert.False(result);
    }

    [Fact]
    public void ShouldShowTask_DuringMonth_ShowsOnCompletionDay_WithShowCompletedTasksTrue()
    {
        // Arrange
        var assignmentId = Guid.NewGuid();
        var assignment = new TaskAssignment
        {
            Id = assignmentId,
            ScheduleType = ScheduleType.DuringMonth
        };

        var completionsThisMonth = new List<TaskCompletion>
        {
            new TaskCompletion
            {
                TaskAssignmentId = assignmentId,
                Date = _today // Completed today
            }
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            new List<TaskCompletion>(),
            completionsThisMonth,
            showCompletedTasks: true);

        // Assert
        Assert.True(result);
    }

    [Fact]
    public void ShouldShowTask_DuringMonth_HidesAfterCompletionDay_WithShowCompletedTasksTrue()
    {
        // Arrange
        var assignmentId = Guid.NewGuid();
        var assignment = new TaskAssignment
        {
            Id = assignmentId,
            ScheduleType = ScheduleType.DuringMonth
        };

        var completionsThisMonth = new List<TaskCompletion>
        {
            new TaskCompletion
            {
                TaskAssignmentId = assignmentId,
                Date = new DateOnly(2026, 1, 10) // Completed earlier this month
            }
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            new List<TaskCompletion>(),
            completionsThisMonth,
            showCompletedTasks: true);

        // Assert
        Assert.False(result);
    }

    [Fact]
    public void ShouldShowTask_WithDueTime_ShowsBeforeDueTime()
    {
        // Arrange - Due time is 3:00 PM, current time is 2:30 PM
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(),
            ScheduleType = ScheduleType.Daily,
            DueTime = new TimeOnly(15, 0) // 3:00 PM
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime, // 2:30 PM
            _thursday,
            new List<TaskCompletion>(),
            new List<TaskCompletion>());

        // Assert
        Assert.True(result);
    }

    [Fact]
    public void ShouldShowTask_WithDueTime_HidesAfterDueTime()
    {
        // Arrange - Due time is 2:00 PM, current time is 2:30 PM
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(),
            ScheduleType = ScheduleType.Daily,
            DueTime = new TimeOnly(14, 0) // 2:00 PM
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime, // 2:30 PM
            _thursday,
            new List<TaskCompletion>(),
            new List<TaskCompletion>());

        // Assert
        Assert.False(result);
    }

    [Fact]
    public void ShouldShowTask_WithoutDueTime_AlwaysShows()
    {
        // Arrange - No due time set
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(),
            ScheduleType = ScheduleType.Daily,
            DueTime = null
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            new List<TaskCompletion>(),
            new List<TaskCompletion>());

        // Assert
        Assert.True(result);
    }

    [Fact]
    public void ShouldShowTask_InvalidScheduleType_ReturnsFalse()
    {
        // Arrange
        var assignment = new TaskAssignment
        {
            Id = Guid.NewGuid(),
            ScheduleType = (ScheduleType)999 // Invalid schedule type
        };

        // Act
        var result = TaskScheduleHelper.ShouldShowTask(
            assignment,
            _today,
            _currentTime,
            _thursday,
            new List<TaskCompletion>(),
            new List<TaskCompletion>());

        // Assert
        Assert.False(result);
    }
}
