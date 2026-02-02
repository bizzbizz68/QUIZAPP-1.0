/**
 * ======================================================
 * HSK SCORING ENGINE (Converted from TypeScript)
 * ======================================================
 * 
 * Tính điểm và generate báo cáo kết quả thi HSK
 * Dựa trên chuẩn Prep Standard
 */

/// HSK Task Types
enum HSKTask {
  // Nhóm Nghe
  listeningTrueFalseImage,
  listeningSelectionImage,
  listeningMatchImageShort,
  listeningMatchImageLong,
  listeningDialogueMultipleChoice,
  listeningTrueFalseDialogue,
  listeningDialogueShort,
  listeningDialogueLong,
  listeningComprehensionLong,
  
  // Nhóm Đọc
  readingTrueFalseText,
  readingMatchImageText,
  readingFillBlankSingle,
  readingFillBlankDialogue,
  readingSentenceMatching,
  readingComprehensionShort,
  readingSentenceReorderLogic,
  readingComprehensionSingle,
  readingComprehensionMultiChoice,
  readingFillBlankContext,
  readingComprehensionGroup,
  readingIdentifyError,
  readingFillBlankSentence,
  
  // Nhóm Viết
  writingSentenceReorder,
  writingFillBlankPinyin,
  writingImageDescription,
  writingTopicEssay,
  writingImageEssay,
  writingRecallSummary,
}

/// Extension to get task description
extension HSKTaskExtension on HSKTask {
  String get description {
    switch (this) {
      // Listening
      case HSKTask.listeningTrueFalseImage:
        return 'Nghe câu chọn hình đúng/sai';
      case HSKTask.listeningSelectionImage:
        return 'Nghe chọn tranh ABC';
      case HSKTask.listeningMatchImageShort:
        return 'Nghe chọn hình ABCDEF';
      case HSKTask.listeningMatchImageLong:
        return 'Nghe chọn hình dài';
      case HSKTask.listeningDialogueMultipleChoice:
        return 'Nghe hội thoại chọn ABC';
      case HSKTask.listeningTrueFalseDialogue:
        return 'Nghe hội thoại đúng/sai';
      case HSKTask.listeningDialogueShort:
        return 'Nghe đoạn hội thoại ngắn';
      case HSKTask.listeningDialogueLong:
        return 'Nghe hiểu hội thoại dài';
      case HSKTask.listeningComprehensionLong:
        return 'Nghe hiểu đoạn dài';
      
      // Reading
      case HSKTask.readingTrueFalseText:
        return 'Đọc câu chọn đúng sai';
      case HSKTask.readingMatchImageText:
        return 'Đọc chữ chọn hình ABCDEF';
      case HSKTask.readingFillBlankSingle:
        return 'Đọc chọn từ điền chỗ trống';
      case HSKTask.readingFillBlankDialogue:
        return 'Điền từ vào hội thoại';
      case HSKTask.readingSentenceMatching:
        return 'Ghép câu';
      case HSKTask.readingComprehensionShort:
        return 'Đọc hiểu ngắn';
      case HSKTask.readingSentenceReorderLogic:
        return 'Sắp xếp câu theo logic';
      case HSKTask.readingComprehensionSingle:
        return 'Đọc hiểu đơn';
      case HSKTask.readingComprehensionMultiChoice:
        return 'Đọc hiểu nhiều lựa chọn';
      case HSKTask.readingFillBlankContext:
        return 'Điền từ theo ngữ cảnh';
      case HSKTask.readingComprehensionGroup:
        return 'Đọc hiểu nhóm';
      case HSKTask.readingIdentifyError:
        return 'Tìm lỗi sai';
      case HSKTask.readingFillBlankSentence:
        return 'Điền từ vào câu';
      
      // Writing
      case HSKTask.writingSentenceReorder:
        return 'Sắp xếp từ thành câu';
      case HSKTask.writingFillBlankPinyin:
        return 'Điền từ theo phiên âm';
      case HSKTask.writingImageDescription:
        return 'Mô tả hình ảnh';
      case HSKTask.writingTopicEssay:
        return 'Viết luận theo chủ đề';
      case HSKTask.writingImageEssay:
        return 'Viết luận theo hình';
      case HSKTask.writingRecallSummary:
        return 'Viết tóm tắt';
    }
  }
}

/// HSK Section configuration
class HSKSection {
  final String range;
  final HSKTask task;
  final String desc;

  const HSKSection({
    required this.range,
    required this.task,
    required this.desc,
  });
}

/// HSK Level configuration
class HSKLevelConfig {
  final List<HSKSection> listening;
  final List<HSKSection> reading;
  final List<HSKSection>? writing;
  final int passScore;
  final int totalMaxScore;

  const HSKLevelConfig({
    required this.listening,
    required this.reading,
    this.writing,
    required this.passScore,
    required this.totalMaxScore,
  });
}

