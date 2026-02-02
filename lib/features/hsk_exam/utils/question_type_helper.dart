import '../data/models/question_model.dart';

/// Helper to get requirements for each question type
class QuestionTypeHelper {
  /// Get requirements for a question type
  static QuestionTypeRequirement getRequirement(QuestionType type) {
    final typeStr = type.toString().split('.').last;

    // HSK1 Câu 1-5: nghe_dung_sai - nghe câu chọn hình đúng sai
    if (typeStr == 'nghe_dung_sai') {
      return QuestionTypeRequirement(
        requiresAudio: true,
        requiresImage: true,
        requiresText: false,
        optionsType: OptionsType.trueFalse,
        optionsLabels: ['Đúng', 'Sai'],
        description: 'Nghe audio + xem hình, chọn Đúng/Sai',
      );
    }

    // HSK1 Câu 6-10: nghe_tranh_ABC - nghe chọn tranh ABC
    if (typeStr == 'nghe_tranh_ABC') {
      return QuestionTypeRequirement(
        requiresAudio: true,
        requiresImage: false,
        requiresText: false,
        optionsType: OptionsType.images,
        optionsLabels: ['A', 'B', 'C'],
        description: 'Nghe audio, chọn hình đúng (A/B/C)',
        helpText: 'Upload 3 hình ảnh tương ứng A, B, C',
      );
    }

    // HSK1 Câu 11-15: nghe_ngan_hinh - nghe chọn hình ABCDEF
    if (typeStr == 'nghe_ngan_hinh') {
      return QuestionTypeRequirement(
        requiresAudio: true,
        requiresImage: false,
        requiresText: false,
        optionsType: OptionsType.images,
        optionsLabels: ['A', 'B', 'C', 'D', 'E', 'F'],
        description: 'Nghe audio ngắn, chọn hình đúng (A-F)',
        helpText: 'Upload 6 hình ảnh tương ứng A-F',
      );
    }

    // HSK1 Câu 16-20: nghe_ABC - nghe hội thoại chọn ABC
    if (typeStr == 'nghe_ABC') {
      return QuestionTypeRequirement(
        requiresAudio: true,
        requiresImage: false,
        requiresText: true,
        optionsType: OptionsType.text,
        optionsLabels: ['A', 'B', 'C'],
        description: 'Nghe hội thoại, chọn câu trả lời (A/B/C)',
        helpText: 'Nhập 3 đáp án dạng text',
      );
    }

    // HSK1 Câu 21-25: doc_dung_sai - đọc câu chọn đúng sai
    if (typeStr == 'doc_dung_sai') {
      return QuestionTypeRequirement(
        requiresAudio: false,
        requiresImage: false,
        requiresText: true,
        optionsType: OptionsType.trueFalse,
        optionsLabels: ['Đúng', 'Sai'],
        description: 'Đọc câu, chọn Đúng/Sai',
      );
    }

    // HSK1 Câu 26-30: doc_chon_hinh - đọc chữ chọn hình ABCDEF
    if (typeStr == 'doc_chon_hinh') {
      return QuestionTypeRequirement(
        requiresAudio: false,
        requiresImage: false,
        requiresText: true,
        optionsType: OptionsType.images,
        optionsLabels: ['A', 'B', 'C', 'D', 'E', 'F'],
        description: 'Đọc câu, chọn hình đúng (A-F)',
        helpText: 'Upload 6 hình ảnh tương ứng A-F',
      );
    }

    // HSK1 Câu 31-35: doc_chon_ABCDEF - đọc chọn ABCDEF
    if (typeStr == 'doc_chon_ABCDEF') {
      return QuestionTypeRequirement(
        requiresAudio: false,
        requiresImage: false,
        requiresText: true,
        optionsType: OptionsType.text,
        optionsLabels: ['A', 'B', 'C', 'D', 'E', 'F'],
        description: 'Đọc câu, chọn đáp án (A-F)',
        helpText: 'Nhập 6 đáp án dạng text',
      );
    }

    // HSK2 Câu 16-20: nghe_dai_hinh - nghe chọn hình ABCDE
    if (typeStr == 'nghe_dai_hinh') {
      return QuestionTypeRequirement(
        requiresAudio: true,
        requiresImage: false,
        requiresText: false,
        optionsType: OptionsType.images,
        optionsLabels: ['A', 'B', 'C', 'D', 'E'],
        description: 'Nghe audio dài, chọn hình đúng (A-E)',
        helpText: 'Upload 5 hình ảnh tương ứng A-E',
      );
    }

    // HSK2 Câu 41-45: doc_dien_tu_cau_don - chọn 1/6 từ điền vào chỗ trống
    if (typeStr == 'doc_dien_tu_cau_don') {
      return QuestionTypeRequirement(
        requiresAudio: false,
        requiresImage: false,
        requiresText: true,
        optionsType: OptionsType.text,
        optionsLabels: ['A', 'B', 'C', 'D', 'E', 'F'],
        description: 'Chọn từ điền vào chỗ trống',
        helpText: 'Câu hỏi có chỗ trống ___. Nhập 6 từ để chọn.',
      );
    }

    // HSK2 Câu 51-55: doc_ghep_cau - ghép 2 câu phù hợp
    if (typeStr == 'doc_ghep_cau') {
      return QuestionTypeRequirement(
        requiresAudio: false,
        requiresImage: false,
        requiresText: true,
        optionsType: OptionsType.text,
        optionsLabels: ['A', 'B', 'C', 'D', 'E', 'F'],
        description: 'Ghép 2 câu phù hợp với nhau',
        helpText: 'Câu hỏi là nửa đầu, đáp án là nửa sau',
      );
    }

    // Default for other types
    return QuestionTypeRequirement(
      requiresAudio: false,
      requiresImage: false,
      requiresText: true,
      optionsType: OptionsType.text,
      optionsLabels: ['A', 'B', 'C', 'D'],
      description: 'Câu hỏi trắc nghiệm',
    );
  }

