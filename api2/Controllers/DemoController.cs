using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ap2api.api2;

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

    [Authorize("Combined")]
    [HttpGet("Combined")]
    public string Combined() => "Combined endpoint";

    [Authorize("Azure")]
    [HttpGet("AzureAdOnly")]
    public string AzureOnly() => "Azure endpoint only";
}
