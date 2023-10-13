using System.IdentityModel.Tokens.Jwt;

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

        var aud = context.User.Claims.Where(c => c.Type == JwtRegisteredClaimNames.Aud).First();
        if (aud.Value == $"api://{requirement.Id}")
        {
            var roleClaim = context.User.Claims.Where(c => c.Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/role").FirstOrDefault();
            if (roleClaim != null && roleClaim.Value == requirement.Role)
                context.Succeed(requirement);
            else
                context.Fail();
        }
        else
        {
            // Some other checks?
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}
