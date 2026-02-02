import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_answer_model.dart';
import '../../utils/hsk_scoring_engine.dart';

/// Exam Result Model
/// Lưu kết quả thi của học sinh
class ExamResultModel {
  final String id;
  final String examInstanceId; // Reference to ExamInstanceModel
  final String studentId;
  final String studentName;
  final String examTitle;
  final int hskLevel;

  // Answers
  final List<StudentAnswerModel> answers;
  final int totalQuestions;
  final int answeredQuestions;

  // Scores (from HSK Scoring Engine)
  final HSKExamResult? hskResult;
  final double listeningScore; // 0-100
  final double readingScore; // 0-100
  final double writingScore; // 0-100
  final double totalScore; // Sum of above
  final bool isPassed;

  // Timing
  final DateTime startedAt;
  final DateTime? submittedAt;
  final int durationSeconds; // Actual time taken
  final int allowedDurationMinutes; // Time limit

  // Status
  final ExamStatus status;

  const ExamResultModel({
    required this.id,
    required this.examInstanceId,
    required this.studentId,
    required this.studentName,
    required this.examTitle,
    required this.hskLevel,
    required this.answers,
    required this.totalQuestions,
    required this.answeredQuestions,
    this.hskResult,
    this.listeningScore = 0,
    this.readingScore = 0,
    this.writingScore = 0,
    this.totalScore = 0,
    this.isPassed = false,
    required this.startedAt,
    this.submittedAt,
    required this.durationSeconds,
    required this.allowedDurationMinutes,
    this.status = ExamStatus.inProgress,
  });

  /// Create from Firestore
  factory ExamResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ExamResultModel(
      id: doc.id,
      examInstanceId: data['examInstanceId'] as String,
      studentId: data['studentId'] as String,
      studentName: data['studentName'] as String? ?? '',
      examTitle: data['examTitle'] as String? ?? '',
      hskLevel: data['hskLevel'] as int? ?? 1,
      answers: (data['answers'] as List<dynamic>?)
              ?.map((a) => StudentAnswerModel.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      totalQuestions: data['totalQuestions'] as int? ?? 0,
      answeredQuestions: data['answeredQuestions'] as int? ?? 0,
      hskResult: data['hskResult'] != null
          ? _parseHSKResult(data['hskResult'] as Map<String, dynamic>)
          : null,
      listeningScore: (data['listeningScore'] as num?)?.toDouble() ?? 0,
      readingScore: (data['readingScore'] as num?)?.toDouble() ?? 0,
      writingScore: (data['writingScore'] as num?)?.toDouble() ?? 0,
      totalScore: (data['totalScore'] as num?)?.toDouble() ?? 0,
      isPassed: data['isPassed'] as bool? ?? false,
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      submittedAt: data['submittedAt'] != null
          ? (data['submittedAt'] as Timestamp).toDate()
          : null,
      durationSeconds: data['durationSeconds'] as int? ?? 0,
      allowedDurationMinutes: data['allowedDurationMinutes'] as int? ?? 90,
      status: ExamStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => ExamStatus.inProgress,
      ),
    );
  }

  /// Parse HSK Result from map
  static HSKExamResult _parseHSKResult(Map<String, dynamic> map) {
    return HSKExamResult(
      listening: (map['listening'] as num?)?.toDouble() ?? 0,
      reading: (map['reading'] as num?)?.toDouble() ?? 0,
      writing: (map['writing'] as num?)?.toDouble() ?? 0,
      totalScore: (map['totalScore'] as num?)?.toDouble() ?? 0,
      isPassed: map['isPassed'] as bool? ?? false,
      details: Map<String, String>.from(map['details'] ?? {}),
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'examInstanceId': examInstanceId,
      'studentId': studentId,
      'studentName': studentName,
      'examTitle': examTitle,
      'hskLevel': hskLevel,
      'answers': answers.map((a) => a.toMap()).toList(),
      'totalQuestions': totalQuestions,
      'answeredQuestions': answeredQuestions,
      'hskResult': hskResult?.toJson(),
      'listeningScore': listeningScore,
      'readingScore': readingScore,
      'writingScore': writingScore,
      'totalScore': totalScore,
      'isPassed': isPassed,
      'startedAt': Timestamp.fromDate(startedAt),
      'submittedAt': submittedAt != null 
          ? Timestamp.fromDate(submittedAt!) 
          : null,
      'durationSeconds': durationSeconds,
      'allowedDurationMinutes': allowedDurationMinutes,
      'status': status.toString().split('.').last,
    };
  }

  /// Copy with
  ExamResultModel copyWith({
    String? id,
    String? examInstanceId,
    String? studentId,
    String? studentName,
    String? examTitle,
    int? hskLevel,
    List<StudentAnswerModel>? answers,
    int? totalQuestions,
    int? answeredQuestions,
    HSKExamResult? hskResult,
    double? listeningScore,
    double? readingScore,
    double? writingScore,
    double? totalScore,
    bool? isPassed,
    DateTime? startedAt,
    DateTime? submittedAt,
    int? durationSeconds,
    int? allowedDurationMinutes,
    ExamStatus? status,
  }) {
    return ExamResultModel(
      id: id ?? this.id,
      examInstanceId: examInstanceId ?? this.examInstanceId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      examTitle: examTitle ?? this.examTitle,
      hskLevel: hskLevel ?? this.hskLevel,
      answers: answers ?? this.answers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
      hskResult: hskResult ?? this.hskResult,
      listeningScore: listeningScore ?? this.listeningScore,
      readingScore: readingScore ?? this.readingScore,
      writingScore: writingScore ?? this.writingScore,
      totalScore: totalScore ?? this.totalScore,
      isPassed: isPassed ?? this.isPassed,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      allowedDurationMinutes: allowedDurationMinutes ?? this.allowedDurationMinutes,
      status: status ?? this.status,
    );
  }

  /// Get progress percentage
  double get progressPercentage {
    if (totalQuestions == 0) return 0;
    return (answeredQuestions / totalQuestions) * 100;
  }

  /// Get time remaining (if in progress)
  int get timeRemainingSeconds {
    if (status != ExamStatus.inProgress) return 0;
    final allowedSeconds = allowedDurationMinutes * 60;
    final elapsed = DateTime.now().difference(startedAt).inSeconds;
    return (allowedSeconds - elapsed).clamp(0, allowedSeconds);
  }

  /// Check if time is up
  bool get isTimeUp {
    return timeRemainingSeconds <= 0;
  }

  @override
  String toString() {
    return 'ExamResultModel(id: $id, student: $studentName, score: $totalScore, passed: $isPassed)';
  }
}

/// Exam Status
enum ExamStatus {
  notStarted,   // Chưa bắt đầu
  inProgress,   // Đang làm
  submitted,    // Đã nộp bài
  graded,       // Đã chấm xong
  timeout,      // Hết giờ (auto-submit)
}

extension ExamStatusExtension on ExamStatus {
  String get displayName {
    switch (this) {
      case ExamStatus.notStarted:
        return 'Chưa bắt đầu';
      case ExamStatus.inProgress:
        return 'Đang làm bài';
      case ExamStatus.submitted:
        return 'Đã nộp bài';
      case ExamStatus.graded:
        return 'Đã chấm điểm';
      case ExamStatus.timeout:
        return 'Hết giờ';
    }
  }

  String get icon {
    switch (this) {
      case ExamStatus.notStarted:
        return '⏸️';
      case ExamStatus.inProgress:
        return '▶️';
      case ExamStatus.submitted:
        return '✅';
      case ExamStatus.graded:
        return '📊';
      case ExamStatus.timeout:
        return '⏰';
    }
  }
}
