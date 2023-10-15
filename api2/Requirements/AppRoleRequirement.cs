using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

using Microsoft.AspNetCore.Authorization;

namespace api2api.api2;

public class AppRoleRequirement : AuthorizationHandler<AppRoleRequirement>, IAuthorizationRequirement
{
    public readonly string Id;

    public AppRoleRequirement(string id, string role)
    {
        ArgumentNullException.ThrowIfNullOrWhiteSpace(id);
        Id = id;
        Role = role;
    }

    public string Role { get; }

    protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, AppRoleRequirement requirement)
    {
        if (context.HasFailed)
            return Task.CompletedTask;

        var roles = context.User.Claims.Where(c => c.Type == "roles").ToList();
        var aud = context.User.Claims.Where(c => c.Type == JwtRegisteredClaimNames.Aud).FirstOrDefault();
        var roleClaims = context.User.Claims.Where(c => c.Type == ClaimTypes.Role).ToList();
        if (aud?.Value == requirement.Id && roleClaims.Select(rc => rc.Value).Contains(requirement.Role))
            context.Succeed(requirement);
        else
            context.Fail();

        return Task.CompletedTask;
    }
}
