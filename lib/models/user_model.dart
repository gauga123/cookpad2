import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    this.role = 'user', // Default role is user
  });

  bool get canWatchVideos => role == 'premium' || role == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id, // Lấy UID từ Document ID
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
    );
  }
}
