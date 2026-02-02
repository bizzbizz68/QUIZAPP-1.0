/// App Constants
/// Chứa tất cả constants dùng trong app
class AppConstants {
  // App Info
  static const String appName = 'Quiz App';
  static const String appVersion = '1.0.0';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String examsCollection = 'exams';
  static const String questionsSubCollection = 'questions';
  static const String resultsCollection = 'results';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';
  static const String roleParent = 'parent';
  
  // HSK Levels
  static const List<int> hskLevels = [1, 2, 3, 4, 5, 6];
  
  // Exam Settings
  static const int defaultExamDuration = 60; // minutes
  static const int questionsPerExam = 20;
  static const int passingScore = 60; // percentage
  
  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 3;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
}
