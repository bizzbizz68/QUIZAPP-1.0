import 'package:cloud_firestore/cloud_firestore.dart';

/// Exam Instance Model - Đề thi template (available for students)
class ExamInstanceModel {
  final String id;
  final int hskLevel;
  final String title;
  final String description;

  // Questions
  final List<String> questionIds; // Array of question bank IDs

  // Timing
  final int durationMinutes; // Duration in minutes
  
  // Scoring
  final int passingScore;
  final int totalQuestions;

  // Status
  final bool isActive;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  ExamInstanceModel({
    required this.id,
    required this.hskLevel,
    required this.title,
    this.description = '',
    required this.questionIds,
    this.durationMinutes = 90,
    this.passingScore = 180,
    required this.totalQuestions,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy = 'system',
  });

  /// Create from Firestore document
  factory ExamInstanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExamInstanceModel(
      id: doc.id,
      hskLevel: data['hskLevel'] ?? 1,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      questionIds: List<String>.from(data['questionIds'] ?? []),
      durationMinutes: data['durationMinutes'] ?? 90,
      passingScore: data['passingScore'] ?? 180,
      totalQuestions: data['totalQuestions'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? 'system',
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'hskLevel': hskLevel,
      'title': title,
      'description': description,
      'questionIds': questionIds,
      'durationMinutes': durationMinutes,
      'passingScore': passingScore,
      'totalQuestions': totalQuestions,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  /// Copy with
  ExamInstanceModel copyWith({
    String? id,
    int? hskLevel,
    String? title,
    String? description,
    List<String>? questionIds,
    int? durationMinutes,
    int? passingScore,
    int? totalQuestions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return ExamInstanceModel(
      id: id ?? this.id,
      hskLevel: hskLevel ?? this.hskLevel,
      title: title ?? this.title,
      description: description ?? this.description,
      questionIds: questionIds ?? this.questionIds,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      passingScore: passingScore ?? this.passingScore,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Get formatted duration
  String get durationFormatted {
    return '$durationMinutes phút';
  }

  @override
  String toString() {
    return 'ExamInstanceModel(id: $id, title: $title, level: HSK $hskLevel)';
  }
}
