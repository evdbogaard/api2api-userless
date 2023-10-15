using System.IdentityModel.Tokens.Jwt;
using System.Security;
using System.Security.Claims;

using Microsoft.AspNetCore.Authorization;

namespace api2api.api2;

public class AppRoleOrJwtRequirement : AuthorizationHandler<AppRoleOrJwtRequirement>, IAuthorizationRequirement
{
    public string Id { get; set; }
    public string Role { get; }

    public AppRoleOrJwtRequirement(string id, string role)
    {
        ArgumentNullException.ThrowIfNullOrWhiteSpace(id);
        Id = id;
        Role = role;
    }

    protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, AppRoleOrJwtRequirement requirement)
    {
        if (context.HasFailed)
            return Task.CompletedTask;

        var aud = context.User.Claims.Where(c => c.Type == JwtRegisteredClaimNames.Aud).FirstOrDefault();
        if (aud == null)
            throw new SecurityException("No valid claim");

        if (aud.Value == requirement.Id)
        {
            var roleClaims = context.User.Claims.Where(c => c.Type == ClaimTypes.Role).ToList();
            if (roleClaims.Select(rc => rc.Value).Contains(requirement.Role))
                context.Succeed(requirement);
            else
                context.Fail();
        }
        else
        {
            // Checks for JWT
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}