/// HSK Configuration for all levels
class HSKConfig {
  static const Map<String, HSKLevelConfig> config = {
    'HSK1': HSKLevelConfig(
      passScore: 120,
      totalMaxScore: 200,
      listening: [
        HSKSection(
          range: '1-5',
          task: HSKTask.listeningTrueFalseImage,
          desc: 'Nghe câu chọn hình đúng/sai',
        ),
        HSKSection(
          range: '6-10',
          task: HSKTask.listeningSelectionImage,
          desc: 'Nghe chọn tranh ABC',
        ),
        HSKSection(
          range: '11-15',
          task: HSKTask.listeningMatchImageShort,
          desc: 'Nghe chọn hình ABCDEF',
        ),
        HSKSection(
          range: '16-20',
          task: HSKTask.listeningDialogueMultipleChoice,
          desc: 'Nghe hội thoại chọn ABC',
        ),
      ],
      reading: [
        HSKSection(
          range: '21-25',
          task: HSKTask.readingTrueFalseText,
          desc: 'Đọc câu chọn đúng sai',
        ),
        HSKSection(
          range: '26-30',
          task: HSKTask.readingMatchImageText,
          desc: 'Đọc chữ chọn hình ABCDEF',
        ),
        HSKSection(
          range: '31-35',
          task: HSKTask.readingFillBlankSingle,
          desc: 'Đọc chọn từ điền chỗ trống',
        ),
      ],
    ),
    'HSK2': HSKLevelConfig(
      passScore: 120,
      totalMaxScore: 200,
      listening: [
        HSKSection(
          range: '1-35',
          task: HSKTask.listeningDialogueMultipleChoice,
          desc: 'Nghe hiểu',
        ),
      ],
      reading: [
        HSKSection(
          range: '36-60',
          task: HSKTask.readingComprehensionShort,
          desc: 'Đọc hiểu',
        ),
      ],
    ),
    'HSK3': HSKLevelConfig(
      passScore: 180,
      totalMaxScore: 300,
      listening: [
        HSKSection(
          range: '1-40',
          task: HSKTask.listeningDialogueMultipleChoice,
          desc: 'Nghe hiểu',
        ),
      ],
      reading: [
        HSKSection(
          range: '41-70',
          task: HSKTask.readingComprehensionShort,
          desc: 'Đọc hiểu',
        ),
      ],
      writing: [
        HSKSection(
          range: '71-80',
          task: HSKTask.writingSentenceReorder,
          desc: 'Viết',
        ),
      ],
    ),
    'HSK4': HSKLevelConfig(
      passScore: 180,
      totalMaxScore: 300,
      listening: [
        HSKSection(
          range: '1-45',
          task: HSKTask.listeningDialogueLong,
          desc: 'Nghe hiểu',
        ),
      ],
      reading: [
        HSKSection(
          range: '46-85',
          task: HSKTask.readingComprehensionGroup,
          desc: 'Đọc hiểu',
        ),
      ],
      writing: [
        HSKSection(
          range: '86-100',
          task: HSKTask.writingSentenceReorder,
          desc: 'Viết',
        ),
      ],
    ),
    'HSK5': HSKLevelConfig(
      passScore: 180,
      totalMaxScore: 300,
      listening: [
        HSKSection(
          range: '1-45',
          task: HSKTask.listeningDialogueLong,
          desc: 'Nghe hiểu',
        ),
      ],
      reading: [
        HSKSection(
          range: '46-90',
          task: HSKTask.readingComprehensionGroup,
          desc: 'Đọc hiểu',
        ),
      ],
      writing: [
        HSKSection(
          range: '91-100',
          task: HSKTask.writingSentenceReorder,
          desc: 'Viết',
        ),
      ],
    ),
    'HSK6': HSKLevelConfig(
      passScore: 180,
      totalMaxScore: 300,
      listening: [
        HSKSection(
          range: '1-50',
          task: HSKTask.listeningComprehensionLong,
          desc: 'Nghe hiểu',
        ),
      ],
      reading: [
        HSKSection(
          range: '51-100',
          task: HSKTask.readingComprehensionGroup,
          desc: 'Đọc hiểu',
        ),
      ],
      writing: [
        HSKSection(
          range: '101-101',
          task: HSKTask.writingRecallSummary,
          desc: 'Viết tóm tắt',
        ),
      ],
    ),
  };
}

/// Exam result model
class HSKExamResult {
  final double listening;
  final double reading;
  final double writing;
  final double totalScore;
  final bool isPassed;
  final Map<String, String> details;

  const HSKExamResult({
    required this.listening,
    required this.reading,
    required this.writing,
    required this.totalScore,
    required this.isPassed,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
        'listening': listening,
        'reading': reading,
        'writing': writing,
        'totalScore': totalScore,
        'isPassed': isPassed,
        'details': details,
      };
}

/// HSK Scoring Engine
class HSKScoringEngine {
  /// Calculate section score (0-100)
  static double calculateSectionScore(int correct, int totalQuestions) {
    if (totalQuestions == 0) return 0;
    return (correct / totalQuestions) * 100;
  }

  /// Get total question count from sections
  static int _getQuestionCount(List<HSKSection> sections) {
    final lastRange = sections.last.range.split('-');
    final firstRange = sections.first.range.split('-');
    return int.parse(lastRange[1]) - (int.parse(firstRange[0]) - 1);
  }

  /// Calculate final exam result
  static HSKExamResult getFinalResult(
    String level,
    int correctL,
    int correctR, [
    int correctW = 0,
  ]) {
    final config = HSKConfig.config[level];
    
    if (config == null) {
      throw ArgumentError('Invalid HSK level: $level');
    }

    final totalL = _getQuestionCount(config.listening);
    final totalR = _getQuestionCount(config.reading);
    final totalW = config.writing != null
        ? (level == 'HSK6' ? 1 : _getQuestionCount(config.writing!))
        : 0;

    final listening = (calculateSectionScore(correctL, totalL) * 100).round() / 100;
    final reading = (calculateSectionScore(correctR, totalR) * 100).round() / 100;
    final writing = (calculateSectionScore(correctW, totalW) * 100).round() / 100;

    final totalScore = (listening + reading + writing * 100).round() / 100;
    final isPassed = totalScore >= config.passScore;

    return HSKExamResult(
      listening: listening,
      reading: reading,
      writing: writing,
      totalScore: totalScore,
      isPassed: isPassed,
      details: {
        'lCorrect': '$correctL/$totalL',
        'rCorrect': '$correctR/$totalR',
        'wCorrect': config.writing != null ? '$correctW/$totalW' : 'N/A',
      },
    );
  }
}
