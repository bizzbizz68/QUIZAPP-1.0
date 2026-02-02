import 'package:flutter/material.dart';
import '../../data/models/exam_model.dart';
import '../../data/sources/exam_service.dart';
import '../services/admin_exam_service.dart';
import 'admin_exam_form_screen.dart';
import 'admin_questions_screen.dart';

/// Admin Exam List Screen - Quản lý danh sách đề thi
class AdminExamListScreen extends StatefulWidget {
  const AdminExamListScreen({super.key});

  @override
  State<AdminExamListScreen> createState() => _AdminExamListScreenState();
}

class _AdminExamListScreenState extends State<AdminExamListScreen> {
  final _examService = ExamService();
  final _adminService = AdminExamService();
  List<ExamModel> _exams = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final exams = await _adminService.getAllExamsIncludingInactive();
      setState(() {
        _exams = exams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleExamStatus(ExamModel exam) async {
    try {
      await _adminService.toggleExamStatus(exam.id, !exam.isActive);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exam.isActive
              ? 'Đã ẩn đề thi ${exam.title}'
              : 'Đã kích hoạt đề thi ${exam.title}'),
          backgroundColor: Colors.green,
        ),
      );
      _loadExams();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteExam(ExamModel exam) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa đề thi "${exam.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _adminService.deleteExam(exam.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa đề thi ${exam.title}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadExams();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Đề Thi HSK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExams,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminExamFormScreen(),
            ),
          );
          if (result == true) {
            _loadExams();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo Đề Mới'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExams,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_exams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Chưa có đề thi nào'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminExamFormScreen(),
                  ),
                );
                if (result == true) {
                  _loadExams();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Tạo Đề Đầu Tiên'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExams,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _exams.length,
        itemBuilder: (context, index) {
          final exam = _exams[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: exam.isActive ? Colors.blue : Colors.grey,
                child: Text(
                  'HSK\n${exam.level}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
              title: Text(
                exam.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: exam.isActive ? null : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('${exam.totalQuestions} câu • ${exam.durationDisplay}'),
                  Text(
                    exam.isActive ? 'Đang hoạt động' : 'Đã ẩn',
                    style: TextStyle(
                      color: exam.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'questions':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminQuestionsScreen(exam: exam),
                        ),
                      );
                      break;
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminExamFormScreen(exam: exam),
                        ),
                      ).then((result) {
                        if (result == true) _loadExams();
                      });
                      break;
                    case 'toggle':
                      _toggleExamStatus(exam);
                      break;
                    case 'delete':
                      _deleteExam(exam);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'questions',
                    child: Row(
                      children: [
                        Icon(Icons.quiz, size: 20),
                        SizedBox(width: 8),
                        Text('Quản lý câu hỏi'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Chỉnh sửa'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          exam.isActive ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(exam.isActive ? 'Ẩn đề thi' : 'Kích hoạt'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminQuestionsScreen(exam: exam),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
