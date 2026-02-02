import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Firebase Authentication Service
/// Thay thế mock AuthService bằng Firebase thật
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _currentUser;

  /// Lấy user hiện tại
  UserModel? get currentUser => _currentUser;

  /// Kiểm tra đã đăng nhập chưa
  bool get isAuthenticated => _currentUser != null;

  /// Khởi tạo - Kiểm tra user đã đăng nhập
  Future<void> initialize() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await _loadUserFromFirestore(firebaseUser.uid);
    }
  }

  /// Đăng ký tài khoản mới
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      // Tạo tài khoản Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Không thể tạo tài khoản');
      }

      // Tạo document trong Firestore
      final userData = {
        'email': email,
        'name': name,
        'role': role.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(firebaseUser.uid).set(userData);

      // Tạo UserModel
      _currentUser = UserModel(
        id: firebaseUser.uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );

      return _currentUser!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi đăng ký: $e');
    }
  }

  /// Đăng nhập bằng email/password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Đăng nhập thất bại');
      }

      await _loadUserFromFirestore(firebaseUser.uid);
      return _currentUser!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  /// Đăng nhập bằng Google
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Đã hủy đăng nhập Google');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Không thể đăng nhập với Google');
      }

      // Kiểm tra xem user đã có trong Firestore chưa
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // User mới - Tạo document với role mặc định là student
        final userData = {
          'email': firebaseUser.email ?? '',
          'name': firebaseUser.displayName ?? 'User',
          'role': 'student', // Role mặc định
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(firebaseUser.uid).set(userData);

        _currentUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          role: UserRole.student,
          createdAt: DateTime.now(),
        );
      } else {
        // User đã tồn tại - Load từ Firestore
        await _loadUserFromFirestore(firebaseUser.uid);
      }

      return _currentUser!;
    } catch (e) {
      throw Exception('Lỗi đăng nhập Google: $e');
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
    
    // Only sign out from Google if user was signed in with Google
    // Prevents error when Google client ID is not configured
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore Google sign out errors (e.g., when not signed in via Google)
      print('Google sign out skipped or failed: $e');
    }
    
    _currentUser = null;
  }

  /// Get user data by UID (for auth persistence)
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      
      return UserModel(
        id: uid,
        email: data['email'] as String,
        name: data['name'] as String,
        role: _parseRole(data['role'] as String),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Load user data từ Firestore
  Future<void> _loadUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (!doc.exists) {
        throw Exception('User không tồn tại trong database');
      }

      final data = doc.data()!;
      
      _currentUser = UserModel(
        id: uid,
        email: data['email'] as String,
        name: data['name'] as String,
        role: _parseRole(data['role'] as String),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('Lỗi load user: $e');
    }
  }

  /// Parse role string to UserRole enum
  UserRole _parseRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
        return UserRole.teacher;
      case 'student':
        return UserRole.student;
      case 'parent':
        return UserRole.parent;
      default:
        return UserRole.student;
    }
  }

  /// Xử lý Firebase Auth exceptions
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản';
      case 'wrong-password':
        return 'Sai mật khẩu';
      case 'user-disabled':
        return 'Tài khoản đã bị khóa';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập chưa được kích hoạt';
      default:
        return 'Lỗi xác thực: ${e.message}';
    }
  }

  /// Đổi mật khẩu
  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }

    try {
      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Reset mật khẩu qua email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Cập nhật thông tin user
  Future<void> updateUserProfile({String? name}) async {
    if (_currentUser == null) {
      throw Exception('Chưa đăng nhập');
    }

    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) {
        updates['name'] = name;
        await _auth.currentUser?.updateDisplayName(name);
      }

      await _firestore.collection('users').doc(_currentUser!.id).update(updates);

      // Reload user
      await _loadUserFromFirestore(_currentUser!.id);
    } catch (e) {
      throw Exception('Lỗi cập nhật profile: $e');
    }
  }
}
