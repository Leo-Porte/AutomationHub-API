using AutomationHub.Models;
using Microsoft.AspNetCore.Mvc;

namespace AutomationHub.Controller
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChatController : ControllerBase
    {
        private readonly Services.OpenAIService _openAIService;

        public ChatController(Services.OpenAIService openAIService)
        {
            _openAIService = openAIService;
        }

        [HttpPost("send")]
        public async Task<IActionResult> Send([FromBody] ChatRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Message))
                return BadRequest("Message cannot be empty.");

            var response = await _openAIService.SendMessageAsync(request);
            return Ok(response);
        }
    }
}