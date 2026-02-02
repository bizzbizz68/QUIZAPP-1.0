import 'package:flutter/material.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/question_model.dart';
import '../../data/sources/exam_service.dart';
import '../services/admin_exam_service.dart';
import 'admin_question_form_screen.dart';

/// Admin Questions Screen - Quản lý câu hỏi của một đề thi
class AdminQuestionsScreen extends StatefulWidget {
  final ExamModel exam;

  const AdminQuestionsScreen({super.key, required this.exam});

  @override
  State<AdminQuestionsScreen> createState() => _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends State<AdminQuestionsScreen> {
  final _examService = ExamService();
  final _adminService = AdminExamService();
  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  String? _error;
  String? _filterSection; // null = all, 'nghe', 'doc', 'viet'

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final questions =
          await _examService.getQuestionsByExamId(widget.exam.id);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<QuestionModel> get _filteredQuestions {
    if (_filterSection == null) return _questions;
    return _questions.where((q) => q.section == _filterSection).toList();
  }

  Future<void> _deleteQuestion(QuestionModel question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa câu ${question.orderIndex}?'),
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
        await _adminService.deleteQuestion(widget.exam.id, question.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã xóa câu hỏi'),
            backgroundColor: Colors.green,
          ),
        );
        _loadQuestions();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.exam.title),
            Text(
              '${_filteredQuestions.length} câu hỏi',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          // Filter Section
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Lọc theo phần',
            onSelected: (value) {
              setState(() => _filterSection = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Tất cả'),
              ),
              const PopupMenuItem(
                value: 'nghe',
                child: Text('Nghe'),
              ),
              const PopupMenuItem(
                value: 'doc',
                child: Text('Đọc'),
              ),
              const PopupMenuItem(
                value: 'viet',
                child: Text('Viết'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuestions,
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
              builder: (context) =>
                  AdminQuestionFormScreen(exam: widget.exam),
            ),
          );
          if (result == true) {
            _loadQuestions();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm Câu Hỏi'),
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
              onPressed: _loadQuestions,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Chưa có câu hỏi nào'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminQuestionFormScreen(exam: widget.exam),
                  ),
                );
                if (result == true) {
                  _loadQuestions();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm Câu Hỏi Đầu Tiên'),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredQuestions;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Không có câu hỏi phần $_filterSection'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuestions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final question = filtered[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getSectionColor(question.section),
                child: Text(
                  '${question.orderIndex}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                _getQuestionTypeDisplay(question.type),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    question.content['text']?.toString() ?? '(Không có nội dung)',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildSectionChip(question.section),
                      const SizedBox(width: 8),
                      if (question.content['audioUrl'] != null)
                        const Icon(Icons.volume_up, size: 16, color: Colors.blue),
                      if (question.content['imageUrl'] != null)
                        const Icon(Icons.image, size: 16, color: Colors.green),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminQuestionFormScreen(
                            exam: widget.exam,
                            question: question,
                          ),
                        ),
                      ).then((result) {
                        if (result == true) _loadQuestions();
                      });
                      break;
                    case 'delete':
                      _deleteQuestion(question);
                      break;
                  }
                },
                itemBuilder: (context) => [
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionChip(String section) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getSectionColor(section).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        section.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getSectionColor(section),
        ),
      ),
    );
  }

  Color _getSectionColor(String section) {
    switch (section) {
      case 'nghe':
        return Colors.blue;
      case 'doc':
        return Colors.green;
      case 'viet':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getQuestionTypeDisplay(QuestionType type) {
    final typeStr = type.toString().split('.').last;
    return typeStr.replaceAll('_', ' ').toUpperCase();
  }
}
