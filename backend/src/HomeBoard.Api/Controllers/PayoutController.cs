using HomeBoard.Api.Models;
using HomeBoard.Domain.Entities;
using HomeBoard.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace HomeBoard.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class PayoutController : ControllerBase
{
    private readonly HomeBoardDbContext _context;

    public PayoutController(HomeBoardDbContext context)
    {
        _context = context;
    }

    [HttpGet("preview")]
    public async Task<ActionResult<PayoutPreviewResponseDto>> GetPayoutPreview()
    {
        // Get family settings for rate
        var settings = await _context.FamilySettings.FirstOrDefaultAsync();
        if (settings == null)
        {
            return BadRequest(new { message = "Family settings not found. Please configure point-to-money rate first." });
        }

        var rate = settings.PointToMoneyRate;
        var now = DateTime.UtcNow;

        // Get all active users
        var users = await _context.Users
            .Where(u => u.IsActive)
            .ToListAsync();

        var userPayouts = new List<PayoutPreviewDto>();

        foreach (var user in users)
        {
            // Get user's payout state
            var payoutState = await _context.UserPayoutStates
                .FirstOrDefaultAsync(p => p.UserId == user.Id);

            var lastPayoutAt = payoutState?.LastPayoutAt;
            var periodStart = lastPayoutAt ?? DateTime.MinValue;
            var periodEnd = now;

            // Calculate net points for the period (includes all transactions)
            var netPoints = await _context.PointsLedger
                .Where(p => p.UserId == user.Id 
                    && p.CreatedAt > periodStart 
                    && p.CreatedAt <= periodEnd)
                .SumAsync(p => (int?)p.PointsDelta) ?? 0;

            // Calculate money to pay (max of netPoints and 0)
            var payablePoints = Math.Max(netPoints, 0);
            var moneyToPay = payablePoints * rate;

            userPayouts.Add(new PayoutPreviewDto
            {
                UserId = user.Id,
                DisplayName = user.DisplayName,
                LastPayoutAt = lastPayoutAt,
                PeriodStart = periodStart,
                PeriodEnd = periodEnd,
                NetPointsSinceLastPayout = netPoints,
                PointToMoneyRate = rate,
                MoneyToPay = moneyToPay
            });
        }

        var response = new PayoutPreviewResponseDto
        {
            UserPayouts = userPayouts,
            TotalMoneyToPay = userPayouts.Sum(p => p.MoneyToPay),
            PointToMoneyRate = rate
        };

        return Ok(response);
    }

    [HttpPost("execute")]
    public async Task<ActionResult<ExecutePayoutResponseDto>> ExecutePayout([FromBody] ExecutePayoutRequest request)
    {
        // Get current admin user ID
        var adminUserId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(adminUserId))
        {
            return Unauthorized();
        }

        var adminGuid = Guid.Parse(adminUserId);

        // Get family settings for rate
        var settings = await _context.FamilySettings.FirstOrDefaultAsync();
        if (settings == null)
        {
            return BadRequest(new { message = "Family settings not found. Please configure point-to-money rate first." });
        }

        var rate = settings.PointToMoneyRate;
        var now = DateTime.UtcNow;

        // Get users to process
        IQueryable<User> usersQuery = _context.Users.Where(u => u.IsActive);
        if (request.UserIds != null && request.UserIds.Any())
        {
            usersQuery = usersQuery.Where(u => request.UserIds.Contains(u.Id));
        }

        var users = await usersQuery.ToListAsync();

        var createdPayouts = new List<PayoutDto>();

        // Use transaction to ensure atomicity
        using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            foreach (var user in users)
            {
                // Get user's payout state
                var payoutState = await _context.UserPayoutStates
                    .FirstOrDefaultAsync(p => p.UserId == user.Id);

                var lastPayoutAt = payoutState?.LastPayoutAt;
                var periodStart = lastPayoutAt ?? DateTime.MinValue;
                var periodEnd = now;

                // Calculate net points for the period
                var netPoints = await _context.PointsLedger
                    .Where(p => p.UserId == user.Id 
                        && p.CreatedAt > periodStart 
                        && p.CreatedAt <= periodEnd)
                    .SumAsync(p => (int?)p.PointsDelta) ?? 0;

                // Calculate money paid
                var payablePoints = Math.Max(netPoints, 0);
                var moneyPaid = payablePoints * rate;

                // Create payout record only if netPoints != 0 or moneyPaid != 0
                if (netPoints != 0 || moneyPaid != 0)
                {
                    var payout = new Payout
                    {
                        Id = Guid.NewGuid(),
                        UserId = user.Id,
                        PeriodStart = periodStart,
                        PeriodEnd = periodEnd,
                        NetPoints = netPoints,
                        PointToMoneyRate = rate,
                        MoneyPaid = moneyPaid,
                        PaidByUserId = adminGuid,
                        PaidAt = now,
                        Note = request.Note
                    };

                    _context.Payouts.Add(payout);

                    createdPayouts.Add(new PayoutDto
                    {
                        Id = payout.Id,
                        UserId = user.Id,
                        DisplayName = user.DisplayName,
                        PeriodStart = payout.PeriodStart,
                        PeriodEnd = payout.PeriodEnd,
                        NetPoints = payout.NetPoints,
                        PointToMoneyRate = payout.PointToMoneyRate,
                        MoneyPaid = payout.MoneyPaid,
                        PaidAt = payout.PaidAt,
                        Note = payout.Note
                    });
                }

                // Always update LastPayoutAt to close the period
                if (payoutState == null)
                {
                    payoutState = new UserPayoutState
                    {
                        UserId = user.Id,
                        LastPayoutAt = now,
                        UpdatedAt = now
                    };
                    _context.UserPayoutStates.Add(payoutState);
                }
                else
                {
                    payoutState.LastPayoutAt = now;
                    payoutState.UpdatedAt = now;
                }
            }

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            var response = new ExecutePayoutResponseDto
            {
                Payouts = createdPayouts,
                TotalMoneyPaid = createdPayouts.Sum(p => p.MoneyPaid),
                UsersProcessed = users.Count
            };

            return Ok(response);
        }
        catch (Exception)
        {
            await transaction.RollbackAsync();
            throw;
        }
    }
}
