namespace HomeBoard.Api.Models;

public class LoginRequest
{
    public required string Username { get; set; }
    public required string Password { get; set; }
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
}
