import '../data/models/question_model.dart';

/// Structure item representing a group of questions
class StructureItem {
  final String range; // "1-5", "6-10", etc.
  final QuestionType type;
  final String description;
  final String section; // 'listening', 'reading', 'writing'

  const StructureItem({
    required this.range,
    required this.type,
    required this.description,
    required this.section,
  });

  int get startQuestion => int.parse(range.split('-').first);
  int get endQuestion => int.parse(range.split('-').last);
  int get questionCount => endQuestion - startQuestion + 1;
}

/// HSK Exam Structure Definition
/// Defines the exact question order, types, and ranges for each HSK level
class HskStructure {

  /// Get complete structure for an HSK level
  static List<StructureItem> getStructure(int hskLevel) {
    switch (hskLevel) {
      case 1:
        return _hsk1Structure;
      case 2:
        return _hsk2Structure;
      case 3:
        return _hsk3Structure;
      case 4:
        return _hsk4Structure;
      case 5:
        return _hsk5Structure;
      case 6:
        return _hsk6Structure;
      default:
        return [];
    }
  }

  /// Get structure filtered by section
  static List<StructureItem> getStructureBySection(int hskLevel, String section) {
    final sectionMap = {
      'nghe': 'listening',
      'doc': 'reading',
      'viet': 'writing',
    };
    
    final targetSection = sectionMap[section] ?? section;
    return getStructure(hskLevel)
        .where((item) => item.section == targetSection)
        .toList();
  }

  /// Get unique question types for HSK level and section (in order)
  static List<QuestionType> getQuestionTypes(int hskLevel, String? section) {
    List<StructureItem> items;
    
    if (section != null) {
      items = getStructureBySection(hskLevel, section);
    } else {
      items = getStructure(hskLevel);
    }

    // Keep order and remove duplicates
    final seen = <QuestionType>{};
    final types = <QuestionType>[];
    
    for (final item in items) {
      if (!seen.contains(item.type)) {
        seen.add(item.type);
        types.add(item.type);
      }
    }
    
    return types;
  }

  /// Get range options for a specific question type
  static List<String> getRangeOptions(int hskLevel, QuestionType type) {
    return getStructure(hskLevel)
        .where((item) => item.type == type)
        .map((item) => item.range)
        .toList();
  }

