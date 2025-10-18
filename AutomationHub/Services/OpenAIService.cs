using AutomationHub.Models;

namespace AutomationHub.Services
{
    public class OpenAIService
    {
        private readonly OpenAIClient _client;

        public OpenAIService(string apiKey)
        {
            _client = new OpenAIClient(apiKey);
        }

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