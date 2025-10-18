namespace AutomationHub.Models
{
    public class ChatResponse
    {
        public string? Reply { get; set; }
        public DateTime Timestamp { get; set; } = DateTime.Now;
    }
}