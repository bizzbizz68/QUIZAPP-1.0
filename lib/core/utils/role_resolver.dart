import 'package:flutter/material.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/dashboard/screens/admin_dashboard.dart';
import '../../features/dashboard/screens/teacher_dashboard.dart';
import '../../features/dashboard/screens/student_dashboard.dart';
import '../../features/dashboard/screens/parent_dashboard.dart';

/// Role Resolver - Navigate to appropriate dashboard based on user role
class RoleResolver {
  /// Get the appropriate dashboard widget based on user role
  static Widget getDashboardForRole(UserRole role, UserModel user) {
    switch (role) {
      case UserRole.admin:
        return AdminDashboard(user: user);
      case UserRole.teacher:
        return TeacherDashboard(user: user);
      case UserRole.student:
        return StudentDashboard(user: user);
      case UserRole.parent:
        return ParentDashboard(user: user);
    }
  }

  /// Navigate to appropriate dashboard based on user role
  static void navigateToDashboard(BuildContext context, UserModel user) {
    final dashboard = getDashboardForRole(user.role, user);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  /// Get role display name in Vietnamese
  static String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Quản Trị Viên';
      case UserRole.teacher:
        return 'Giáo Viên';
      case UserRole.student:
        return 'Học Sinh';
      case UserRole.parent:
        return 'Phụ Huynh';
    }
  }

  /// Get role icon
  static IconData getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.teacher:
        return Icons.school;
      case UserRole.student:
        return Icons.person;
      case UserRole.parent:
        return Icons.family_restroom;
    }
  }

  /// Get role color
  static Color getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.teacher:
        return Colors.blue;
      case UserRole.student:
        return Colors.green;
      case UserRole.parent:
        return Colors.orange;
    }
  }
}
