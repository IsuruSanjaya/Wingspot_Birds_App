enum MessageType { text, image }

enum MessageStatus { sent, delivered, read }

class Message {
  final String content;
  final MessageType type;
  final bool isSent;
  final DateTime timestamp;
  final MessageStatus status;

  Message({
    required this.content,
    required this.type,
    required this.isSent,
    required this.timestamp,
    required this.status,
  });
}
