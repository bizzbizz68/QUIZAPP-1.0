import 'package:flutter/material.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/question_model.dart';
import '../services/admin_exam_service.dart';

/// Admin Question Form Screen - Thêm/Chỉnh sửa câu hỏi
class AdminQuestionFormScreen extends StatefulWidget {
  final ExamModel exam;
  final QuestionModel? question; // null = thêm mới, có giá trị = edit

  const AdminQuestionFormScreen({
    super.key,
    required this.exam,
    this.question,
  });

  @override
  State<AdminQuestionFormScreen> createState() =>
      _AdminQuestionFormScreenState();
}

class _AdminQuestionFormScreenState extends State<AdminQuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminService = AdminExamService();

  late TextEditingController _contentController;
  late TextEditingController _orderIndexController;
  late TextEditingController _explanationController;
  late TextEditingController _audioUrlController;
  late TextEditingController _imageUrlController;
  late TextEditingController _correctAnswerController;

  QuestionType _selectedType = QuestionType.nghe_dung_sai;
  String _selectedSection = 'nghe';
  List<TextEditingController> _optionControllers = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.question != null) {
      // Edit mode
      final q = widget.question!;
      _selectedType = q.type;
      _selectedSection = q.section;
      _contentController = TextEditingController(
        text: q.content['text']?.toString() ?? '',
      );
      _orderIndexController =
          TextEditingController(text: q.orderIndex.toString());
      _explanationController =
          TextEditingController(text: q.explanation ?? '');
      _audioUrlController = TextEditingController(
        text: q.content['audioUrl']?.toString() ?? '',
      );
      _imageUrlController = TextEditingController(
        text: q.content['imageUrl']?.toString() ?? '',
      );
      _correctAnswerController = TextEditingController(
        text: q.correctAnswer?.toString() ?? '',
      );

      // Load options
      for (var option in q.options) {
        _optionControllers.add(TextEditingController(text: option));
      }
    } else {
      // Add new mode
      _contentController = TextEditingController();
      _orderIndexController = TextEditingController(text: '1');
      _explanationController = TextEditingController();
      _audioUrlController = TextEditingController();
      _imageUrlController = TextEditingController();
      _correctAnswerController = TextEditingController();

      // Default 4 options
      for (int i = 0; i < 4; i++) {
        _optionControllers.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _orderIndexController.dispose();
    _explanationController.dispose();
    _audioUrlController.dispose();
    _imageUrlController.dispose();
    _correctAnswerController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final content = <String, dynamic>{
        'text': _contentController.text.trim(),
      };

      if (_audioUrlController.text.trim().isNotEmpty) {
        content['audioUrl'] = _audioUrlController.text.trim();
      }
      if (_imageUrlController.text.trim().isNotEmpty) {
        content['imageUrl'] = _imageUrlController.text.trim();
      }

      final options = _optionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      if (widget.question == null) {
        // Add new
        await _adminService.addQuestion(
          examId: widget.exam.id,
          content: content,
          type: _selectedType,
          options: options,
          correctAnswer: _correctAnswerController.text.trim(),
          explanation: _explanationController.text.trim().isEmpty
              ? null
              : _explanationController.text.trim(),
          points: 1,
          orderIndex: int.parse(_orderIndexController.text),
          imageUrl: _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
          audioUrl: _audioUrlController.text.trim().isEmpty
              ? null
              : _audioUrlController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Thêm câu hỏi thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Update
        await _adminService.updateQuestion(
          widget.exam.id,
          widget.question!.id,
          {
            'content': content,
            'type': _selectedType.toString().split('.').last,
            'section': _selectedSection,
            'options': options,
            'correctAnswer': _correctAnswerController.text.trim(),
            'explanation': _explanationController.text.trim().isEmpty
                ? null
                : _explanationController.text.trim(),
            'orderIndex': int.parse(_orderIndexController.text),
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Cập nhật câu hỏi thành công!'),
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
    final isEdit = widget.question != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh Sửa Câu Hỏi' : 'Thêm Câu Hỏi Mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Order Index
            TextFormField(
              controller: _orderIndexController,
              decoration: const InputDecoration(
                labelText: 'Số thứ tự *',
                hintText: '1',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số thứ tự';
                }
                final index = int.tryParse(value);
                if (index == null || index <= 0) {
                  return 'Số thứ tự phải là số dương';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Section
            DropdownButtonFormField<String>(
              value: _selectedSection,
              decoration: const InputDecoration(
                labelText: 'Phần *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'nghe', child: Text('Nghe')),
                DropdownMenuItem(value: 'doc', child: Text('Đọc')),
                DropdownMenuItem(value: 'viet', child: Text('Viết')),
              ],
              onChanged: (value) {
                setState(() => _selectedSection = value!);
              },
            ),
            const SizedBox(height: 16),

            // Question Type
            DropdownButtonFormField<QuestionType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Loại câu hỏi *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.quiz),
              ),
              isExpanded: true,
              items: QuestionType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.toString().split('.').last.replaceAll('_', ' '),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
            ),
            const SizedBox(height: 16),

            // Content
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung câu hỏi *',
                hintText: 'Nhập nội dung câu hỏi...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.text_fields),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập nội dung câu hỏi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Audio URL (optional)
            TextFormField(
              controller: _audioUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Audio (tùy chọn)',
                hintText: 'audio/hsk1/listening_1.mp3',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.audiotrack),
              ),
            ),
            const SizedBox(height: 16),

            // Image URL (optional)
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Hình ảnh (tùy chọn)',
                hintText: 'images/hsk1/question_1.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
            ),
            const SizedBox(height: 16),

            // Options
            const Text(
              'Các đáp án:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._optionControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Đáp án ${index + 1}',
                          border: const OutlineInputBorder(),
                          prefixIcon: CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 12,
                            child: Text(
                              '${String.fromCharCode(65 + index)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeOption(index),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              label: const Text('Thêm đáp án'),
            ),
            const SizedBox(height: 16),

            // Correct Answer
            TextFormField(
              controller: _correctAnswerController,
              decoration: const InputDecoration(
                labelText: 'Đáp án đúng *',
                hintText: 'A hoặc B,C (nếu nhiều đáp án)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.check_circle),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập đáp án đúng';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Explanation
            TextFormField(
              controller: _explanationController,
              decoration: const InputDecoration(
                labelText: 'Giải thích (tùy chọn)',
                hintText: 'Giải thích đáp án...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveQuestion,
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
                  : (isEdit ? 'Cập Nhật' : 'Thêm Câu Hỏi')),
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
