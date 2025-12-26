using HomeBoard.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeBoard.Infrastructure.Data;

public class HomeBoardDbContext : DbContext
{
    public HomeBoardDbContext(DbContextOptions<HomeBoardDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<TaskDefinition> TaskDefinitions => Set<TaskDefinition>();
    public DbSet<TaskAssignment> TaskAssignments => Set<TaskAssignment>();
    public DbSet<TaskCompletion> TaskCompletions => Set<TaskCompletion>();
    public DbSet<PointsLedger> PointsLedger => Set<PointsLedger>();
    public DbSet<Reward> Rewards => Set<Reward>();
    public DbSet<RewardRedemption> RewardRedemptions => Set<RewardRedemption>();
    public DbSet<FamilySettings> FamilySettings => Set<FamilySettings>();
    public DbSet<UserPayoutState> UserPayoutStates => Set<UserPayoutState>();
    public DbSet<Payout> Payouts => Set<Payout>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // User configuration
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Username).IsRequired().HasMaxLength(100);
            entity.HasIndex(e => e.Username).IsUnique();
            entity.Property(e => e.DisplayName).IsRequired().HasMaxLength(200);
            entity.Property(e => e.PasswordHash).IsRequired();
            entity.Property(e => e.Role).IsRequired();
            entity.Property(e => e.IsActive).IsRequired();
            entity.Property(e => e.CreatedAt).IsRequired();

            entity.HasMany(e => e.CreatedTaskDefinitions)
                .WithOne(e => e.CreatedByUser)
                .HasForeignKey(e => e.CreatedByUserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasMany(e => e.AssignedTasks)
                .WithOne(e => e.AssignedToUser)
                .HasForeignKey(e => e.AssignedToUserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasMany(e => e.CompletedTasks)
                .WithOne(e => e.CompletedByUser)
                .HasForeignKey(e => e.CompletedByUserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasMany(e => e.PointsEntries)
                .WithOne(e => e.User)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasMany(e => e.RewardRedemptions)
                .WithOne(e => e.User)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // TaskDefinition configuration
        modelBuilder.Entity<TaskDefinition>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.DefaultPoints).IsRequired();
            entity.Property(e => e.IsActive).IsRequired();
            entity.Property(e => e.CreatedAt).IsRequired();
        });

        // TaskAssignment configuration
        modelBuilder.Entity<TaskAssignment>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.ScheduleType).IsRequired();
            entity.Property(e => e.DaysOfWeek).IsRequired();
            entity.Property(e => e.IsActive).IsRequired();
            entity.Property(e => e.CreatedAt).IsRequired();

            entity.HasOne(e => e.TaskDefinition)
                .WithMany(e => e.Assignments)
                .HasForeignKey(e => e.TaskDefinitionId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // TaskCompletion configuration
        modelBuilder.Entity<TaskCompletion>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Date).IsRequired();
            entity.Property(e => e.CompletedAt).IsRequired();
            entity.Property(e => e.Status).IsRequired();
            entity.Property(e => e.RejectionReason).HasMaxLength(500);

            entity.HasOne(e => e.TaskAssignment)
                .WithMany(e => e.Completions)
                .HasForeignKey(e => e.TaskAssignmentId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.VerifiedByUser)
                .WithMany()
                .HasForeignKey(e => e.VerifiedByUserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Unique constraint: one completion per assignment per date
            entity.HasIndex(e => new { e.TaskAssignmentId, e.Date }).IsUnique();
        });

        // PointsLedger configuration
        modelBuilder.Entity<PointsLedger>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.SourceType).IsRequired();
            entity.Property(e => e.PointsDelta).IsRequired();
            entity.Property(e => e.Note).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).IsRequired();

            entity.HasOne(e => e.CreatedByUser)
                .WithMany()
                .HasForeignKey(e => e.CreatedByUserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Index for efficient points calculation
            entity.HasIndex(e => new { e.UserId, e.CreatedAt });
        });

        // Reward configuration
        modelBuilder.Entity<Reward>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.CostPoints).IsRequired();
            entity.Property(e => e.IsActive).IsRequired();
            entity.Property(e => e.CreatedAt).IsRequired();
        });

        // RewardRedemption configuration
        modelBuilder.Entity<RewardRedemption>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.RedeemedAt).IsRequired();
            entity.Property(e => e.Status).IsRequired();

            entity.HasOne(e => e.Reward)
                .WithMany(e => e.Redemptions)
                .HasForeignKey(e => e.RewardId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.HandledByUser)
                .WithMany()
                .HasForeignKey(e => e.HandledByUserId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // FamilySettings configuration
        modelBuilder.Entity<FamilySettings>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Timezone).IsRequired().HasMaxLength(100);
            entity.Property(e => e.PointToMoneyRate).IsRequired().HasColumnType("decimal(18,2)");
            entity.Property(e => e.WeekStartsOn).IsRequired();
        });

        // UserPayoutState configuration
        modelBuilder.Entity<UserPayoutState>(entity =>
        {
            entity.HasKey(e => e.UserId);
            entity.Property(e => e.UpdatedAt).IsRequired();

            entity.HasOne(e => e.User)
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Payout configuration
        modelBuilder.Entity<Payout>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.PeriodStart).IsRequired();
            entity.Property(e => e.PeriodEnd).IsRequired();
            entity.Property(e => e.NetPoints).IsRequired();
            entity.Property(e => e.PointToMoneyRate).IsRequired().HasColumnType("decimal(12,4)");
            entity.Property(e => e.MoneyPaid).IsRequired().HasColumnType("decimal(12,2)");
            entity.Property(e => e.PaidAt).IsRequired();
            entity.Property(e => e.Note).HasMaxLength(500);

            entity.HasOne(e => e.User)
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.PaidByUser)
                .WithMany()
                .HasForeignKey(e => e.PaidByUserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Index for efficient querying by user and date
            entity.HasIndex(e => new { e.UserId, e.PaidAt });
        });
    }
}
