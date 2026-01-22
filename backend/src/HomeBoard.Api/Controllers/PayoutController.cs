using System.Security.Claims;
using HomeBoard.Api.Models;
using HomeBoard.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class PayoutController : ControllerBase
{
    private readonly IPayoutService _payoutService;

    public PayoutController(IPayoutService payoutService)
    {
        _payoutService = payoutService;
    }

    [HttpGet("preview")]
    public async Task<ActionResult<PayoutPreviewResponseDto>> GetPayoutPreview()
    {
        try
        {
            var preview = await _payoutService.GetPayoutPreviewAsync();
            return Ok(preview);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost("execute")]
    public async Task<ActionResult<ExecutePayoutResponseDto>> ExecutePayout([FromBody] ExecutePayoutRequest request)
    {
        var adminUserId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(adminUserId))
        {
            return Unauthorized();
        }

        try
        {
            var result = await _payoutService.ExecutePayoutAsync(request, Guid.Parse(adminUserId));
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
