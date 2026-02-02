import 'package:cloud_firestore/cloud_firestore.dart';

/// Student Answer Model
/// Lưu câu trả lời của học sinh cho mỗi câu hỏi
class StudentAnswerModel {
  final String questionId;
  final dynamic answer; // String, List<String>, int, etc.
  final bool isAnswered;
  final DateTime? answeredAt;
  final int timeSpentSeconds; // Thời gian làm câu này

  const StudentAnswerModel({
    required this.questionId,
    this.answer,
    this.isAnswered = false,
    this.answeredAt,
    this.timeSpentSeconds = 0,
  });

  /// Create from map
  factory StudentAnswerModel.fromMap(Map<String, dynamic> map) {
    return StudentAnswerModel(
      questionId: map['questionId'] as String,
      answer: map['answer'],
      isAnswered: map['isAnswered'] as bool? ?? false,
      answeredAt: map['answeredAt'] != null
          ? (map['answeredAt'] as Timestamp).toDate()
          : null,
      timeSpentSeconds: map['timeSpentSeconds'] as int? ?? 0,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'answer': answer,
      'isAnswered': isAnswered,
      'answeredAt': answeredAt != null 
          ? Timestamp.fromDate(answeredAt!) 
          : null,
      'timeSpentSeconds': timeSpentSeconds,
    };
  }

  /// Copy with
  StudentAnswerModel copyWith({
    String? questionId,
    dynamic answer,
    bool? isAnswered,
    DateTime? answeredAt,
    int? timeSpentSeconds,
  }) {
    return StudentAnswerModel(
      questionId: questionId ?? this.questionId,
      answer: answer ?? this.answer,
      isAnswered: isAnswered ?? this.isAnswered,
      answeredAt: answeredAt ?? this.answeredAt,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
    );
  }

  @override
  String toString() {
    return 'StudentAnswerModel(questionId: $questionId, answer: $answer, isAnswered: $isAnswered)';
  }
}
