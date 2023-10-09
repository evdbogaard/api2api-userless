using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;

using Api2Api.Api1.Handlers;

using Azure.Core;
using Azure.Identity;

using Microsoft.IdentityModel.Tokens;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddControllers();

TokenCredential credential = new AzureCliCredential();

// Second token
var key = "This is a sample secret key - please don't use in production environment.'";
var issuer = "http://localhost/";
var audience = "Erwin Demo Person";
var tokenHandler = new JwtSecurityTokenHandler();
var tokenDescriptor = new SecurityTokenDescriptor
{
    Expires = DateTime.UtcNow.AddMinutes(10),
    Subject = new ClaimsIdentity(new[] 
    {
        new Claim("id", "1"),
        new Claim(JwtRegisteredClaimNames.Email, "test@example.com"),
        new Claim(JwtRegisteredClaimNames.Sub, "test@example.com"),
        new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
    }),
    SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(Encoding.ASCII.GetBytes(key)), SecurityAlgorithms.HmacSha512Signature),
    Issuer = issuer,
    Audience = audience
};

var jwtToken = tokenHandler.CreateToken(tokenDescriptor);
var final = tokenHandler.WriteToken(jwtToken);
Console.WriteLine(final);

builder.Services.AddTransient(s => new AzureAuthHandler(credential, ["api://e3b0ed2b-9168-41d1-8a5c-44c31477ae89/.default"]));
builder.Services.AddSingleton(credential);
builder.Services.AddHttpClient("jwt", options =>
{
    options.BaseAddress = new Uri("https://localhost:7027/api/");
    options.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", final);
});

builder.Services.AddHttpClient("azure", options =>
{
    options.BaseAddress = new Uri("https://localhost:7027/api/");
}).AddHttpMessageHandler<AzureAuthHandler>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast")
.WithOpenApi();

app.MapControllers();

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}