  /// Get display name for question type
  static String getDisplayName(QuestionType type) {
    final typeStr = type.toString().split('.').last;
    return typeStr.replaceAll('_', ' ').toUpperCase();
  }

  /// Get section from question type
  static String getSection(QuestionType type) {
    final typeStr = type.toString().split('.').last;
    if (typeStr.startsWith('nghe_')) return 'nghe';
    if (typeStr.startsWith('doc_')) return 'doc';
    if (typeStr.startsWith('viet_')) return 'viet';
    return 'other';
  }

  /// Get range group for HSK level and question type
  static String getRangeGroup(int hskLevel, QuestionType type) {
    final typeStr = type.toString().split('.').last;

    switch (hskLevel) {
      case 1:
        if (typeStr == 'nghe_dung_sai') return '1-5';
        if (typeStr == 'nghe_tranh_ABC') return '6-10';
        if (typeStr == 'nghe_ngan_hinh') return '11-15';
        if (typeStr == 'nghe_ABC') return '16-20';
        if (typeStr == 'doc_dung_sai') return '21-25';
        if (typeStr == 'doc_chon_hinh') return '26-30';
        if (typeStr == 'doc_chon_ABCDEF') return '31-35';
        break;

      case 2:
        if (typeStr == 'nghe_dung_sai') return '1-10';
        if (typeStr == 'nghe_ngan_hinh') return '11-15';
        if (typeStr == 'nghe_dai_hinh') return '16-20';
        if (typeStr == 'nghe_ABC') return '21-35'; // Combined 21-30 and 31-35
        if (typeStr == 'doc_chon_hinh') return '36-40';
        if (typeStr == 'doc_dien_tu_cau_don') return '41-45';
        if (typeStr == 'doc_dung_sai') return '46-50';
        if (typeStr == 'doc_ghep_cau') return '51-60'; // Combined 51-55 and 56-60
        break;

      case 3:
        if (typeStr == 'nghe_ngan_hinh') return '1-5';
        if (typeStr == 'nghe_dai_hinh') return '6-10';
        if (typeStr == 'nghe_dung_sai') return '11-20';
        if (typeStr == 'nghe_ABC') return '21-40'; // Combined 21-30 and 31-40
        if (typeStr == 'doc_ghep_cau') return '41-50'; // Combined 41-45 and 46-50
        if (typeStr == 'doc_dien_tu_cau_don') return '51-55';
        if (typeStr == 'doc_dien_tu_hoi_thoai') return '56-60';
        if (typeStr == 'doc_chon_3') return '61-70';
        if (typeStr == 'viet_sap_xep_tu') return '71-75';
        if (typeStr == 'viet_pinyin') return '76-80';
        break;

      case 4:
        if (typeStr == 'nghe_dung_sai') return '1-10';
        if (typeStr == 'nghe_chon_ngan') return '11-25';
        if (typeStr == 'nghe_chon_dai') return '26-45';
        if (typeStr == 'doc_dien_tu_cau_don') return '46-50';
        if (typeStr == 'doc_dien_tu_hoi_thoai') return '51-55';
        if (typeStr == 'doc_sap_xep') return '56-65';
        if (typeStr == 'doc_chon_1_cau') return '66-79';
        if (typeStr == 'doc_chon_2_cau') return '80-85';
        if (typeStr == 'viet_sap_xep_tu') return '86-95';
        if (typeStr == 'viet_nhin_tranh') return '96-100';
        break;

      case 5:
        if (typeStr == 'nghe_chon_ngan') return '1-20';
        if (typeStr == 'nghe_chon_dai') return '21-45';
        if (typeStr == 'doc_dien_3_tu') return '46-48';
        if (typeStr == 'doc_dien_4_tu') return '49-60'; // Combined multiple ranges
        if (typeStr == 'doc_chon_1_cau') return '61-70';
        if (typeStr == 'doc_chon_lon_nho') return '71-90'; // Combined multiple ranges
        if (typeStr == 'viet_sap_xep_tu') return '91-98';
        if (typeStr == 'viet_doan_van_theo_tu') return '99';
        if (typeStr == 'viet_doan_van_theo_hinh') return '100';
        break;

      case 6:
        if (typeStr == 'nghe_chon_doan_dai') return '1-50'; // Combined all ranges
        if (typeStr == 'doc_cau_chon_cau') return '51-60';
        if (typeStr == 'doc_dien_nhieu_tu') return '61-70';
        if (typeStr == 'doc_dien_5_tu') return '71-80'; // Combined 71-75 and 76-80
        if (typeStr == 'doc_chon_lon_nho') return '81-100'; // Combined all ranges
        if (typeStr == 'doc_nho_viet') return '101';
        break;
    }

    // Default: return empty for manual input
    return '';
  }

