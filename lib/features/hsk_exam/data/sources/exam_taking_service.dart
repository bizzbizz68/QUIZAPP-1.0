import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exam_instance_model.dart';
import '../models/exam_result_model.dart';
import '../models/student_answer_model.dart';
import '../models/question_model.dart';
import '../../utils/hsk_scoring_engine.dart';

/// Exam Taking Service
/// Handle logic làm bài thi cho học sinh
class ExamTakingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ============================================================
  /// START EXAM
  /// ============================================================

  /// Start a new exam session
  Future<ExamResultModel> startExam({
    required String examInstanceId,
    required String studentId,
    required String studentName,
  }) async {
    try {
      // 1. Get exam instance
      final examDoc = await _firestore
          .collection('exam_instances')
          .doc(examInstanceId)
          .get();

      if (!examDoc.exists) {
        throw Exception('Exam not found');
      }

      final exam = ExamInstanceModel.fromFirestore(examDoc);

      // 2. Check if student already started
      final existingResult = await _firestore
          .collection('exam_results')
          .where('examInstanceId', isEqualTo: examInstanceId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (existingResult.docs.isNotEmpty) {
        // Resume existing exam
        return ExamResultModel.fromFirestore(existingResult.docs.first);
      }

      // 3. Create new exam result
      final result = ExamResultModel(
        id: '',
        examInstanceId: examInstanceId,
        studentId: studentId,
        studentName: studentName,
        examTitle: exam.title,
        hskLevel: exam.hskLevel,
        answers: [], // Empty initially
        totalQuestions: exam.questionIds.length,
        answeredQuestions: 0,
        startedAt: DateTime.now(),
        durationSeconds: 0,
        allowedDurationMinutes: exam.durationMinutes,
        status: ExamStatus.inProgress,
      );

      // 4. Save to Firestore
      final docRef = await _firestore
          .collection('exam_results')
          .add(result.toMap());

      return result.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to start exam: $e');
    }
  }

  /// ============================================================
  /// GET EXAM DATA
  /// ============================================================

  /// Get exam instance with questions
  Future<Map<String, dynamic>> getExamWithQuestions(String examInstanceId) async {
    try {
      // 1. Get exam instance
      final examDoc = await _firestore
          .collection('exam_instances')
          .doc(examInstanceId)
          .get();

      if (!examDoc.exists) {
        throw Exception('Exam not found');
      }

      final exam = ExamInstanceModel.fromFirestore(examDoc);

      // 2. Get all questions
      final questions = <QuestionModel>[];
      
      // TODO: Update exam model to store question metadata (level, section, type)
      // Currently exam only stores questionIds without hierarchical path info
      // Need to refactor exam structure to support hierarchical question loading
      
      // Temporary: Load from exam's questionDetails if available
      // Or implement a mapping service to resolve questionId to hierarchical path

      return {
        'exam': exam,
        'questions': questions,
      };
    } catch (e) {
      throw Exception('Failed to load exam: $e');
    }
  }

  /// ============================================================
  /// ANSWER SUBMISSION
  /// ============================================================

  /// Save student answer for a question
  Future<void> saveAnswer({
    required String examResultId,
    required String questionId,
    required dynamic answer,
    required int timeSpentSeconds,
  }) async {
    try {
      final resultDoc = await _firestore
          .collection('exam_results')
          .doc(examResultId)
          .get();

      if (!resultDoc.exists) {
        throw Exception('Exam result not found');
      }

      final result = ExamResultModel.fromFirestore(resultDoc);
      
      // Update or add answer
      final answers = List<StudentAnswerModel>.from(result.answers);
      final existingIndex = answers.indexWhere((a) => a.questionId == questionId);
      
      final newAnswer = StudentAnswerModel(
        questionId: questionId,
        answer: answer,
        isAnswered: true,
        answeredAt: DateTime.now(),
        timeSpentSeconds: timeSpentSeconds,
      );

      if (existingIndex >= 0) {
        answers[existingIndex] = newAnswer;
      } else {
        answers.add(newAnswer);
      }

      // Count answered questions
      final answeredCount = answers.where((a) => a.isAnswered).length;

      // Update Firestore
      await _firestore.collection('exam_results').doc(examResultId).update({
        'answers': answers.map((a) => a.toMap()).toList(),
        'answeredQuestions': answeredCount,
      });
    } catch (e) {
      throw Exception('Failed to save answer: $e');
    }
  }

  /// ============================================================
  /// SUBMIT EXAM
  /// ============================================================

  /// Submit exam and calculate scores
  Future<ExamResultModel> submitExam({
    required String examResultId,
    bool isTimeout = false,
  }) async {
    try {
      // 1. Get exam result
      final resultDoc = await _firestore
          .collection('exam_results')
          .doc(examResultId)
          .get();

      if (!resultDoc.exists) {
        throw Exception('Exam result not found');
      }

      final result = ExamResultModel.fromFirestore(resultDoc);

      // 2. Get exam with questions
      final examData = await getExamWithQuestions(result.examInstanceId);
      final questions = examData['questions'] as List<QuestionModel>;

      // 3. Calculate scores by section
      int correctListening = 0;
      int correctReading = 0;
      int correctWriting = 0;

      for (var answer in result.answers) {
        if (!answer.isAnswered) continue;

        final question = questions.firstWhere(
          (q) => q.id == answer.questionId,
          orElse: () => questions.first,
        );
        
        if (question.id == null) continue; // Skip if question not found

        // Check if answer is correct
        final isCorrect = _checkAnswer(answer.answer, question.correctAnswer);

        if (isCorrect) {
          switch (question.section) {
            case 'nghe':
              correctListening++;
              break;
            case 'doc':
              correctReading++;
              break;
            case 'viet':
              correctWriting++;
              break;
          }
        }
      }

      // 4. Calculate final scores using HSK Scoring Engine
      final hskResult = HSKScoringEngine.getFinalResult(
        'HSK${result.hskLevel}',
        correctListening,
        correctReading,
        correctWriting,
      );

      // 5. Calculate duration
      final duration = DateTime.now().difference(result.startedAt).inSeconds;

      // 6. Update result
      final updatedResult = result.copyWith(
        hskResult: hskResult,
        listeningScore: hskResult.listening,
        readingScore: hskResult.reading,
        writingScore: hskResult.writing,
        totalScore: hskResult.totalScore,
        isPassed: hskResult.isPassed,
        submittedAt: DateTime.now(),
        durationSeconds: duration,
        status: isTimeout ? ExamStatus.timeout : ExamStatus.graded,
      );

      // 7. Save to Firestore
      await _firestore
          .collection('exam_results')
          .doc(examResultId)
          .update(updatedResult.toMap());

      return updatedResult;
    } catch (e) {
      throw Exception('Failed to submit exam: $e');
    }
  }

  /// Check if answer is correct
  bool _checkAnswer(dynamic studentAnswer, dynamic correctAnswer) {
    if (studentAnswer == null) return false;

    // Handle List answers (multiple choice)
    if (correctAnswer is List) {
      if (studentAnswer is! List) return false;
      final studentList = studentAnswer as List;
      final correctList = correctAnswer as List;
      
      if (studentList.length != correctList.length) return false;
      
      for (var answer in studentList) {
        if (!correctList.contains(answer)) return false;
      }
      return true;
    }

    // Handle single answer
    return studentAnswer.toString().trim().toLowerCase() ==
        correctAnswer.toString().trim().toLowerCase();
  }

  /// ============================================================
  /// GET STUDENT RESULTS
  /// ============================================================

  /// Get exam result by ID
  Future<ExamResultModel> getExamResult(String examResultId) async {
    try {
      final doc = await _firestore
          .collection('exam_results')
          .doc(examResultId)
          .get();

      if (!doc.exists) {
        throw Exception('Exam result not found');
      }

      return ExamResultModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to load exam result: $e');
    }
  }

  /// Get all exam results for a student
  Stream<List<ExamResultModel>> getStudentExamHistory(String studentId) {
    // TODO: Add orderBy after creating Firestore composite index
    // For now, sort in memory
    return _firestore
        .collection('exam_results')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          final results = snapshot.docs
              .map((doc) => ExamResultModel.fromFirestore(doc))
              .toList();
          
          // Sort by startedAt in memory
          results.sort((a, b) => b.startedAt.compareTo(a.startedAt));
          
          return results;
        });
  }

  /// ============================================================
  /// AVAILABLE EXAMS
  /// ============================================================

  /// Get available exams for student (active exams)
  Stream<List<ExamInstanceModel>> getAvailableExams(int? hskLevel) {
    Query query = _firestore
        .collection('exam_instances')
        .where('isActive', isEqualTo: true);

    if (hskLevel != null) {
      query = query.where('hskLevel', isEqualTo: hskLevel);
    }

    // TODO: Add orderBy after creating Firestore composite index
    // For now, sort in memory to avoid index requirement
    return query
        .snapshots()
        .map((snapshot) {
          final exams = snapshot.docs
              .map((doc) => ExamInstanceModel.fromFirestore(doc))
              .toList();
          
          // Sort by createdAt in memory
          exams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return exams;
        });
  }

  /// Check if student already took this exam
  Future<ExamResultModel?> getExistingResult({
    required String examInstanceId,
    required String studentId,
  }) async {
    try {
      // TODO: This query needs composite index for optimal performance
      // For now, filter by one field and check other in memory
      final snapshot = await _firestore
          .collection('exam_results')
          .where('examInstanceId', isEqualTo: examInstanceId)
          .get();

      // Filter by studentId in memory
      final docs = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['studentId'] == studentId;
      }).toList();

      if (docs.isEmpty) return null;

      return ExamResultModel.fromFirestore(docs.first);
    } catch (e) {
      return null;
    }
  }

  /// ============================================================
  /// AUTO-SUBMIT ON TIMEOUT
  /// ============================================================

  /// Auto-submit exam when time is up
  Future<ExamResultModel> autoSubmitOnTimeout(String examResultId) async {
    return await submitExam(
      examResultId: examResultId,
      isTimeout: true,
    );
  }
}
