import 'package:flutter/material.dart';
import '../../data/models/exam_model.dart';
import '../services/admin_exam_service.dart';

/// Admin Exam Form Screen - Tạo/Chỉnh sửa đề thi
class AdminExamFormScreen extends StatefulWidget {
  final ExamModel? exam; // null = tạo mới, có giá trị = edit

  const AdminExamFormScreen({super.key, this.exam});

  @override
  State<AdminExamFormScreen> createState() => _AdminExamFormScreenState();
}

class _AdminExamFormScreenState extends State<AdminExamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminService = AdminExamService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late TextEditingController _totalQuestionsController;
  late TextEditingController _passingScoreController;

  int _selectedLevel = 1;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.exam?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.exam?.description ?? '');
    _durationController =
        TextEditingController(text: widget.exam?.duration.toString() ?? '60');
    _totalQuestionsController = TextEditingController(
        text: widget.exam?.totalQuestions.toString() ?? '0');
    _passingScoreController = TextEditingController(
        text: widget.exam?.passingScore.toString() ?? '60');

    if (widget.exam != null) {
      _selectedLevel = widget.exam!.level;
      _isActive = widget.exam!.isActive;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _totalQuestionsController.dispose();
    _passingScoreController.dispose();
    super.dispose();
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.exam == null) {
        // Tạo mới
        await _adminService.createExam(
          title: _titleController.text.trim(),
          level: _selectedLevel,
          duration: int.parse(_durationController.text),
          description: _descriptionController.text.trim(),
          totalQuestions: int.parse(_totalQuestionsController.text),
          passingScore: int.parse(_passingScoreController.text),
          createdBy: 'admin', // TODO: Get current user ID
          isActive: _isActive,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Tạo đề thi thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Cập nhật
        await _adminService.updateExam(
          widget.exam!.id,
          {
            'title': _titleController.text.trim(),
            'level': _selectedLevel,
            'duration': int.parse(_durationController.text),
            'description': _descriptionController.text.trim(),
            'totalQuestions': int.parse(_totalQuestionsController.text),
            'passingScore': int.parse(_passingScoreController.text),
            'isActive': _isActive,
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Cập nhật đề thi thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.exam != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh Sửa Đề Thi' : 'Tạo Đề Thi Mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề đề thi *',
                hintText: 'VD: HSK 1 - Đề Thi Thử',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // HSK Level
            DropdownButtonFormField<int>(
              value: _selectedLevel,
              decoration: const InputDecoration(
                labelText: 'HSK Level *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              items: [1, 2, 3, 4, 5, 6]
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text('HSK $level'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedLevel = value!);
              },
            ),
            const SizedBox(height: 16),

            // Duration
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Thời gian (phút) *',
                hintText: '60',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập thời gian';
                }
                final duration = int.tryParse(value);
                if (duration == null || duration <= 0) {
                  return 'Thời gian phải là số dương';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Total Questions
            TextFormField(
              controller: _totalQuestionsController,
              decoration: const InputDecoration(
                labelText: 'Tổng số câu hỏi *',
                hintText: '35',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.quiz),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số câu hỏi';
                }
                final total = int.tryParse(value);
                if (total == null || total <= 0) {
                  return 'Số câu hỏi phải là số dương';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Passing Score
            TextFormField(
              controller: _passingScoreController,
              decoration: const InputDecoration(
                labelText: 'Điểm đạt (%) *',
                hintText: '60',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grade),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập điểm đạt';
                }
                final score = int.tryParse(value);
                if (score == null || score < 0 || score > 100) {
                  return 'Điểm đạt phải từ 0-100';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                hintText: 'Mô tả về đề thi...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Active Status
            SwitchListTile(
              title: const Text('Trạng thái'),
              subtitle: Text(_isActive ? 'Đang hoạt động' : 'Đã ẩn'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
              secondary: Icon(
                _isActive ? Icons.visibility : Icons.visibility_off,
                color: _isActive ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveExam,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving
                  ? 'Đang lưu...'
                  : (isEdit ? 'Cập Nhật' : 'Tạo Đề Thi')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
