import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/exam_instance_model.dart';
import '../../data/models/exam_result_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/student_answer_model.dart';
import '../../data/sources/exam_taking_service.dart';
import '../widgets/timer_widget.dart';
import '../widgets/question_widget.dart';
import '../widgets/answer_sheet_widget.dart';
import 'exam_result_screen.dart';

/// Exam Taking Screen
/// Màn hình làm bài thi
class ExamTakingScreen extends StatefulWidget {
  final String examInstanceId;
  final String? existingResultId; // For resume

  const ExamTakingScreen({
    Key? key,
    required this.examInstanceId,
    this.existingResultId,
  }) : super(key: key);

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  final ExamTakingService _examService = ExamTakingService();
  final PageController _pageController = PageController();

  ExamInstanceModel? _exam;
  List<QuestionModel> _questions = [];
  ExamResultModel? _examResult;
  Map<String, dynamic> _answers = {}; // questionId -> answer
  
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  Timer? _autoSaveTimer;
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _initializeExam();
    _startAutoSave();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeExam() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Start or resume exam
      if (widget.existingResultId != null) {
        // Resume existing exam
        _examResult = await _examService.getExamResult(widget.existingResultId!);
        
        // Load answers
        for (var answer in _examResult!.answers) {
          _answers[answer.questionId] = answer.answer;
        }
      } else {
        // Start new exam
        _examResult = await _examService.startExam(
          examInstanceId: widget.examInstanceId,
          studentId: user.uid,
          studentName: user.displayName ?? user.email ?? 'Student',
        );
      }

      // Load exam with questions
      final examData = await _examService.getExamWithQuestions(widget.examInstanceId);
      _exam = examData['exam'] as ExamInstanceModel;
      _questions = examData['questions'] as List<QuestionModel>;

      _questionStartTime = DateTime.now();

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _saveCurrentAnswer(),
    );
  }

  Future<void> _saveCurrentAnswer() async {
    if (_examResult == null || _questions.isEmpty) return;
    
    final currentQuestion = _questions[_currentQuestionIndex];
    final answer = _answers[currentQuestion.id];
    
    if (answer != null) {
      final timeSpent = _questionStartTime != null
          ? DateTime.now().difference(_questionStartTime!).inSeconds
          : 0;

      try {
        await _examService.saveAnswer(
          examResultId: _examResult!.id,
          questionId: currentQuestion.id,
          answer: answer,
          timeSpentSeconds: timeSpent,
        );
      } catch (e) {
        print('Auto-save error: $e');
      }
    }
  }

  void _onAnswerChanged(dynamic answer) {
    setState(() {
      _answers[_questions[_currentQuestionIndex].id] = answer;
    });
  }

  Future<void> _goToQuestion(int index) async {
    await _saveCurrentAnswer();
    
    setState(() {
      _currentQuestionIndex = index;
      _questionStartTime = DateTime.now();
    });
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _nextQuestion() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      await _goToQuestion(_currentQuestionIndex + 1);
    }
  }

  Future<void> _previousQuestion() async {
    if (_currentQuestionIndex > 0) {
      await _goToQuestion(_currentQuestionIndex - 1);
    }
  }

  Future<void> _submitExam() async {
    // Save current answer first
    await _saveCurrentAnswer();

    // Confirm submission
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nộp bài thi?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tổng câu: ${_questions.length}'),
            Text('Đã làm: ${_answers.length}'),
            Text('Chưa làm: ${_questions.length - _answers.length}'),
            const SizedBox(height: 16),
            const Text(
              'Bạn có chắc muốn nộp bài không?\nKhông thể chỉnh sửa sau khi nộp.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiếp tục làm'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await _examService.submitExam(
        examResultId: _examResult!.id,
        isTimeout: false,
      );

      if (mounted) {
        // Navigate to result screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExamResultScreen(examResultId: result.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi nộp bài: $e')),
        );
      }
    }
  }

  void _onTimeUp() {
    _autoSubmitOnTimeout();
  }

  Future<void> _autoSubmitOnTimeout() async {
    try {
      final result = await _examService.autoSubmitOnTimeout(_examResult!.id);
      
      if (mounted) {
        // Show timeout dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('⏰ Hết giờ'),
            content: const Text('Bài thi đã được tự động nộp.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // Navigate to result
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExamResultScreen(examResultId: result.id),
          ),
        );
      }
    } catch (e) {
      print('Auto-submit error: $e');
    }
  }

  void _showAnswerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AnswerSheetWidget(
        questions: _questions,
        answers: _answers,
        currentIndex: _currentQuestionIndex,
        onQuestionTap: (index) {
          Navigator.pop(context);
          _goToQuestion(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isSubmitting) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang nộp bài...'),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thoát bài thi?'),
            content: const Text(
              'Bài làm của bạn sẽ được lưu tự động.\nBạn có thể quay lại làm tiếp sau.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Ở lại'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Thoát'),
              ),
            ],
          ),
        );
        return confirmed ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_exam?.title ?? 'Exam'),
          backgroundColor: Colors.blue,
          actions: [
            // Timer
            if (_examResult != null)
              TimerWidget(
                startTime: _examResult!.startedAt,
                durationMinutes: _examResult!.allowedDurationMinutes,
                onTimeUp: _onTimeUp,
              ),
            
            // Answer sheet button
            IconButton(
              onPressed: _showAnswerSheet,
              icon: const Icon(Icons.grid_on),
              tooltip: 'Bảng đáp án',
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

            // Question counter
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Câu ${_currentQuestionIndex + 1}/${_questions.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Đã làm: ${_answers.length}/${_questions.length}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Question content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                onPageChanged: (index) {
                  setState(() => _currentQuestionIndex = index);
                },
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  final currentAnswer = _answers[question.id];

                  return QuestionWidget(
                    question: question,
                    questionNumber: index + 1,
                    answer: currentAnswer,
                    onAnswerChanged: _onAnswerChanged,
                  );
                },
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Previous button
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _previousQuestion,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Câu trước'),
                      ),
                    ),
                  
                  if (_currentQuestionIndex > 0)
                    const SizedBox(width: 16),

                  // Next or Submit button
                  Expanded(
                    flex: 2,
                    child: _currentQuestionIndex < _questions.length - 1
                        ? ElevatedButton.icon(
                            onPressed: _nextQuestion,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Câu tiếp theo'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _submitExam,
                            icon: const Icon(Icons.check),
                            label: const Text('Nộp bài'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