  /// Get suggested ranges for a specific HSK level and question type
  /// Returns list of all possible ranges (for cases where same type appears multiple times)
  static List<String> getSuggestedRanges(int hskLevel, QuestionType type) {
    final typeStr = type.toString().split('.').last;
    final ranges = <String>[];

    switch (hskLevel) {
      case 2:
        if (typeStr == 'nghe_ABC') {
          ranges.addAll(['21-30', '31-35']);
        } else if (typeStr == 'doc_ghep_cau') {
          ranges.addAll(['51-55', '56-60']);
        }
        break;

      case 3:
        if (typeStr == 'nghe_ABC') {
          ranges.addAll(['21-30', '31-40']);
        } else if (typeStr == 'doc_ghep_cau') {
          ranges.addAll(['41-45', '46-50']);
        }
        break;

      case 5:
        if (typeStr == 'doc_dien_4_tu') {
          ranges.addAll(['49-52', '53-56', '57-60']);
        } else if (typeStr == 'doc_chon_lon_nho') {
          ranges.addAll(['71-74', '75-78', '79-82', '83-86', '87-90']);
        }
        break;

      case 6:
        if (typeStr == 'nghe_chon_doan_dai') {
          ranges.addAll(['1-15', '16-30', '31-50']);
        } else if (typeStr == 'doc_dien_5_tu') {
          ranges.addAll(['71-75', '76-80']);
        } else if (typeStr == 'doc_chon_lon_nho') {
          ranges.addAll(['81-84', '85-88', '89-92', '93-96', '97-100']);
        }
        break;
    }

    // If no specific ranges, return the default range
    if (ranges.isEmpty) {
      final defaultRange = getRangeGroup(hskLevel, type);
      if (defaultRange.isNotEmpty) {
        ranges.add(defaultRange);
      }
    }

    return ranges;
  }
}

/// Requirements for a question type
class QuestionTypeRequirement {
  final bool requiresAudio;
  final bool requiresImage;
  final bool requiresText;
  final OptionsType optionsType;
  final List<String> optionsLabels;
  final String description;
  final String? helpText;

  const QuestionTypeRequirement({
    required this.requiresAudio,
    required this.requiresImage,
    required this.requiresText,
    required this.optionsType,
    required this.optionsLabels,
    required this.description,
    this.helpText,
  });
}

/// Type of options
enum OptionsType {
  trueFalse, // Đúng/Sai
  text,      // Text answers
  images,    // Image options (A, B, C...)
}
