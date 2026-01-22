using System.Security.Claims;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
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
    private readonly ITaskService _taskService;

    public MeController(HomeBoardDbContext context, ITaskService taskService)
    {
        _context = context;
        _taskService = taskService;
    }

    [HttpGet("today")]
    public async Task<ActionResult<List<TodayTaskDto>>> GetTodayTasks()
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        try
        {
            var tasks = await _taskService.GetTodayTasksAsync(userId);
            return Ok(tasks);
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
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

