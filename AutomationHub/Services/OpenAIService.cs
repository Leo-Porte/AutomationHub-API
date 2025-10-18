using OpenAI.Chat;
using AutomationHub.Models;

namespace AutomationHub.Services
{
    public class OpenAIService
    {
        private readonly ChatClient _chat;

        public OpenAIService(ChatClient chat) => _chat = chat;

        public async Task<ChatResponse> SendMessageAsync(ChatRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Message))
                return new ChatResponse { Reply = "Empty message received." };

            ChatCompletion completion = await _chat.CompleteChatAsync(request.Message!);
            string reply = completion.Content.Count > 0
                ? completion.Content[0].Text
                : "No response from OpenAI.";

            return new ChatResponse { Reply = reply, Timestamp = DateTime.Now };
        }
    }
}