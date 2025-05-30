class Message {
  final String conversationId;
  final String message;
  final bool fromAdmin;
  final DateTime? timestamp;

  Message({
    required this.conversationId,
    required this.message,
    required this.fromAdmin,
    this.timestamp,
  });

  factory Message.fromFirestore(Map<String, dynamic> data) {
    return Message(
      conversationId: data['conversationId'] ?? '',
      message: data['message'] ?? '',
      fromAdmin: data['fromAdmin'] ?? false,
      timestamp:
          data['timestamp']?.toDate(), // Chuyển đổi Timestamp sang DateTime
    );
  }
}