  /// Get structure item by range
  static StructureItem? getItemByRange(int hskLevel, String range) {
    try {
      return getStructure(hskLevel).firstWhere((item) => item.range == range);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // HSK 1 STRUCTURE
  // ============================================
  static const List<StructureItem> _hsk1Structure = [
    // === LISTENING ===
    StructureItem(
      range: '1-5',
      type: QuestionType.nghe_dung_sai,
      description: 'Nghe câu chọn hình đúng/sai',
      section: 'listening',
    ),
    StructureItem(
      range: '6-10',
      type: QuestionType.nghe_tranh_ABC,
      description: 'Nghe chọn tranh ABC',
      section: 'listening',
    ),
    StructureItem(
      range: '11-15',
      type: QuestionType.nghe_ngan_hinh,
      description: 'Nghe chọn hình ABCDEF',
      section: 'listening',
    ),
    StructureItem(
      range: '16-20',
      type: QuestionType.nghe_ABC,
      description: 'Nghe hội thoại chọn ABC',
      section: 'listening',
    ),
    // === READING ===
    StructureItem(
      range: '21-25',
      type: QuestionType.doc_dung_sai,
      description: 'Đọc câu chọn đúng sai',
      section: 'reading',
    ),
    StructureItem(
      range: '26-30',
      type: QuestionType.doc_chon_hinh,
      description: 'Đọc chữ chọn hình ABCDEF',
      section: 'reading',
    ),
    StructureItem(
      range: '31-35',
      type: QuestionType.doc_chon_hinh,
      description: 'Đọc chọn ABCDEF',
      section: 'reading',
    ),
  ];

  // ============================================
  // HSK 2 STRUCTURE
  // ============================================
  static const List<StructureItem> _hsk2Structure = [
    // === LISTENING ===
    StructureItem(
      range: '1-10',
      type: QuestionType.nghe_dung_sai,
      description: 'Nghe câu chọn hình đúng/sai',
      section: 'listening',
    ),
    StructureItem(
      range: '11-15',
      type: QuestionType.nghe_ngan_hinh,
      description: 'Nghe chọn hình ABCDEF',
      section: 'listening',
    ),
    StructureItem(
      range: '16-20',
      type: QuestionType.nghe_dai_hinh,
      description: 'Nghe chọn hình ABCDE',
      section: 'listening',
    ),
    StructureItem(
      range: '21-35',
      type: QuestionType.nghe_ABC,
      description: 'Nghe hội thoại chọn ABC',
      section: 'listening',
    ),
    // === READING ===
    StructureItem(
      range: '36-40',
      type: QuestionType.doc_chon_hinh,
      description: 'Đọc chữ chọn hình ABCDEF',
      section: 'reading',
    ),
    StructureItem(
      range: '41-45',
      type: QuestionType.doc_dien_tu_cau_don,
      description: 'Chọn 1/6 từ điền vào chỗ trống',
      section: 'reading',
    ),
    StructureItem(
      range: '46-50',
      type: QuestionType.doc_dung_sai,
      description: 'Đọc câu chọn đúng sai',
      section: 'reading',
    ),
    StructureItem(
      range: '51-60',
      type: QuestionType.doc_ghep_cau,
      description: 'Ghép 2 câu phù hợp với nhau',
      section: 'reading',
    ),
  ];

  // ============================================
  // HSK 3 STRUCTURE
  // ============================================
  static const List<StructureItem> _hsk3Structure = [
    // === LISTENING ===
    StructureItem(
      range: '1-5',
      type: QuestionType.nghe_ngan_hinh,
      description: 'Nghe chọn hình ABCDEF',
      section: 'listening',
    ),
    StructureItem(
      range: '6-10',
      type: QuestionType.nghe_dai_hinh,
      description: 'Nghe chọn hình ABCDE',
      section: 'listening',
    ),
    StructureItem(
      range: '11-20',
      type: QuestionType.nghe_dung_sai,
      description: 'Nghe hội thoại tick đúng/sai',
      section: 'listening',
    ),
    StructureItem(
      range: '21-40',
      type: QuestionType.nghe_ABC,
      description: 'Nghe hội thoại chọn ABC',
      section: 'listening',
    ),
    // === READING ===
    StructureItem(
      range: '41-50',
      type: QuestionType.doc_ghep_cau,
      description: 'Ghép 2 câu phù hợp với nhau',
      section: 'reading',
    ),
    StructureItem(
      range: '51-55',
      type: QuestionType.doc_dien_tu_cau_don,
      description: 'Chọn 1/6 từ điền vào câu đơn',
      section: 'reading',
    ),
    StructureItem(
      range: '56-60',
      type: QuestionType.doc_dien_tu_hoi_thoai,
      description: 'Chọn 1/6 từ điền vào hội thoại',
      section: 'reading',
    ),
    StructureItem(
      range: '61-70',
      type: QuestionType.doc_chon_3,
      description: 'Chọn 1/3 đúng với câu',
      section: 'reading',
    ),
    // === WRITING ===
    StructureItem(
      range: '71-75',
      type: QuestionType.viet_sap_xep_tu,
      description: 'Sắp xếp từ thành đoạn văn',
      section: 'writing',
    ),
    StructureItem(
      range: '76-80',
      type: QuestionType.viet_pinyin,
      description: 'Điền từ theo phiên âm',
      section: 'writing',
    ),
  ];

  // ============================================
  // HSK 4 STRUCTURE
  // ============================================
  static const List<StructureItem> _hsk4Structure = [
    // === LISTENING ===
    StructureItem(
      range: '1-10',
      type: QuestionType.nghe_dung_sai,
      description: 'Nghe hội thoại tick đúng/sai',
      section: 'listening',
    ),
    StructureItem(
      range: '11-25',
      type: QuestionType.nghe_chon_ngan,
      description: 'Nghe hội thoại ngắn chọn ABCD',
      section: 'listening',
    ),
    StructureItem(
      range: '26-45',
      type: QuestionType.nghe_chon_dai,
      description: 'Nghe hội thoại dài chọn ABCD',
      section: 'listening',
    ),
    // === READING ===
    StructureItem(
      range: '46-50',
      type: QuestionType.doc_dien_tu_cau_don,
      description: 'Điền từ vào câu đơn',
      section: 'reading',
    ),
    StructureItem(
      range: '51-55',
      type: QuestionType.doc_dien_tu_hoi_thoai,
      description: 'Điền từ vào hội thoại',
      section: 'reading',
    ),
    StructureItem(
      range: '56-65',
      type: QuestionType.doc_sap_xep,
      description: 'Sắp xếp 3 câu ABC',
      section: 'reading',
    ),
    StructureItem(
      range: '66-79',
      type: QuestionType.doc_chon_1_cau,
      description: 'Đọc đoạn văn chọn 1 đáp án',
      section: 'reading',
    ),
    StructureItem(
      range: '80-85',
      type: QuestionType.doc_chon_2_cau,
      description: 'Đọc đoạn văn chọn 2 đáp án',
      section: 'reading',
    ),
    // === WRITING ===
    StructureItem(
      range: '86-95',
      type: QuestionType.viet_sap_xep_tu,
      description: 'Sắp xếp từ thành đoạn',
      section: 'writing',
    ),
    StructureItem(
      range: '96-100',
      type: QuestionType.viet_nhin_tranh,
      description: 'Nhìn hình và từ gợi ý viết đoạn văn',
      section: 'writing',
    ),
  ];

  // ============================================
  // HSK 5 STRUCTURE
  // ============================================
  static const List<StructureItem> _hsk5Structure = [
    // === LISTENING ===
    StructureItem(
      range: '1-20',
      type: QuestionType.nghe_chon_ngan,
      description: 'Nghe đoạn ngắn chọn đáp án',
      section: 'listening',
    ),
    StructureItem(
      range: '21-45',
      type: QuestionType.nghe_chon_dai,
      description: 'Nghe đoạn dài chọn đáp án',
      section: 'listening',
    ),
    // === READING ===
    StructureItem(
      range: '46-60',
      type: QuestionType.doc_dien_nhieu_tu,
      description: 'Điền nhiều từ vào đoạn chung',
      section: 'reading',
    ),
    StructureItem(
      range: '61-70',
      type: QuestionType.doc_chon_1_cau,
      description: 'Đọc đoạn văn chọn 1 đáp án',
      section: 'reading',
    ),
    StructureItem(
      range: '71-90',
      type: QuestionType.doc_chon_lon_nho,
      description: 'Đoạn văn dài có nhiều câu hỏi nhỏ',
      section: 'reading',
    ),
    // === WRITING ===
    StructureItem(
      range: '91-98',
      type: QuestionType.viet_sap_xep_tu,
      description: 'Sắp xếp từ thành đoạn',
      section: 'writing',
    ),
    StructureItem(
      range: '99',
      type: QuestionType.viet_doan_van_theo_tu,
      description: 'Viết đoạn văn 80 từ theo từ gợi ý',
      section: 'writing',
    ),
    StructureItem(
      range: '100',
      type: QuestionType.viet_doan_van_theo_hinh,
      description: 'Viết đoạn văn 80 từ theo hình',
      section: 'writing',
    ),
  ];

  // ============================================
  // HSK 6 STRUCTURE
  // ============================================
  static const List<StructureItem> _hsk6Structure = [
    // === LISTENING ===
    StructureItem(
      range: '1-50',
      type: QuestionType.nghe_chon_doan_dai,
      description: 'Nghe đoạn dài chọn đáp án',
      section: 'listening',
    ),
    // === READING ===
    StructureItem(
      range: '51-60',
      type: QuestionType.doc_cau_chon_cau,
      description: 'Chọn câu sai trong ABCD',
      section: 'reading',
    ),
    StructureItem(
      range: '61-70',
      type: QuestionType.doc_dien_nhieu_tu,
      description: 'Chọn ABCD điền nhiều vị trí',
      section: 'reading',
    ),
    StructureItem(
      range: '71-80',
      type: QuestionType.doc_dien_5_tu,
      description: 'Chọn ABCDE vào 5 vị trí',
      section: 'reading',
    ),
    StructureItem(
      range: '81-100',
      type: QuestionType.doc_chon_lon_nho,
      description: 'Đọc đoạn dài chọn đáp án cho câu nhỏ',
      section: 'reading',
    ),
    // === WRITING ===
    StructureItem(
      range: '101',
      type: QuestionType.doc_nho_viet,
      description: 'Đọc văn bản, nhớ và viết lại luận',
      section: 'writing',
    ),
  ];
}
