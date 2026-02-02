import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore Service để quản lý database operations
/// Xử lý tất cả các thao tác với Firestore Database
class FirestoreService {
  // Singleton pattern
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  static const String usersCollection = 'users';

  /// Tạo hoặc cập nhật user profile trong Firestore
  /// 
  /// Parameters:
  /// - [uid]: User ID từ Firebase Authentication
  /// - [email]: Email của user
  /// - [role]: Role của user (admin, teacher, student, parent)
  /// - [name]: Tên đầy đủ của user (optional)
  /// - [avatarUrl]: URL avatar (optional)
  /// 
  /// Returns: Future<void>
  /// Throws: Exception nếu có lỗi
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String role,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final userData = {
        'email': email,
        'name': name ?? email.split('@')[0], // Default name từ email
        'role': role,
        'avatarUrl': avatarUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(usersCollection)
          .doc(uid)
          .set(userData, SetOptions(merge: true));

      print('✅ User profile created/updated: $uid');
    } catch (e) {
      print('❌ Error creating user profile: $e');
      throw Exception('Không thể tạo user profile: $e');
    }
  }

  /// Lấy thông tin user từ Firestore
  /// 
  /// Parameters:
  /// - [uid]: User ID
  /// 
  /// Returns: Map<String, dynamic>? - User data hoặc null nếu không tìm thấy
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error getting user profile: $e');
      throw Exception('Không thể lấy user profile: $e');
    }
  }

  /// Cập nhật thông tin user
  /// 
  /// Parameters:
  /// - [uid]: User ID
  /// - [data]: Map chứa các field cần update
  /// 
  /// Returns: Future<void>
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      // Thêm updatedAt timestamp
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(usersCollection)
          .doc(uid)
          .update(data);

      print('✅ User profile updated: $uid');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      throw Exception('Không thể cập nhật user profile: $e');
    }
  }

  /// Xóa user profile
  /// 
  /// Parameters:
  /// - [uid]: User ID
  /// 
  /// Returns: Future<void>
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(uid)
          .delete();

      print('✅ User profile deleted: $uid');
    } catch (e) {
      print('❌ Error deleting user profile: $e');
      throw Exception('Không thể xóa user profile: $e');
    }
  }

  /// Kiểm tra user có tồn tại không
  /// 
  /// Parameters:
  /// - [uid]: User ID
  /// 
  /// Returns: bool - true nếu user tồn tại
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .get();

      return doc.exists;
    } catch (e) {
      print('❌ Error checking user existence: $e');
      return false;
    }
  }

  /// Lấy danh sách users theo role
  /// 
  /// Parameters:
  /// - [role]: Role cần filter (admin, teacher, student, parent)
  /// 
  /// Returns: List<Map<String, dynamic>> - Danh sách users
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollection)
          .where('role', isEqualTo: role)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'uid': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('❌ Error getting users by role: $e');
      throw Exception('Không thể lấy danh sách users: $e');
    }
  }

  /// Lấy tất cả users
  /// 
  /// Returns: List<Map<String, dynamic>> - Danh sách tất cả users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'uid': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('❌ Error getting all users: $e');
      throw Exception('Không thể lấy danh sách users: $e');
    }
  }

  /// Stream để listen real-time changes của user profile
  /// 
  /// Parameters:
  /// - [uid]: User ID
  /// 
  /// Returns: Stream<Map<String, dynamic>?> - Stream của user data
  Stream<Map<String, dynamic>?> watchUserProfile(String uid) {
    return _firestore
        .collection(usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  /// Stream để listen danh sách users theo role
  /// 
  /// Parameters:
  /// - [role]: Role cần filter
  /// 
  /// Returns: Stream<List<Map<String, dynamic>>> - Stream danh sách users
  Stream<List<Map<String, dynamic>>> watchUsersByRole(String role) {
    return _firestore
        .collection(usersCollection)
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'uid': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// Cập nhật role của user
  /// 
  /// Parameters:
  /// - [uid]: User ID
  /// - [newRole]: Role mới
  /// 
  /// Returns: Future<void>
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await updateUserProfile(uid, {'role': newRole});
      print('✅ User role updated: $uid -> $newRole');
    } catch (e) {
      print('❌ Error updating user role: $e');
      throw Exception('Không thể cập nhật role: $e');
    }
  }

  /// Tìm kiếm users theo email
  /// 
  /// Parameters:
  /// - [email]: Email cần tìm
  /// 
  /// Returns: List<Map<String, dynamic>> - Danh sách users match
  Future<List<Map<String, dynamic>>> searchUsersByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollection)
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'uid': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('❌ Error searching users: $e');
      throw Exception('Không thể tìm kiếm users: $e');
    }
  }

  /// Đếm số lượng users theo role
  /// 
  /// Parameters:
  /// - [role]: Role cần đếm
  /// 
  /// Returns: int - Số lượng users
  Future<int> countUsersByRole(String role) async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollection)
          .where('role', isEqualTo: role)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('❌ Error counting users: $e');
      return 0;
    }
  }

  /// Batch tạo nhiều users cùng lúc
  /// 
  /// Parameters:
  /// - [users]: List các user data cần tạo
  /// 
  /// Returns: Future<void>
  Future<void> batchCreateUsers(List<Map<String, dynamic>> users) async {
    try {
      final batch = _firestore.batch();

      for (var user in users) {
        final docRef = _firestore
            .collection(usersCollection)
            .doc(user['uid'] as String);

        batch.set(docRef, {
          'email': user['email'],
          'name': user['name'],
          'role': user['role'],
          'avatarUrl': user['avatarUrl'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('✅ Batch created ${users.length} users');
    } catch (e) {
      print('❌ Error batch creating users: $e');
      throw Exception('Không thể tạo users hàng loạt: $e');
    }
  }
}
