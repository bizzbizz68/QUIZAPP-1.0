import 'package:flutter/material.dart';
import '../../data/models/question_model.dart';

/// Question Widget
/// Display câu hỏi theo type và handle answer input
class QuestionWidget extends StatelessWidget {
  final QuestionModel question;
  final int questionNumber;
  final dynamic answer;
  final ValueChanged<dynamic> onAnswerChanged;

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.questionNumber,
    this.answer,
    required this.onAnswerChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question type badge
          _buildTypeBadge(),
          
          const SizedBox(height: 16),

          // Audio player (if has audio)
          if (question.content['audioUrl'] != null && 
              question.content['audioUrl'].toString().isNotEmpty) ...[
            _buildAudioPlayer(),
            const SizedBox(height: 16),
          ],

          // Image (if has image)
          if (question.content['imageUrl'] != null && 
              question.content['imageUrl'].toString().isNotEmpty) ...[
            _buildImage(),
            const SizedBox(height: 16),
          ],

          // Question text
          if ((question.content['text'] ?? '').toString().isNotEmpty) ...[
            _buildQuestionText(),
            const SizedBox(height: 24),
          ],

          // Answer options
          _buildAnswerInput(),
        ],
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getTypeColor()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTypeIcon(), size: 16, color: _getTypeColor()),
          const SizedBox(width: 6),
          Text(
            question.type.toString().split('.').last,
            style: TextStyle(
              color: _getTypeColor(),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.headphones, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  (question.content['audioUrl'] ?? '').toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Play audio
            },
            icon: const Icon(Icons.play_arrow, size: 32),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        (question.content['imageUrl'] ?? '').toString(),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 64),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$questionNumber',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              (question.content['text'] ?? '').toString(),
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    // True/False questions
    if (_isTrueFalseQuestion()) {
      return _buildTrueFalseOptions();
    }

    // Multiple choice with images (ABCDEF)
    if (_isImageChoiceQuestion()) {
      return _buildImageChoiceOptions();
    }

    // Multiple choice (ABC or ABCD)
    if (_isMultipleChoiceQuestion()) {
      return _buildMultipleChoiceOptions();
    }

    // Fill in the blank
    if (_isFillBlankQuestion()) {
      return _buildFillBlankInput();
    }

    // Writing/Essay
    if (_isWritingQuestion()) {
      return _buildWritingInput();
    }

    // Default: text input
    return _buildDefaultInput();
  }

  // True/False
  Widget _buildTrueFalseOptions() {
    return Column(
      children: [
        _OptionTile(
          label: '✓ Đúng',
          value: 'true',
          groupValue: answer?.toString(),
          onChanged: (val) => onAnswerChanged(val),
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _OptionTile(
          label: '✗ Sai',
          value: 'false',
          groupValue: answer?.toString(),
          onChanged: (val) => onAnswerChanged(val),
          color: Colors.red,
        ),
      ],
    );
  }

  // Multiple choice
  Widget _buildMultipleChoiceOptions() {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final optionLabel = String.fromCharCode(65 + index.toInt()); // A, B, C, D...

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OptionTile(
            label: '$optionLabel. $option',
            value: option,
            groupValue: answer?.toString(),
            onChanged: (val) => onAnswerChanged(val),
          ),
        );
      }).toList(),
    );
  }

  // Image choice (ABCDEF)
  Widget _buildImageChoiceOptions() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final optionLabel = String.fromCharCode(65 + index);
        final isSelected = answer?.toString() == option;

        return GestureDetector(
          onTap: () => onAnswerChanged(option),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  optionLabel,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                ),
                // TODO: Display image if option is image URL
              ],
            ),
          ),
        );
      },
    );
  }

  // Fill in the blank
  Widget _buildFillBlankInput() {
    return TextField(
      onChanged: onAnswerChanged,
      controller: answer != null ? TextEditingController(text: answer.toString()) : null,
      decoration: InputDecoration(
        hintText: 'Nhập câu trả lời...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      maxLines: 2,
    );
  }

  // Writing/Essay
  Widget _buildWritingInput() {
    return TextField(
      onChanged: onAnswerChanged,
      controller: answer != null ? TextEditingController(text: answer.toString()) : null,
      decoration: InputDecoration(
        hintText: 'Viết câu trả lời của bạn...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      maxLines: 10,
      minLines: 5,
    );
  }

  // Default input
  Widget _buildDefaultInput() {
    return TextField(
      onChanged: onAnswerChanged,
      controller: answer != null ? TextEditingController(text: answer.toString()) : null,
      decoration: InputDecoration(
        hintText: 'Nhập câu trả lời...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Helper methods to determine question type
  bool _isTrueFalseQuestion() {
    final type = question.type.toString().toLowerCase();
    return type.contains('dung_sai') || type.contains('truefalse');
  }

  bool _isImageChoiceQuestion() {
    final type = question.type.toString().toLowerCase();
    return type.contains('chon_hinh') || type.contains('image');
  }

  bool _isMultipleChoiceQuestion() {
    return question.options.length >= 3 && question.options.length <= 6;
  }

  bool _isFillBlankQuestion() {
    final type = question.type.toString().toLowerCase();
    return type.contains('dien') || type.contains('fill');
  }

  bool _isWritingQuestion() {
    final type = question.type.toString().toLowerCase();
    return type.contains('viet') || type.contains('writing');
  }

  Color _getTypeColor() {
    if (question.section == 'nghe') return Colors.blue;
    if (question.section == 'doc') return Colors.green;
    if (question.section == 'viet') return Colors.orange;
    return Colors.grey;
  }

  IconData _getTypeIcon() {
    if (question.section == 'nghe') return Icons.headphones;
    if (question.section == 'doc') return Icons.book;
    if (question.section == 'viet') return Icons.edit;
    return Icons.question_answer;
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String value;
  final String? groupValue;
  final ValueChanged<String> onChanged;
  final Color? color;

  const _OptionTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? Colors.blue).withOpacity(0.1)
              : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? (color ?? Colors.blue) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? (color ?? Colors.blue) : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? (color ?? Colors.blue) : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
