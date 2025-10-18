namespace AutomationHub.Models
{
    /// <summary>
    /// Represents a chat request payload.
    /// </summary>
    public class ChatRequest
    {
        /// <summary>
        /// The message content to send to the AI model.
        /// </summary>
        public string? Message { get; set; }
    }
}