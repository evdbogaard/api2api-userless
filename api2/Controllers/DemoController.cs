using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ap2api.api2;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class DemoController
{
    [HttpGet]
    public async Task<string> DemoCall()
    {
        await Task.CompletedTask;
        return "success";
    }
}
