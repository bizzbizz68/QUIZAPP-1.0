import 'package:cloud_firestore/cloud_firestore.dart';

/// HSK Exam Model
/// Represents an HSK exam with level, duration, and metadata
class ExamModel {
  final String id;
  final String title;
  final int level; // HSK Level: 1-6
  final int duration; // Duration in minutes
  final String description;
  final int totalQuestions;
  final int passingScore;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy; // User ID của người tạo

  ExamModel({
    required this.id,
    required this.title,
    required this.level,
    required this.duration,
    required this.description,
    required this.totalQuestions,
    required this.passingScore,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
  });

  /// Create ExamModel from Firestore document
  factory ExamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ExamModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      level: data['level'] as int? ?? 1,
      duration: data['duration'] as int? ?? 60,
      description: data['description'] as String? ?? '',
      totalQuestions: data['totalQuestions'] as int? ?? 0,
      passingScore: data['passingScore'] as int? ?? 60,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  /// Create ExamModel from Map
  factory ExamModel.fromMap(Map<String, dynamic> map, String id) {
    return ExamModel(
      id: id,
      title: map['title'] as String? ?? '',
      level: map['level'] as int? ?? 1,
      duration: map['duration'] as int? ?? 60,
      description: map['description'] as String? ?? '',
      totalQuestions: map['totalQuestions'] as int? ?? 0,
      passingScore: map['passingScore'] as int? ?? 60,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'] as String? ?? '',
    );
  }

  /// Convert ExamModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'level': level,
      'duration': duration,
      'description': description,
      'totalQuestions': totalQuestions,
      'passingScore': passingScore,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'createdBy': createdBy,
    };
  }

  /// Copy with method for updates
  ExamModel copyWith({
    String? id,
    String? title,
    int? level,
    int? duration,
    String? description,
    int? totalQuestions,
    int? passingScore,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return ExamModel(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      passingScore: passingScore ?? this.passingScore,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Get level display name
  String get levelDisplayName {
    return 'HSK $level';
  }

  /// Get duration display
  String get durationDisplay {
    if (duration < 60) {
      return '$duration phút';
    }
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    return minutes > 0 ? '$hours giờ $minutes phút' : '$hours giờ';
  }

  @override
  String toString() {
    return 'ExamModel(id: $id, title: $title, level: $level, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExamModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
