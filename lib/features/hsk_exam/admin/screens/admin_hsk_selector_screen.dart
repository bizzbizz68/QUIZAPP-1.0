import 'package:flutter/material.dart';
import '../../utils/hsk_template_generator.dart';
import '../services/admin_exam_service.dart';
// TODO: Restore or recreate admin_question_template_screen.dart
// import 'admin_question_template_screen.dart';

/// Admin HSK Selector Screen - Chọn HSK level để tạo/quản lý đề
class AdminHskSelectorScreen extends StatefulWidget {
  const AdminHskSelectorScreen({super.key});

  @override
  State<AdminHskSelectorScreen> createState() => _AdminHskSelectorScreenState();
}

class _AdminHskSelectorScreenState extends State<AdminHskSelectorScreen> {
  final _adminService = AdminExamService();
  bool _isCreating = false;

  Future<void> _selectHskLevel(int level) async {
    // Check if template available
    final template = HskTemplateGenerator.generateTemplate(level);
    
    if (template.totalQuestions == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('HSK $level chưa có dữ liệu cấu trúc đề thi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirm creation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tạo Đề HSK $level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(template.title),
            const SizedBox(height: 8),
            Text('📝 ${template.totalQuestions} câu hỏi'),
            Text('⏱️ ${template.duration} phút'),
            Text('✅ Điểm đạt: ${template.passingScore}%'),
            const SizedBox(height: 16),
            const Text(
              'Hệ thống sẽ tự động tạo cấu trúc đề thi theo format chuẩn HSK.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tạo Đề'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCreating = true);

    try {
      // Create exam with template structure
      final examId = await _adminService.createExam(
        title: template.title,
        level: level,
        duration: template.duration,
        description: 'Đề thi HSK $level theo cấu trúc chính thức',
        totalQuestions: template.totalQuestions,
        passingScore: template.passingScore,
        createdBy: 'admin', // TODO: Get current user
        isActive: false, // Inactive until all questions are filled
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tạo đề thi thành công! Bây giờ hãy nhập câu hỏi.'),
            backgroundColor: Colors.green,
          ),
        );

        // TODO: Navigate to question template screen
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => AdminQuestionTemplateScreen(
        //       examId: examId,
        //       hskLevel: level,
        //       template: template,
        //     ),
        //   ),
        // );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template screen not implemented yet'),
            backgroundColor: Colors.orange,
          ),
        );
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
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Cấp Độ HSK'),
      ),
      body: _isCreating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tạo đề thi...'),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                final level = index + 1;
                final template = HskTemplateGenerator.generateTemplate(level);
                final hasData = template.totalQuestions > 0;

                return Card(
                  elevation: hasData ? 4 : 2,
                  color: hasData ? null : Colors.grey[300],
                  child: InkWell(
                    onTap: hasData ? () => _selectHskLevel(level) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'HSK $level',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: hasData ? Colors.blue : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (hasData) ...[
                            Text(
                              '${template.totalQuestions} câu',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '${template.duration} phút',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ] else ...[
                            Text(
                              'Chưa có dữ liệu',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
