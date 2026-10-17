namespace HomeBoard.Domain.Entities;

/// <summary>
/// A refresh token handed out at login, which gets a new access token when the old one expires.
/// Only its SHA-256 hash is stored. Each use replaces it with a new token, and logging out or a
/// password reset revokes it.
/// </summary>
public class RefreshToken
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public required string TokenHash { get; set; }

    /// <summary>
    /// Issued for a login without a password (a child on the family tablet), so it only works
    /// where passwordless login does.
    /// </summary>
    public bool Passwordless { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime ExpiresAt { get; set; }
    public DateTime? RevokedAt { get; set; }

    // Navigation properties
    public User? User { get; set; }
}
