using AutomationHub.Models;
using OpenAI;

namespace AutomationHub.Services
{
    /// <summary>
    /// Service responsible for interacting with the OpenAI chat API.
    /// </summary>
    public class OpenAIService
    {
        private readonly OpenAIClient _client;

        /// <summary>
        /// Initializes a new instance of the <see cref="OpenAIService"/> class.
        /// </summary>
        /// <param name="apiKey">The API key used to authenticate with OpenAI.</param>
        public OpenAIService(string apiKey)
        {
            _client = new OpenAIClient(apiKey);
        }

        /// <summary>
        /// Sends a message to the model and returns the generated response.
        /// </summary>
        /// <param name="request">The request payload containing the user message.</param>
        /// <returns>A <see cref="ChatResponse"/> with the model reply and timestamp.</returns>
        public async Task<Models.ChatResponse> SendMessageAsync(Models.ChatRequest request)
        {
            var chatMessages = new List<ChatMessage>
            {
                new ChatMessage(ChatRole.User, request.Message ?? string.Empty)
            };

            var result = await _client.Chat.GetAsync("gpt-4o-mini", chatMessages);
            var reply = result.Value.Choices[0].Message.Content[0].Text;

            return new ChatResponse
            {
                Reply = reply,
                Timestamp = DateTime.Now
            };
        }
    }
}