class ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
  });
}
