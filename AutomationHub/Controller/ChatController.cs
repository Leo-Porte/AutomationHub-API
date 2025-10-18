using AutomationHub.Models;
using Microsoft.AspNetCore.Mvc;

namespace AutomationHub.Controllers
{
    /// <summary>
    /// Controller responsible for chat interactions with the OpenAI service.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class ChatController : ControllerBase
    {
        private readonly Services.OpenAIService _openAIService;

        /// <summary>
        /// Initializes a new instance of <see cref="ChatController"/>.
        /// </summary>
        /// <param name="openAIService">The OpenAI service dependency.</param>
        public ChatController(Services.OpenAIService openAIService)
        {
            _openAIService = openAIService;
        }

        /// <summary>
        /// Sends a message to the OpenAI model and returns its response.
        /// </summary>
        /// <param name="request">The chat message payload.</param>
        /// <returns>Returns the generated reply from the model.</returns>
        /// <response code="200">Message processed successfully.</response>
        /// <response code="400">The message is invalid.</response>
        [HttpPost("send")]
        [ProducesResponseType(typeof(ChatResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Send([FromBody] ChatRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Message))
                return BadRequest("Message cannot be empty.");

            var response = await _openAIService.SendMessageAsync(request);
            return Ok(response);
        }
    }
}