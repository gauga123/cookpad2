import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart' as custom_notification;
import 'package:url_launcher/url_launcher.dart';

class MessageScreen extends StatefulWidget {
  final String conversationId;
  final String userId;

  const MessageScreen({
    super.key,
    required this.conversationId,
    required this.userId,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _messageController = TextEditingController();

  Future<custom_notification.Notification?> _getNotification() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('notifications')
        .where('conversationId', isEqualTo: widget.conversationId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return custom_notification.Notification.fromFirestore(
          snapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323),
        title: const Text(
          'Nhắn tin với Admin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Hiển thị thông báo gốc (bao gồm videoLink)
          FutureBuilder<custom_notification.Notification?>(
            future: _getNotification(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                      child: Text('Không tìm thấy thông báo gốc',
                          style: TextStyle(color: Colors.white70))),
                );
              }

              final notification = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.orangeAccent,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 8.0),
                          const Text(
                            'Cookpad Vũ Tính - Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        notification.body,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (notification.videoLink != null &&
                          notification.videoLink!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: InkWell(
                            onTap: () async {
                              final url = Uri.parse(notification.videoLink!);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.platformDefault);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Không thể mở liên kết video'),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Xem video',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8.0),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Danh sách tin nhắn
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _notificationService.getMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white70)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Không có tin nhắn nào.',
                          style: TextStyle(color: Colors.white70)));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isFromAdmin = message.fromAdmin;
                    return Align(
                      alignment: isFromAdmin
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isFromAdmin
                              ? Colors.grey[800]
                              : Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.message,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              _formatTimestamp(message.timestamp),
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Gửi tin nhắn
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: const Color(0xFF2C2C2C),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.orangeAccent),
            onPressed: () async {
              if (_messageController.text.trim().isNotEmpty) {
                await _notificationService.sendMessage(
                  widget.conversationId,
                  _messageController.text.trim(),
                  false, // Người dùng gửi, không phải admin
                );
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Vừa xong';
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
