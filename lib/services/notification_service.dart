import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import '../models/message_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseMessaging? _fcm;

  NotificationService() {
    if (!kIsWeb) {
      try {
        _fcm = FirebaseMessaging.instance;
        print('FirebaseMessaging initialized for mobile');
      } catch (e) {
        print('Error initializing FirebaseMessaging: $e');
      }
    } else {
      print('FirebaseMessaging skipped on web');
    }
  }

  Stream<List<Notification>> getNotifications(String userId) {
    try {
      print('Starting getNotifications for userId: $userId');
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots()
          .map((snapshot) {
        print('Received ${snapshot.docs.length} notifications');
        return snapshot.docs
            .map((doc) =>
                Notification.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList();
      }).handleError((e) {
        print('Error in getNotifications stream: $e');
        throw e;
      });
    } catch (e) {
      print('Error in getNotifications: $e');
      rethrow;
    }
  }

  Future<void> sendNotification(
      String userId, String body, String? videoLink) async {
    try {
      print('Starting sendNotification for userId: $userId');
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      final conversationId =
          '${userId}_${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}';
      print('Generated conversationId: $conversationId');

      // Lưu thông báo vào Firestore (hoạt động trên cả web và mobile)
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': 'New Message from Admin',
        'body': body,
        'videoLink': videoLink ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'fromAdmin': true,
        'conversationId': conversationId,
      });
      print('Notification stored in Firestore successfully');

      // Chỉ gửi thông báo đẩy qua FCM nếu không phải web
      if (!kIsWeb && _fcm != null) {
        try {
          await _fcm!.sendMessage(
            to: '/topics/$userId',
            data: {
              'title': 'New Message from Admin',
              'body': body,
              'videoLink': videoLink ?? '',
              'conversationId': conversationId,
              'notificationTitle': 'New Message from Admin',
              'notificationBody': body,
            },
          );
          print('FCM notification sent successfully');
        } catch (e) {
          print('Error sending FCM notification: $e');
        }
      } else {
        print('FCM skipped on web');
      }

      print('Notification process completed successfully');
    } catch (e) {
      print('Error in sendNotification: $e');
      rethrow;
    }
  }

  Stream<List<Message>> getMessages(String conversationId) {
    try {
      print('Starting getMessages for conversationId: $conversationId');
      return _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
        print('Received ${snapshot.docs.length} messages');
        return snapshot.docs
            .map((doc) =>
                Message.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList();
      }).handleError((e) {
        print('Error in getMessages stream: $e');
        throw e;
      });
    } catch (e) {
      print('Error in getMessages: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(
      String conversationId, String message, bool fromAdmin) async {
    try {
      print('Starting sendMessage for conversationId: $conversationId');
      await _firestore.collection('messages').add({
        'conversationId': conversationId,
        'message': message,
        'fromAdmin': fromAdmin,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
}
