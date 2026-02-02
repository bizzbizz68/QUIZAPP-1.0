import '../models/user_model.dart';

/// Authentication service handling login/register operations
/// Currently uses mock data, ready for Firebase/Supabase integration
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Current authenticated user
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Mock user database (replace with Firebase/Supabase later)
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'email': 'ad',
      'password': '123',
      'id': 'admin_001',
      'name': 'Admin User',
      'role': 'admin',
      'createdAt': DateTime.now().subtract(const Duration(days: 365)),
    },
    {
      'email': 'gv',
      'password': '123',
      'id': 'teacher_001',
      'name': 'Giáo Viên Nguyễn',
      'role': 'teacher',
      'createdAt': DateTime.now().subtract(const Duration(days: 180)),
    },
    {
      'email': 'hs',
      'password': '123',
      'id': 'student_001',
      'name': 'Học Sinh Trần',
      'role': 'student',
      'createdAt': DateTime.now().subtract(const Duration(days: 90)),
    },
    {
      'email': 'ph',
      'password': '123',
      'id': 'parent_001',
      'name': 'Phụ Huynh Lê',
      'role': 'parent',
      'createdAt': DateTime.now().subtract(const Duration(days: 60)),
    },
  ];

  /// Login with email and password
  /// Returns UserModel on success, throws Exception on failure
  Future<UserModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Find user in mock database
      final userData = _mockUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => throw Exception('Email hoặc mật khẩu không đúng'),
      );

      // Create user model
      _currentUser = UserModel(
        id: userData['id'] as String,
        email: userData['email'] as String,
        name: userData['name'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.name == userData['role'],
        ),
        createdAt: userData['createdAt'] as DateTime,
        lastLoginAt: DateTime.now(),
      );

      return _currentUser!;
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }

    // TODO: Replace with Firebase Authentication
    // final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    //   email: email,
    //   password: password,
    // );
    // Then fetch user data from Firestore/Supabase
  }

  /// Register new user
  /// Returns UserModel on success, throws Exception on failure
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Check if email already exists
      final existingUser = _mockUsers.any((user) => user['email'] == email);
      if (existingUser) {
        throw Exception('Email đã được sử dụng');
      }

      // Create new user
      final newUser = {
        'email': email,
        'password': password,
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'role': role.name,
        'createdAt': DateTime.now(),
      };

      // Add to mock database
      _mockUsers.add(newUser);

      // Create user model
      _currentUser = UserModel(
        id: newUser['id'] as String,
        email: newUser['email'] as String,
        name: newUser['name'] as String,
        role: role,
        createdAt: newUser['createdAt'] as DateTime,
        lastLoginAt: DateTime.now(),
      );

      return _currentUser!;
    } catch (e) {
      throw Exception('Đăng ký thất bại: ${e.toString()}');
    }

    // TODO: Replace with Firebase Authentication
    // final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    //   email: email,
    //   password: password,
    // );
    // Then save user data to Firestore/Supabase
  }

  /// Sign in with Google (mock implementation)
  /// Returns UserModel on success, throws Exception on failure
  Future<UserModel> signInWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Mock Google Sign-In - create a demo user
      final googleUser = {
        'id': 'google_${DateTime.now().millisecondsSinceEpoch}',
        'email': 'google.user@gmail.com',
        'name': 'Google User Demo',
        'role': 'student',
        'createdAt': DateTime.now(),
      };

      // Create user model
      _currentUser = UserModel(
        id: googleUser['id'] as String,
        email: googleUser['email'] as String,
        name: googleUser['name'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.name == googleUser['role'],
        ),
        createdAt: googleUser['createdAt'] as DateTime,
        lastLoginAt: DateTime.now(),
      );

      return _currentUser!;
    } catch (e) {
      throw Exception('Đăng nhập Google thất bại: ${e.toString()}');
    }

    // TODO: Replace with Firebase Google Sign-In
    // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // if (googleUser == null) throw Exception('Đăng nhập bị hủy');
    // 
    // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );
    // 
    // final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    // Then fetch user data from Firestore/Supabase
  }

  /// Logout current user
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;

    // TODO: Replace with Firebase logout
    // await FirebaseAuth.instance.signOut();
    // await GoogleSignIn().signOut();
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Get user role
  UserRole? get userRole => _currentUser?.role;

  /// Reset password (mock implementation)
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));

    final userExists = _mockUsers.any((user) => user['email'] == email);
    if (!userExists) {
      throw Exception('Email không tồn tại trong hệ thống');
    }

    // TODO: Implement Firebase password reset
    // await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
    );

    // TODO: Update in Firebase/Supabase
    return _currentUser!;
  }
}
