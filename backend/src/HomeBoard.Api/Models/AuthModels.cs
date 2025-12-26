namespace HomeBoard.Api.Models;

public class LoginRequest
{
    public required string Username { get; set; }
    public string? Password { get; set; }
}

public class LoginResponse
{
    public required string AccessToken { get; set; }
    public required string RefreshToken { get; set; }
    public required UserDto User { get; set; }
}

public class RefreshTokenRequest
{
    public required string RefreshToken { get; set; }
}

public class UserDto
{
    public Guid Id { get; set; }
    public required string Username { get; set; }
    public required string DisplayName { get; set; }
    public required string Role { get; set; }
    public string PreferredLanguage { get; set; } = "en";
    public bool PrefersDarkMode { get; set; } = false;
    public bool NoPasswordRequired { get; set; } = false;
    public string? ProfileImageUrl { get; set; }
}

public class NoPasswordUserDto
{
    public Guid Id { get; set; }
    public required string Username { get; set; }
    public required string DisplayName { get; set; }
    public string? ProfileImageUrl { get; set; }
}
