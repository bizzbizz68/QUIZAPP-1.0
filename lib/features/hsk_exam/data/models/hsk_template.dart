import 'question_model.dart';

/// HSK Exam Template - Cấu trúc đề thi cố định
class HskExamTemplate {
  final int level;
  final String title;
  final int totalQuestions;
  final int duration;
  final int passingScore;
  final List<HskSectionTemplate> sections;

  HskExamTemplate({
    required this.level,
    required this.title,
    required this.totalQuestions,
    required this.duration,
    required this.passingScore,
    required this.sections,
  });
}

/// HSK Section Template - Phần thi (Nghe, Đọc, Viết)
class HskSectionTemplate {
  final String name;
  final int questionCount;
  final List<QuestionGroupTemplate> groups;

  HskSectionTemplate({
    required this.name,
    required this.questionCount,
    required this.groups,
  });
}

/// Question Group Template - Nhóm câu hỏi cùng type
class QuestionGroupTemplate {
  final String range; // "1-5", "6-10", etc.
  final QuestionType type;
  final String description;
  final bool requiresAudio;
  final bool requiresImage;
  final int? imageCount; // Số lượng hình (cho câu chọn hình)
  final int optionsCount;
  final List<String> optionsLabels; // ["A", "B", "C"] hoặc ["Đúng", "Sai"]

  QuestionGroupTemplate({
    required this.range,
    required this.type,
    required this.description,
    required this.requiresAudio,
    required this.requiresImage,
    this.imageCount,
    required this.optionsCount,
    this.optionsLabels = const [],
  });

  /// Get start and end index from range
  List<int> getRangeIndices() {
    final parts = range.split('-');
    return [int.parse(parts[0]), int.parse(parts[1])];
  }

  /// Get question count in this group
  int getQuestionCount() {
    final indices = getRangeIndices();
    return indices[1] - indices[0] + 1;
  }
}
