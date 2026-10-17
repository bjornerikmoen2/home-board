using System.Net;
using System.Net.Sockets;

namespace HomeBoard.Api.Helpers;

/// <summary>
/// Tells requests from the internet apart from requests on the home network.
///
/// Requests through the Cloudflare Tunnel (or another public reverse proxy) carry the visitor's
/// public address in CF-Connecting-IP / X-Forwarded-For. Requests on the home network, through the
/// local reverse proxy, only carry private addresses. A caller can add these headers but can't
/// remove the ones Cloudflare sets, so faking them can only make a request look more "internet".
/// </summary>
public static class HomeNetwork
{
    private static readonly string[] AddressHeaders = { "CF-Connecting-IP", "X-Real-IP", "X-Forwarded-For" };

    /// <summary>True when the client, or any proxy on the way, has a public IP address.</summary>
    public static bool IsFromInternet(HttpRequest request)
    {
        var addresses = AddressHeaders
            .SelectMany(header => request.Headers[header])
            .SelectMany(value => (value ?? "").Split(','))
            .Select(address => address.Trim())
            .Where(address => address.Length > 0)
            .ToList();
        if (request.HttpContext.Connection.RemoteIpAddress is { } remote)
        {
            addresses.Add(remote.ToString());
        }
        return addresses.Any(address => IPAddress.TryParse(WithoutPort(address), out var ip) && IsPublic(ip));
    }

    /// <summary>
    /// The client's address, for per-client limits: Cloudflare's CF-Connecting-IP (which a caller
    /// can't fake), else the first X-Forwarded-For entry (set by the local reverse proxy), else
    /// X-Real-IP, else the connection's address.
    /// </summary>
    public static string ClientAddress(HttpRequest request)
    {
        foreach (var header in new[] { "CF-Connecting-IP", "X-Forwarded-For", "X-Real-IP" })
        {
            var first = request.Headers[header].ToString().Split(',')[0].Trim();
            if (IPAddress.TryParse(WithoutPort(first), out var ip))
            {
                return ip.ToString();
            }
        }
        return request.HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
    }

    /// <summary>False for loopback, private (RFC 1918, IPv6 unique-local), link-local and CGNAT addresses.</summary>
    public static bool IsPublic(IPAddress ip)
    {
        if (ip.IsIPv4MappedToIPv6)
        {
            ip = ip.MapToIPv4();
        }
        if (IPAddress.IsLoopback(ip) || ip.Equals(IPAddress.Any) || ip.Equals(IPAddress.IPv6Any))
        {
            return false;
        }
        if (ip.AddressFamily == AddressFamily.InterNetworkV6)
        {
            return !(ip.IsIPv6LinkLocal || ip.IsIPv6SiteLocal || ip.IsIPv6UniqueLocal);
        }
        var b = ip.GetAddressBytes();
        var isPrivate = b[0] == 10
            || (b[0] == 172 && b[1] >= 16 && b[1] <= 31)
            || (b[0] == 192 && b[1] == 168)
            || (b[0] == 169 && b[1] == 254)
            || (b[0] == 100 && b[1] >= 64 && b[1] <= 127)
            || b[0] == 0;
        return !isPrivate;
    }

    private static string WithoutPort(string address)
    {
        if (address.StartsWith('['))
        {
            var end = address.IndexOf(']');
            return end > 0 ? address[1..end] : address;
        }
        // "1.2.3.4:5678"; a bare IPv6 address has more than one colon
        return address.Count(c => c == ':') == 1 ? address[..address.IndexOf(':')] : address;
    }
}
