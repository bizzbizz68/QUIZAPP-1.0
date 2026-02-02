import 'package:flutter/material.dart';
import '../../data/models/exam_result_model.dart';
import '../../data/sources/exam_taking_service.dart';

/// Exam Result Screen
/// Hiển thị kết quả thi chi tiết
class ExamResultScreen extends StatefulWidget {
  final String examResultId;

  const ExamResultScreen({
    Key? key,
    required this.examResultId,
  }) : super(key: key);

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  final ExamTakingService _examService = ExamTakingService();
  ExamResultModel? _result;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    try {
      final result = await _examService.getExamResult(widget.examResultId);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_result == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy kết quả')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết Quả Thi'),
        backgroundColor: _result!.isPassed ? Colors.green : Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pass/Fail banner
            _buildResultBanner(),

            const SizedBox(height: 24),

            // Exam info
            _buildExamInfo(),

            const SizedBox(height: 24),

            // Score breakdown
            _buildScoreBreakdown(),

            const SizedBox(height: 24),

            // Detailed stats
            _buildDetailedStats(),

            const SizedBox(height: 24),

            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBanner() {
    final isPassed = _result!.isPassed;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPassed
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isPassed ? Colors.green : Colors.red).withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isPassed ? Icons.emoji_events : Icons.info_outline,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            isPassed ? '🎉 CHÚC MỪNG! 🎉' : '😔 Chưa đạt',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPassed
                ? 'Bạn đã vượt qua kỳ thi!'
                : 'Đừng nản lòng, cố gắng lần sau nhé!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExamInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông Tin Bài Thi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _InfoRow(icon: Icons.book, label: 'Đề thi', value: _result!.examTitle),
            _InfoRow(icon: Icons.school, label: 'Cấp độ', value: 'HSK ${_result!.hskLevel}'),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Ngày thi',
              value: _formatDate(_result!.submittedAt ?? _result!.startedAt),
            ),
            _InfoRow(
              icon: Icons.timer,
              label: 'Thời gian làm',
              value: _formatDuration(_result!.durationSeconds),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBreakdown() {
    final maxScore = _result!.hskLevel <= 2 ? 200 : 300;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi Tiết Điểm Số',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),

            // Listening
            _ScoreBar(
              label: '🎧 Nghe',
              score: _result!.listeningScore,
              maxScore: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Reading
            _ScoreBar(
              label: '📖 Đọc',
              score: _result!.readingScore,
              maxScore: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            // Writing (if applicable)
            if (_result!.hskLevel >= 3)
              _ScoreBar(
                label: '✍️ Viết',
                score: _result!.writingScore,
                maxScore: 100,
                color: Colors.orange,
              ),

            if (_result!.hskLevel >= 3)
              const SizedBox(height: 16),

            const Divider(),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TỔNG ĐIỂM',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_result!.totalScore.toStringAsFixed(1)}/$maxScore',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _result!.isPassed ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống Kê Chi Tiết',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  icon: Icons.question_answer,
                  label: 'Tổng câu',
                  value: '${_result!.totalQuestions}',
                  color: Colors.blue,
                ),
                _StatCard(
                  icon: Icons.check_circle,
                  label: 'Đã làm',
                  value: '${_result!.answeredQuestions}',
                  color: Colors.green,
                ),
                _StatCard(
                  icon: Icons.assessment,
                  label: 'Tỉ lệ',
                  value: '${_result!.progressPercentage.toStringAsFixed(0)}%',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.home),
          label: const Text('Về Trang Chủ'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: View detailed answers
          },
          icon: const Icon(Icons.visibility),
          label: const Text('Xem Chi Tiết Câu Trả Lời'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes phút ${remainingSeconds} giây';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double score;
  final double maxScore;
  final Color color;

  const _ScoreBar({
    required this.label,
    required this.score,
    required this.maxScore,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = score / maxScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${score.toStringAsFixed(1)}/$maxScore',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
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
