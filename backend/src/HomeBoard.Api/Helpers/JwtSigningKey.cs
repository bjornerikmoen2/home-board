using System.Text;

namespace HomeBoard.Api.Helpers;

/// <summary>
/// The key that signs the login tokens (setting Jwt:SigningKey, environment variable
/// Jwt__SigningKey). There is no default: anyone who knows the key can make Admin tokens, so a
/// key from a public file must never be used.
/// </summary>
public static class JwtSigningKey
{
    public const int MinimumBytes = 32;

    /// <summary>The key's bytes; throws when it is missing or shorter than 32 bytes (256 bits, for HS256).</summary>
    public static byte[] Read(IConfiguration configuration)
    {
        var key = configuration["Jwt:SigningKey"];
        if (string.IsNullOrWhiteSpace(key))
        {
            throw new InvalidOperationException(
                "Jwt:SigningKey is not set. Set the Jwt__SigningKey environment variable (e.g. openssl rand -base64 48), " +
                "or for local development: dotnet user-secrets set Jwt:SigningKey <key>");
        }
        var bytes = Encoding.UTF8.GetBytes(key);
        if (bytes.Length < MinimumBytes)
        {
            throw new InvalidOperationException($"Jwt:SigningKey must be at least {MinimumBytes} bytes long");
        }
        return bytes;
    }
}
