import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/exam_instance_model.dart';
import '../../data/models/exam_result_model.dart';
import '../../data/sources/exam_taking_service.dart';
import 'exam_taking_screen.dart';
import 'exam_result_screen.dart';

/// Student Exam List Screen
/// Danh sách đề thi available cho học sinh
class StudentExamListScreen extends StatefulWidget {
  const StudentExamListScreen({Key? key}) : super(key: key);

  @override
  State<StudentExamListScreen> createState() => _StudentExamListScreenState();
}

class _StudentExamListScreenState extends State<StudentExamListScreen> {
  final ExamTakingService _examService = ExamTakingService();
  int? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Danh Sách Đề Thi'),
        backgroundColor: Colors.blue,
        actions: [
          // Level filter
          PopupMenuButton<int?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Lọc theo cấp độ',
            onSelected: (level) {
              setState(() => _selectedLevel = level);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Tất cả cấp độ'),
              ),
              ...List.generate(
                6,
                (index) => PopupMenuItem(
                  value: index + 1,
                  child: Text('HSK ${index + 1}'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter indicator
          if (_selectedLevel != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Đang hiển thị: HSK $_selectedLevel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _selectedLevel = null),
                    child: const Text('Xóa bộ lọc'),
                  ),
                ],
              ),
            ),

          // Exam list
          Expanded(
            child: StreamBuilder<List<ExamInstanceModel>>(
              stream: _examService.getAvailableExams(_selectedLevel),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Lỗi: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final exams = snapshot.data ?? [];

                if (exams.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có đề thi nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return _ExamCard(
                      exam: exam,
                      onTap: () => _handleExamTap(exam),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExamTap(ExamInstanceModel exam) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập')),
      );
      return;
    }

    // Check if student already took this exam
    final existingResult = await _examService.getExistingResult(
      examInstanceId: exam.id,
      studentId: user.uid,
    );

    if (existingResult != null) {
      // Show options: View result or Retake
      _showExamTakenDialog(exam, existingResult);
    } else {
      // Start new exam
      _startExam(exam);
    }
  }

  void _showExamTakenDialog(ExamInstanceModel exam, ExamResultModel result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bạn đã làm đề này rồi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Điểm: ${result.totalScore.toStringAsFixed(1)}/${result.hskLevel == 1 || result.hskLevel == 2 ? 200 : 300}'),
            Text('Trạng thái: ${result.isPassed ? "✅ Đạt" : "❌ Chưa đạt"}'),
            const SizedBox(height: 16),
            Text(
              result.status == ExamStatus.inProgress
                  ? 'Tiếp tục làm bài?'
                  : 'Bạn muốn xem kết quả hay làm lại?',
            ),
          ],
        ),
        actions: [
          if (result.status != ExamStatus.inProgress)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExamResultScreen(examResultId: result.id),
                  ),
                );
              },
              child: const Text('Xem Kết Quả'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (result.status == ExamStatus.inProgress) {
                // Resume exam
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExamTakingScreen(
                      examInstanceId: exam.id,
                      existingResultId: result.id,
                    ),
                  ),
                );
              } else {
                // Start new attempt
                _startExam(exam);
              }
            },
            child: Text(
              result.status == ExamStatus.inProgress
                  ? 'Tiếp Tục'
                  : 'Làm Lại',
            ),
          ),
        ],
      ),
    );
  }

  void _startExam(ExamInstanceModel exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamTakingScreen(examInstanceId: exam.id),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final ExamInstanceModel exam;
  final VoidCallback onTap;

  const _ExamCard({
    required this.exam,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(exam.hskLevel),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'HSK ${exam.hskLevel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Active badge
                  if (exam.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                exam.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                exam.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // Info row
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.question_answer,
                    label: '${exam.totalQuestions} câu',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.timer,
                    label: '${exam.durationMinutes} phút',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.emoji_events,
                    label: 'Đạt: ${exam.passingScore}',
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.red;
      case 6:
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
