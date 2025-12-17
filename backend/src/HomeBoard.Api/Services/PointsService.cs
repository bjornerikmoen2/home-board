using HomeBoard.Domain.Entities;
using HomeBoard.Domain.Enums;
using HomeBoard.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Api.Services;

public interface IPointsService
{
    Task<int> GetUserTotalPointsAsync(Guid userId);
    Task<List<PointsLedger>> GetUserPointsHistoryAsync(Guid userId, int limit = 50);
    Task<Dictionary<Guid, int>> GetLeaderboardAsync(DateTime? fromDate = null);
    Task AddPointsAsync(Guid userId, PointSourceType sourceType, int points, Guid? sourceId, string? note, Guid createdByUserId);
}

public class PointsService : IPointsService
{
    private readonly HomeBoardDbContext _context;

    public PointsService(HomeBoardDbContext context)
    {
        _context = context;
    }

    public async Task<int> GetUserTotalPointsAsync(Guid userId)
    {
        var total = await _context.PointsLedger
            .Where(p => p.UserId == userId)
            .SumAsync(p => p.PointsDelta);

        return total;
    }

    public async Task<List<PointsLedger>> GetUserPointsHistoryAsync(Guid userId, int limit = 50)
    {
        return await _context.PointsLedger
            .Where(p => p.UserId == userId)
            .OrderByDescending(p => p.CreatedAt)
            .Take(limit)
            .ToListAsync();
    }

    public async Task<Dictionary<Guid, int>> GetLeaderboardAsync(DateTime? fromDate = null)
    {
        var query = _context.PointsLedger.AsQueryable();

        if (fromDate.HasValue)
        {
            query = query.Where(p => p.CreatedAt >= fromDate.Value);
        }

        var leaderboard = await query
            .GroupBy(p => p.UserId)
            .Select(g => new { UserId = g.Key, TotalPoints = g.Sum(p => p.PointsDelta) })
            .ToDictionaryAsync(x => x.UserId, x => x.TotalPoints);

        return leaderboard;
    }

    public async Task AddPointsAsync(Guid userId, PointSourceType sourceType, int points, Guid? sourceId, string? note, Guid createdByUserId)
    {
        var entry = new PointsLedger
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            SourceType = sourceType,
            SourceId = sourceId,
            PointsDelta = points,
            Note = note,
            CreatedByUserId = createdByUserId,
            CreatedAt = DateTime.UtcNow
        };

        _context.PointsLedger.Add(entry);
        await _context.SaveChangesAsync();
    }
}
