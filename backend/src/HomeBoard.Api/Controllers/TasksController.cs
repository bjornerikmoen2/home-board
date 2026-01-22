using System.Security.Claims;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TasksController : ControllerBase
{
    private readonly ITaskService _taskService;

    public TasksController(ITaskService taskService)
    {
        _taskService = taskService;
    }

    [HttpGet("definitions")]
    public async Task<ActionResult<List<TaskDefinitionDto>>> GetTaskDefinitions()
    {
        var definitions = await _taskService.GetTaskDefinitionsAsync();
        return Ok(definitions);
    }

    [HttpGet("assignments")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<TaskAssignmentDto>>> GetTaskAssignments()
    {
        var assignments = await _taskService.GetTaskAssignmentsAsync();
        return Ok(assignments);
    }

    [HttpPost("definitions")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<TaskDefinitionDto>> CreateTaskDefinition([FromBody] CreateTaskDefinitionRequest request)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var taskDefinition = await _taskService.CreateTaskDefinitionAsync(request, userId);
        return CreatedAtAction(nameof(GetTaskDefinitions), new { id = taskDefinition.Id }, taskDefinition);
    }

    [HttpPatch("definitions/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<TaskDefinitionDto>> UpdateTaskDefinition(Guid id, [FromBody] UpdateTaskDefinitionRequest request)
    {
        try
        {
            var taskDefinition = await _taskService.UpdateTaskDefinitionAsync(id, request);
            return Ok(taskDefinition);
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    [HttpDelete("definitions/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteTaskDefinition(Guid id)
    {
        try
        {
            await _taskService.DeleteTaskDefinitionAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    [HttpPost("assignments")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<TaskAssignmentDto>> CreateTaskAssignment([FromBody] CreateTaskAssignmentRequest request)
    {
        try
        {
            var assignment = await _taskService.CreateTaskAssignmentAsync(request);
            return CreatedAtAction(nameof(GetTaskDefinitions), new { id = assignment.Id }, assignment);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPatch("assignments/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<TaskAssignmentDto>> UpdateTaskAssignment(Guid id, [FromBody] UpdateTaskAssignmentRequest request)
    {
        try
        {
            var assignment = await _taskService.UpdateTaskAssignmentAsync(id, request);
            return Ok(assignment);
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("assignments/{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteTaskAssignment(Guid id)
    {
        try
        {
            await _taskService.DeleteTaskAssignmentAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    [HttpPost("{assignmentId}/complete")]
    public async Task<IActionResult> CompleteTask(Guid assignmentId, [FromBody] CompleteTaskRequest? request)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        try
        {
            var completionId = await _taskService.CompleteTaskAsync(assignmentId, userId, request);
            return Ok(new { message = "Task marked as completed", completionId });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpGet("calendar")]
    public async Task<ActionResult<List<CalendarTaskDto>>> GetCalendarTasks(
        [FromQuery] DateOnly startDate,
        [FromQuery] DateOnly endDate)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var isAdmin = User.IsInRole("Admin");

        try
        {
            var tasks = await _taskService.GetCalendarTasksAsync(startDate, endDate, userId, isAdmin);
            return Ok(tasks);
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }
}
