class Notification {
  final String title;
  final String body;
  final String? videoLink;
  final DateTime? timestamp;
  final bool fromAdmin;
  final String conversationId;

  Notification({
    required this.title,
    required this.body,
    this.videoLink,
    this.timestamp,
    required this.fromAdmin,
    required this.conversationId,
  });

  factory Notification.fromFirestore(Map<String, dynamic> data) {
    return Notification(
      title: data['title'] ?? 'No Title',
      body: data['body'] ?? 'No Body',
      videoLink: data['videoLink'],
      timestamp:
          data['timestamp']?.toDate(), // Chuyển đổi Timestamp sang DateTime
      fromAdmin: data['fromAdmin'] ?? false,
      conversationId: data['conversationId'] ?? '',
    );
  }
}
