using HomeBoard.Domain.Enums;

namespace HomeBoard.Api.Models;

public class CreateUserRequest
{
    public required string Username { get; set; }
    public required string DisplayName { get; set; }
    public string? Password { get; set; }
    public UserRole Role { get; set; }
    public bool NoPasswordRequired { get; set; } = false;
    public string PreferredLanguage { get; set; } = "en";
    public IFormFile? ProfileImage { get; set; }
}

public class UpdateUserRequest
{
    public string? DisplayName { get; set; }
    public bool? IsActive { get; set; }
    public UserRole? Role { get; set; }
    public bool? NoPasswordRequired { get; set; }
    public string? PreferredLanguage { get; set; }
    public bool? PrefersDarkMode { get; set; }
    public IFormFile? ProfileImage { get; set; }
    public bool? RemoveProfileImage { get; set; }
}

public class ResetPasswordRequest
{
    public required string NewPassword { get; set; }
}

public class BonusPointsRequest
{
    public required int Points { get; set; }
    public string? Description { get; set; }
}
