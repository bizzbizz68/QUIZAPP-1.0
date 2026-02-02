import 'package:flutter/material.dart';
import 'core/config/firebase_config.dart';
import 'features/auth/screens/auth_wrapper.dart';
import 'features/hsk_exam/data/sources/exam_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseConfig.initialize();
  
  // Seed initial HSK exam data (chỉ chạy 1 lần lúc đầu)
  // Comment out sau khi đã seed xong
  try {
    await ExamService().seedInitialData(createdBy: 'system');
  } catch (e) {
    print('⚠️ Seed data skipped or failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HSK Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Use AuthWrapper instead of LoginScreen
      // AuthWrapper checks if user is already logged in
      home: const AuthWrapper(),
    );
  }
}
