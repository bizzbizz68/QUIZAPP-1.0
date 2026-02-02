import '../data/models/hsk_template.dart';
import '../data/models/question_model.dart';

/// HSK Template Generator - Tạo cấu trúc đề thi cố định cho HSK 1-9
class HskTemplateGenerator {
  /// Generate template for specific HSK level
  static HskExamTemplate generateTemplate(int level) {
    switch (level) {
      case 1:
        return _generateHSK1Template();
      case 2:
        return _generateHSK2Template();
      case 3:
        return _generateHSK3Template();
      case 4:
        return _generateHSK4Template();
      case 5:
        return _generateHSK5Template();
      case 6:
        return _generateHSK6Template();
      case 7:
        return _generateHSK7Template();
      case 8:
        return _generateHSK8Template();
      case 9:
        return _generateHSK9Template();
      default:
        throw Exception('HSK level $level not supported');
    }
  }

  // ============================================
  // HSK 1 - 35 câu
  // ============================================
  static HskExamTemplate _generateHSK1Template() {
    return HskExamTemplate(
      level: 1,
      title: 'HSK 1 - Đề Thi Chính Thức',
      totalQuestions: 35,
      duration: 60,
      passingScore: 60,
      sections: [
        HskSectionTemplate(
          name: 'Nghe',
          questionCount: 20,
          groups: [
            QuestionGroupTemplate(
              range: '1-5',
              type: QuestionType.nghe_dung_sai,
              description: 'Nghe và chọn Đúng/Sai',
              requiresAudio: true,
              requiresImage: false,
              optionsCount: 2,
              optionsLabels: ['Đúng', 'Sai'],
            ),
            QuestionGroupTemplate(
              range: '6-10',
              type: QuestionType.nghe_tranh_ABC,
              description: 'Nghe và chọn hình phù hợp',
              requiresAudio: true,
              requiresImage: true,
              imageCount: 3,
              optionsCount: 3,
              optionsLabels: ['A', 'B', 'C'],
            ),
            QuestionGroupTemplate(
              range: '11-15',
              type: QuestionType.nghe_ABC,
              description: 'Nghe hỏi đáp và chọn câu trả lời đúng',
              requiresAudio: true,
              requiresImage: false,
              optionsCount: 3,
              optionsLabels: ['A', 'B', 'C'],
            ),
            QuestionGroupTemplate(
              range: '16-20',
              type: QuestionType.nghe_chon_ngan,
              description: 'Nghe đoạn hội thoại và trả lời câu hỏi',
              requiresAudio: true,
              requiresImage: false,
              optionsCount: 3,
              optionsLabels: ['A', 'B', 'C'],
            ),
          ],
        ),
        HskSectionTemplate(
          name: 'Đọc',
          questionCount: 15,
          groups: [
            QuestionGroupTemplate(
              range: '21-25',
              type: QuestionType.doc_dung_sai,
              description: 'Đọc và chọn Đúng/Sai',
              requiresAudio: false,
              requiresImage: false,
              optionsCount: 2,
              optionsLabels: ['Đúng', 'Sai'],
            ),
            QuestionGroupTemplate(
              range: '26-35',
              type: QuestionType.doc_chon_hinh,
              description: 'Đọc và chọn hình phù hợp',
              requiresAudio: false,
              requiresImage: true,
              imageCount: 6,
              optionsCount: 6,
              optionsLabels: ['A', 'B', 'C', 'D', 'E', 'F'],
            ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // HSK 2 - 60 câu
  // ============================================
  static HskExamTemplate _generateHSK2Template() {
    return HskExamTemplate(
      level: 2,
      title: 'HSK 2 - Đề Thi Chính Thức',
      totalQuestions: 60,
      duration: 70,
      passingScore: 60,
      sections: [
        HskSectionTemplate(
          name: 'Nghe',
          questionCount: 35,
          groups: [
            QuestionGroupTemplate(
              range: '1-10',
              type: QuestionType.nghe_dung_sai,
              description: 'Nghe và chọn Đúng/Sai',
              requiresAudio: true,
              requiresImage: false,
              optionsCount: 2,
              optionsLabels: ['Đúng', 'Sai'],
            ),
            QuestionGroupTemplate(
              range: '11-15',
              type: QuestionType.nghe_tranh_ABC,
              description: 'Nghe và chọn hình',
              requiresAudio: true,
              requiresImage: true,
              imageCount: 3,
              optionsCount: 3,
              optionsLabels: ['A', 'B', 'C'],
            ),
            QuestionGroupTemplate(
              range: '16-20',
              type: QuestionType.nghe_ABC,
              description: 'Nghe hỏi đáp',
              requiresAudio: true,
              requiresImage: false,
              optionsCount: 3,
              optionsLabels: ['A', 'B', 'C'],
            ),
            QuestionGroupTemplate(
              range: '21-35',
              type: QuestionType.nghe_chon_ngan,
              description: 'Nghe đoạn hội thoại',
              requiresAudio: true,
              requiresImage: false,
              optionsCount: 3,
              optionsLabels: ['A', 'B', 'C'],
            ),
          ],
        ),
        HskSectionTemplate(
          name: 'Đọc',
          questionCount: 25,
          groups: [
            QuestionGroupTemplate(
              range: '36-40',
              type: QuestionType.doc_dung_sai,
              description: 'Đọc và chọn Đúng/Sai',
              requiresAudio: false,
              requiresImage: false,
              optionsCount: 2,
              optionsLabels: ['Đúng', 'Sai'],
            ),
            QuestionGroupTemplate(
              range: '41-45',
              type: QuestionType.doc_ghep_cau,
              description: 'Nối câu',
              requiresAudio: false,
              requiresImage: false,
              optionsCount: 5,
              optionsLabels: ['A', 'B', 'C', 'D', 'E'],
            ),
            QuestionGroupTemplate(
              range: '46-60',
              type: QuestionType.doc_dien_tu_cau_don,
              description: 'Chọn từ thích hợp điền vào chỗ trống',
              requiresAudio: false,
              requiresImage: false,
              optionsCount: 3,
              optionsLabels: ['A', 'B', 'C'],
            ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // HSK 3 - 80 câu (Placeholder)
  // ============================================
  static HskExamTemplate _generateHSK3Template() {
    return HskExamTemplate(
      level: 3,
      title: 'HSK 3 - Đề Thi Chính Thức',
      totalQuestions: 80,
      duration: 90,
      passingScore: 60,
      sections: [
        HskSectionTemplate(
          name: 'Nghe',
          questionCount: 40,
          groups: [
            QuestionGroupTemplate(
              range: '1-10',
              type: QuestionType.nghe_tranh_ABC,
              description: 'Nghe và chọn hình',
              requiresAudio: true,
              requiresImage: true,
              imageCount: 3,
              optionsCount: 3,
              optionsLabels: ['A', 'B', 'C'],
            ),
            QuestionGroupTemplate(
              range: '11-20',
              type: QuestionType.nghe_dung_sai,
              description: 'Nghe và chọn Đúng/Sai',
              requiresAudio: true,
              requiresImage: false,
              optionsCount: 2,
              optionsLabels: ['Đúng', 'Sai'],
            ),
            QuestionGroupTemplate(
              range: '21-40',
              type: QuestionType.nghe_chon_ngan,
              description: 'Nghe đoạn hội thoại và trả lời',
              requiresAudio: true,
              requiresImage: false,
              optionsCount: 3,
              optionsLabels: ['A', 'B', 'C'],
            ),
          ],
        ),
        HskSectionTemplate(
          name: 'Đọc',
          questionCount: 30,
          groups: [
            QuestionGroupTemplate(
              range: '41-50',
              type: QuestionType.doc_ghep_cau,
              description: 'Nối câu',
              requiresAudio: false,
              requiresImage: false,
              optionsCount: 5,
              optionsLabels: ['A', 'B', 'C', 'D', 'E'],
            ),
            QuestionGroupTemplate(
              range: '51-80',
              type: QuestionType.doc_dien_tu_cau_don,
              description: 'Chọn từ điền vào chỗ trống',
              requiresAudio: false,
              requiresImage: false,
              optionsCount: 3,
              optionsLabels: ['A', 'B', 'C'],
            ),
          ],
        ),
        HskSectionTemplate(
          name: 'Viết',
          questionCount: 10,
          groups: [
            QuestionGroupTemplate(
              range: '81-85',
              type: QuestionType.viet_sap_xep_tu,
              description: 'Sắp xếp từ thành câu',
              requiresAudio: false,
              requiresImage: false,
              optionsCount: 0,
            ),
            QuestionGroupTemplate(
              range: '86-90',
              type: QuestionType.viet_sap_xep_tu,
              description: 'Viết câu theo mẫu',
              requiresAudio: false,
              requiresImage: false,
              optionsCount: 0,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // HSK 4-6 (Simplified placeholders - cần update theo file txt)
  // ============================================
  static HskExamTemplate _generateHSK4Template() {
    return HskExamTemplate(
      level: 4,
      title: 'HSK 4 - Đề Thi Chính Thức',
      totalQuestions: 100,
      duration: 105,
      passingScore: 60,
      sections: [
        HskSectionTemplate(name: 'Nghe', questionCount: 45, groups: []),
        HskSectionTemplate(name: 'Đọc', questionCount: 40, groups: []),
        HskSectionTemplate(name: 'Viết', questionCount: 15, groups: []),
      ],
    );
  }

  static HskExamTemplate _generateHSK5Template() {
    return HskExamTemplate(
      level: 5,
      title: 'HSK 5 - Đề Thi Chính Thức',
      totalQuestions: 100,
      duration: 125,
      passingScore: 60,
      sections: [
        HskSectionTemplate(name: 'Nghe', questionCount: 45, groups: []),
        HskSectionTemplate(name: 'Đọc', questionCount: 45, groups: []),
        HskSectionTemplate(name: 'Viết', questionCount: 10, groups: []),
      ],
    );
  }

  static HskExamTemplate _generateHSK6Template() {
    return HskExamTemplate(
      level: 6,
      title: 'HSK 6 - Đề Thi Chính Thức',
      totalQuestions: 101,
      duration: 140,
      passingScore: 60,
      sections: [
        HskSectionTemplate(name: 'Nghe', questionCount: 50, groups: []),
        HskSectionTemplate(name: 'Đọc', questionCount: 50, groups: []),
        HskSectionTemplate(name: 'Viết', questionCount: 1, groups: []),
      ],
    );
  }

  // HSK 7-9: TBD
  static HskExamTemplate _generateHSK7Template() {
    return HskExamTemplate(
      level: 7,
      title: 'HSK 7 - Đề Thi Chính Thức (Chưa có dữ liệu)',
      totalQuestions: 0,
      duration: 120,
      passingScore: 60,
      sections: [],
    );
  }

  static HskExamTemplate _generateHSK8Template() {
    return HskExamTemplate(
      level: 8,
      title: 'HSK 8 - Đề Thi Chính Thức (Chưa có dữ liệu)',
      totalQuestions: 0,
      duration: 120,
      passingScore: 60,
      sections: [],
    );
  }

  static HskExamTemplate _generateHSK9Template() {
    return HskExamTemplate(
      level: 9,
      title: 'HSK 9 - Đề Thi Chính Thức (Chưa có dữ liệu)',
      totalQuestions: 0,
      duration: 120,
      passingScore: 60,
      sections: [],
    );
  }
}
