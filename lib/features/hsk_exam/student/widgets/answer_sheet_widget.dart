import 'package:flutter/material.dart';
import '../../data/models/question_model.dart';

/// Answer Sheet Widget
/// Bảng theo dõi trạng thái các câu hỏi
class AnswerSheetWidget extends StatelessWidget {
  final List<QuestionModel> questions;
  final Map<String, dynamic> answers;
  final int currentIndex;
  final ValueChanged<int> onQuestionTap;

  const AnswerSheetWidget({
    Key? key,
    required this.questions,
    required this.answers,
    required this.currentIndex,
    required this.onQuestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bảng Đáp Án',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats
          _buildStats(),

          const SizedBox(height: 16),

          // Legend
          _buildLegend(),

          const SizedBox(height: 16),

          // Question grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final isAnswered = answers.containsKey(question.id);
                final isCurrent = index == currentIndex;

                return _QuestionBubble(
                  questionNumber: index + 1,
                  isAnswered: isAnswered,
                  isCurrent: isCurrent,
                  onTap: () => onQuestionTap(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final answeredCount = answers.length;
    final totalCount = questions.length;
    final percentage = (answeredCount / totalCount * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.check_circle,
            label: 'Đã làm',
            value: '$answeredCount',
            color: Colors.green,
          ),
          _StatItem(
            icon: Icons.radio_button_unchecked,
            label: 'Chưa làm',
            value: '${totalCount - answeredCount}',
            color: Colors.orange,
          ),
          _StatItem(
            icon: Icons.assessment,
            label: 'Tiến độ',
            value: '$percentage%',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendItem(
          color: Colors.green,
          label: 'Đã làm',
        ),
        _LegendItem(
          color: Colors.grey.shade300,
          label: 'Chưa làm',
        ),
        _LegendItem(
          color: Colors.blue,
          label: 'Đang làm',
        ),
      ],
    );
  }
}

class _QuestionBubble extends StatelessWidget {
  final int questionNumber;
  final bool isAnswered;
  final bool isCurrent;
  final VoidCallback onTap;

  const _QuestionBubble({
    required this.questionNumber,
    required this.isAnswered,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isCurrent) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
      borderColor = Colors.blue.shade700;
    } else if (isAnswered) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
      borderColor = Colors.green.shade700;
    } else {
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade700;
      borderColor = Colors.grey.shade400;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            if (isCurrent)
              BoxShadow(
                color: Colors.blue.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$questionNumber',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (isAnswered && !isCurrent)
                Icon(
                  Icons.check,
                  size: 16,
                  color: textColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
