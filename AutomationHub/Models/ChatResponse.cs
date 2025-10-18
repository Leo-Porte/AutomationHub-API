namespace AutomationHub.Models
{
    /// <summary>
    /// Represents a chat response payload.
    /// </summary>
    public class ChatResponse
    {
        /// <summary>
        /// The reply content returned by the AI model.
        /// </summary>
        public string? Reply { get; set; }

        /// <summary>
        /// The timestamp when the response was generated.
        /// </summary>
        public DateTime Timestamp { get; set; } = DateTime.Now;
    }
}