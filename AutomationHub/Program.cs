using AutomationHub.Infrastructure.Swagger;
using AutomationHub.Services;
using OpenAI.Chat;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddSwaggerDocumentation();

// OpenAIService configuration
builder.Services.AddSingleton<ChatClient>(sp =>
{
    var cfg = sp.GetRequiredService<IConfiguration>();
    var apiKey = cfg["OpenAI:ApiKey"];
    return new ChatClient(model: "gpt-4o-mini", apiKey: apiKey);
});

var app = builder.Build();

app.UseSwaggerDocumentation();
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();