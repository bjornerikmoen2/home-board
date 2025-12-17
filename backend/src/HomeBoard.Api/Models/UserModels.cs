using HomeBoard.Domain.Enums;

namespace HomeBoard.Api.Models;

public class CreateUserRequest
{
    public required string Username { get; set; }
    public required string DisplayName { get; set; }
    public required string Password { get; set; }
    public UserRole Role { get; set; }
}

public class UpdateUserRequest
{
    public string? DisplayName { get; set; }
    public bool? IsActive { get; set; }
    public UserRole? Role { get; set; }
}

public class ResetPasswordRequest
{
    public required string NewPassword { get; set; }
}
