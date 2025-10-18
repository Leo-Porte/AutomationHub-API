using AutomationHub.Models;
using AutomationHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace AutomationHub.Controllers
{
    /// <summary>
    /// Controller responsible for chat interactions with the OpenAI service.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
    public class ChatController : ControllerBase
    {
        private readonly OpenAIService _openAIService;

        /// <summary>
        /// Initializes a new instance of the <see cref="ChatController"/>.
        /// </summary>
        /// <param name="openAIService">The injected OpenAI service.</param>
        public ChatController(OpenAIService openAIService)
        {
            _openAIService = openAIService ?? throw new ArgumentNullException(nameof(openAIService));
        }

        /// <summary>
        /// Sends a message to the OpenAI model and returns its response.
        /// </summary>
        /// <param name="request">The chat message payload.</param>
        /// <returns>Returns the generated reply from the model.</returns>
        /// <response code="200">Message processed successfully.</response>
        /// <response code="400">The message is invalid.</response>
        /// <response code="500">Internal server error when communicating with OpenAI.</response>
        [HttpPost("send")]
        [ProducesResponseType(typeof(ChatResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> Send([FromBody] ChatRequest request)
        {
            if (string.IsNullOrWhiteSpace(request?.Message))
                return BadRequest("Message cannot be empty.");

            try
            {
                var response = await _openAIService.SendMessageAsync(request);
                return Ok(response);
            }
            catch (Exception ex)
            {
                // Logging pode ser adicionado aqui com ILogger
                return StatusCode(StatusCodes.Status500InternalServerError,
                    $"An error occurred while processing the request: {ex.Message}");
            }
        }
    }
}