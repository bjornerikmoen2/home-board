using System.Security.Claims;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet]
    public async Task<ActionResult<List<UserDto>>> GetUsers()
    {
        var users = await _userService.GetUsersAsync();
        return Ok(users);
    }

    [HttpPost]
    public async Task<ActionResult<UserDto>> CreateUser([FromForm] CreateUserRequest request)
    {
        try
        {
            var user = await _userService.CreateUserAsync(request);
            return CreatedAtAction(nameof(GetUsers), new { id = user.Id }, user);
        }
        catch (InvalidOperationException ex)
        {
            if (ex.Message.Contains("already exists"))
            {
                return Conflict(new { message = ex.Message });
            }
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPatch("{id}")]
    public async Task<ActionResult<UserDto>> UpdateUser(Guid id, [FromForm] UpdateUserRequest request)
    {
        try
        {
            var user = await _userService.UpdateUserAsync(id, request);
            return Ok(user);
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

    [HttpPost("{id}/reset-password")]
    public async Task<IActionResult> ResetPassword(Guid id, [FromBody] ResetPasswordRequest request)
    {
        try
        {
            await _userService.ResetPasswordAsync(id, request.NewPassword);
            return Ok(new { message = "Password reset successfully" });
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    [HttpPost("{id}/reset-points")]
    public async Task<IActionResult> ResetPoints(Guid id)
    {
        var adminUserId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(adminUserId))
        {
            return Unauthorized();
        }

        try
        {
            var pointsReset = await _userService.ResetPointsAsync(id, Guid.Parse(adminUserId));
            return Ok(new { message = "Points reset successfully", pointsReset });
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    [HttpPost("{id}/bonus-points")]
    public async Task<IActionResult> AwardBonusPoints(Guid id, [FromBody] BonusPointsRequest request)
    {
        var adminUserId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(adminUserId))
        {
            return Unauthorized();
        }

        try
        {
            var pointsAwarded = await _userService.AwardBonusPointsAsync(id, request.Points, request.Description, Guid.Parse(adminUserId));
            return Ok(new { message = "Bonus points awarded successfully", pointsAwarded });
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

    [HttpGet("{id}/profile-image")]
    [AllowAnonymous]
    public async Task<IActionResult> GetProfileImage(Guid id)
    {
        var profileImage = await _userService.GetProfileImageAsync(id);
        if (profileImage == null)
        {
            return NotFound();
        }

        var contentType = await _userService.GetProfileImageContentTypeAsync(id);
        return File(profileImage, contentType ?? "image/jpeg");
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUser(Guid id)
    {
        try
        {
            await _userService.DeleteUserAsync(id);
            return NoContent();
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
}
