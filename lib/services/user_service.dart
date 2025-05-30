import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy danh sách tất cả user và admin với Stream (realtime)
  Stream<List<UserModel>> getAllUsersStream() {
    try {
      print('Starting getAllUsersStream');
      return _firestore.collection('users').snapshots().map((snapshot) {
        final users =
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
        print('Received ${users.length} users');
        return users;
      }).handleError((e) {
        print('Error in getAllUsersStream: $e');
        throw e;
      });
    } catch (e) {
      print('Error in getAllUsersStream: $e');
      rethrow;
    }
  }

  // Lấy danh sách tất cả user và admin với Future (lần đầu)
  Future<List<UserModel>> getAllUsers() async {
    try {
      print('Starting getAllUsers');
      final snapshot = await _firestore.collection('users').get();
      final users =
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      print('Received ${users.length} users');
      return users;
    } catch (e) {
      print('Error in getAllUsers: $e');
      rethrow;
    }
  }
}
