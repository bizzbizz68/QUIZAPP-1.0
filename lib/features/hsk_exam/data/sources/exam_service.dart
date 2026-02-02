import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/constants.dart';
import '../models/exam_model.dart';
import '../models/question_model.dart';

/// Exam Service
/// Xử lý tất cả operations liên quan đến exams và questions
class ExamService {
  static final ExamService _instance = ExamService._internal();
  factory ExamService() => _instance;
  ExamService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================
  // SEED INITIAL DATA
  // ============================================

  /// Seed initial HSK exam data into Firestore
  /// Tạo collection 'exams' và sub-collection 'questions'
  Future<void> seedInitialData({String createdBy = 'system'}) async {
    try {
      print('🌱 Starting to seed initial HSK exam data...');

      // Check if data already exists
      final existingExams = await _firestore
          .collection(AppConstants.examsCollection)
          .limit(1)
          .get();

      if (existingExams.docs.isNotEmpty) {
        print('⚠️ Data already exists. Skipping seed.');
        return;
      }

      // Seed exams for each HSK level
      for (int level in AppConstants.hskLevels) {
        await _seedExamForLevel(level, createdBy);
      }

      print('✅ Successfully seeded ${AppConstants.hskLevels.length} HSK exams with questions!');
    } catch (e) {
      print('❌ Error seeding data: $e');
      throw Exception('Không thể seed initial data: $e');
    }
  }

  /// Seed một exam cho một HSK level cụ thể
  Future<void> _seedExamForLevel(int level, String createdBy) async {
    // Get total questions for this level
    final totalQuestions = _getTotalQuestionsForLevel(level);
    
    // Tạo exam document
    final examData = {
      'title': 'HSK $level - Đề Thi Thử',
      'level': level,
      'duration': _getDurationForLevel(level),
      'description': _getDescriptionForLevel(level),
      'totalQuestions': totalQuestions,
      'passingScore': AppConstants.passingScore,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    };

    // Thêm exam vào Firestore
    final examRef = await _firestore
        .collection(AppConstants.examsCollection)
        .add(examData);

    print('📝 Created exam: HSK $level (${examRef.id}) - $totalQuestions câu');

    // Tạo questions cho exam này
    await _seedQuestionsForExam(examRef.id, level);
  }

  /// Seed questions cho một exam
  Future<void> _seedQuestionsForExam(String examId, int level) async {
    final questionsCollection = _firestore
        .collection(AppConstants.examsCollection)
        .doc(examId)
        .collection(AppConstants.questionsSubCollection);

    // Get total questions for this level
    final totalQuestions = _getTotalQuestionsForLevel(level);

    // Batch write để tăng performance
    final batch = _firestore.batch();

    for (int i = 1; i <= totalQuestions; i++) {
      final questionRef = questionsCollection.doc();
      final questionData = _generateQuestionData(i, level, examId);
      batch.set(questionRef, questionData);
    }

    await batch.commit();
    print('  ✅ Added $totalQuestions questions to HSK $level');
  }

  /// Get total questions for each HSK level
  int _getTotalQuestionsForLevel(int level) {
    switch (level) {
      case 1:
        return 35;
      case 2:
        return 60;
      case 3:
        return 80;
      case 4:
      case 5:
        return 100;
      case 6:
        return 101;
      default:
        return 20;
    }
  }

  /// Generate question data dựa trên orderIndex và level
  /// Theo đúng format trong file "Các dạng bài làm trong HSK 1-6.txt"
  Map<String, dynamic> _generateQuestionData(
      int orderIndex, int level, String examId) {
    // Determine question type based on level and orderIndex
    final typeInfo = _getQuestionTypeForIndex(orderIndex, level);
    final questionType = typeInfo['type'] as String;
    final section = typeInfo['section'] as String;

    // Generate sample content based on type
    final sampleData = _generateSampleContent(questionType, orderIndex, level);

    return {
      'examId': examId,
      'hskLevel': level,
      'section': section,
      'type': questionType,
      'orderIndex': orderIndex,
      'content': sampleData['content'],
      'options': sampleData['options'],
      'correctAnswer': sampleData['correctAnswer'],
      'explanation': sampleData['explanation'],
      'createdBy': 'system',
      'updatedBy': 'system',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Xác định QuestionType dựa trên orderIndex và level
  Map<String, String> _getQuestionTypeForIndex(int orderIndex, int level) {
    switch (level) {
      case 1:
        return _getHSK1Type(orderIndex);
      case 2:
        return _getHSK2Type(orderIndex);
      case 3:
        return _getHSK3Type(orderIndex);
      case 4:
        return _getHSK4Type(orderIndex);
      case 5:
        return _getHSK5Type(orderIndex);
      case 6:
        return _getHSK6Type(orderIndex);
      default:
        return {'type': 'doc_chon_1_cau', 'section': 'doc'};
    }
  }

  /// HSK 1 - 35 câu
  Map<String, String> _getHSK1Type(int index) {
    if (index >= 1 && index <= 5) {
      return {'type': 'nghe_dung_sai', 'section': 'nghe'};
    } else if (index >= 6 && index <= 10) {
      return {'type': 'nghe_tranh_ABC', 'section': 'nghe'};
    } else if (index >= 11 && index <= 15) {
      return {'type': 'nghe_ngan_hinh', 'section': 'nghe'};
    } else if (index >= 16 && index <= 20) {
      return {'type': 'nghe_ABC', 'section': 'nghe'};
    } else if (index >= 21 && index <= 25) {
      return {'type': 'doc_dung_sai', 'section': 'doc'};
    } else if (index >= 26 && index <= 30) {
      return {'type': 'doc_chon_hinh', 'section': 'doc'};
    } else if (index >= 31 && index <= 35) {
      return {'type': 'doc_chon_hinh', 'section': 'doc'}; // doc chon ABCDEF
    }
    return {'type': 'doc_chon_1_cau', 'section': 'doc'};
  }

  /// HSK 2 - 60 câu
  Map<String, String> _getHSK2Type(int index) {
    if (index >= 1 && index <= 10) {
      return {'type': 'nghe_dung_sai', 'section': 'nghe'};
    } else if (index >= 11 && index <= 15) {
      return {'type': 'nghe_ngan_hinh', 'section': 'nghe'};
    } else if (index >= 16 && index <= 20) {
      return {'type': 'nghe_dai_hinh', 'section': 'nghe'};
    } else if (index >= 21 && index <= 35) {
      return {'type': 'nghe_ABC', 'section': 'nghe'};
    } else if (index >= 36 && index <= 40) {
      return {'type': 'doc_chon_hinh', 'section': 'doc'};
    } else if (index >= 41 && index <= 45) {
      return {'type': 'doc_dien_tu_cau_don', 'section': 'doc'};
    } else if (index >= 46 && index <= 50) {
      return {'type': 'doc_dung_sai', 'section': 'doc'};
    } else if (index >= 51 && index <= 60) {
      return {'type': 'doc_ghep_cau', 'section': 'doc'};
    }
    return {'type': 'doc_chon_1_cau', 'section': 'doc'};
  }

  /// HSK 3 - 80 câu
  Map<String, String> _getHSK3Type(int index) {
    if (index >= 1 && index <= 5) {
      return {'type': 'nghe_ngan_hinh', 'section': 'nghe'};
    } else if (index >= 6 && index <= 10) {
      return {'type': 'nghe_dai_hinh', 'section': 'nghe'};
    } else if (index >= 11 && index <= 20) {
      return {'type': 'nghe_dung_sai', 'section': 'nghe'};
    } else if (index >= 21 && index <= 40) {
      return {'type': 'nghe_ABC', 'section': 'nghe'};
    } else if (index >= 41 && index <= 50) {
      return {'type': 'doc_ghep_cau', 'section': 'doc'};
    } else if (index >= 51 && index <= 55) {
      return {'type': 'doc_dien_tu_cau_don', 'section': 'doc'};
    } else if (index >= 56 && index <= 60) {
      return {'type': 'doc_dien_tu_hoi_thoai', 'section': 'doc'};
    } else if (index >= 61 && index <= 70) {
      return {'type': 'doc_chon_3', 'section': 'doc'};
    } else if (index >= 71 && index <= 75) {
      return {'type': 'viet_sap_xep_tu', 'section': 'viet'};
    } else if (index >= 76 && index <= 80) {
      return {'type': 'viet_pinyin', 'section': 'viet'};
    }
    return {'type': 'doc_chon_1_cau', 'section': 'doc'};
  }

  /// HSK 4 - 100 câu
  Map<String, String> _getHSK4Type(int index) {
    if (index >= 1 && index <= 10) {
      return {'type': 'nghe_dung_sai', 'section': 'nghe'};
    } else if (index >= 11 && index <= 25) {
      return {'type': 'nghe_chon_ngan', 'section': 'nghe'};
    } else if (index >= 26 && index <= 45) {
      return {'type': 'nghe_chon_dai', 'section': 'nghe'};
    } else if (index >= 46 && index <= 50) {
      return {'type': 'doc_dien_tu_cau_don', 'section': 'doc'};
    } else if (index >= 51 && index <= 55) {
      return {'type': 'doc_dien_tu_hoi_thoai', 'section': 'doc'};
    } else if (index >= 56 && index <= 65) {
      return {'type': 'doc_sap_xep', 'section': 'doc'};
    } else if (index >= 66 && index <= 79) {
      return {'type': 'doc_chon_1_cau', 'section': 'doc'};
    } else if (index >= 80 && index <= 85) {
      return {'type': 'doc_chon_2_cau', 'section': 'doc'};
    } else if (index >= 86 && index <= 95) {
      return {'type': 'viet_sap_xep_tu', 'section': 'viet'};
    } else if (index >= 96 && index <= 100) {
      return {'type': 'viet_nhin_tranh', 'section': 'viet'};
    }
    return {'type': 'doc_chon_1_cau', 'section': 'doc'};
  }

  /// HSK 5 - 100 câu
  Map<String, String> _getHSK5Type(int index) {
    if (index >= 1 && index <= 20) {
      return {'type': 'nghe_chon_ngan', 'section': 'nghe'};
    } else if (index >= 21 && index <= 45) {
      return {'type': 'nghe_chon_dai', 'section': 'nghe'};
    } else if (index >= 46 && index <= 48) {
      return {'type': 'doc_dien_3_tu', 'section': 'doc'};
    } else if (index >= 49 && index <= 60) {
      return {'type': 'doc_dien_4_tu', 'section': 'doc'};
    } else if (index >= 61 && index <= 70) {
      return {'type': 'doc_chon_1_cau', 'section': 'doc'};
    } else if (index >= 71 && index <= 90) {
      return {'type': 'doc_chon_lon_nho', 'section': 'doc'};
    } else if (index >= 91 && index <= 98) {
      return {'type': 'viet_sap_xep_tu', 'section': 'viet'};
    } else if (index == 99) {
      return {'type': 'viet_doan_van_theo_tu', 'section': 'viet'};
    } else if (index == 100) {
      return {'type': 'viet_doan_van_theo_hinh', 'section': 'viet'};
    }
    return {'type': 'doc_chon_1_cau', 'section': 'doc'};
  }

  /// HSK 6 - 101 câu
  Map<String, String> _getHSK6Type(int index) {
    if (index >= 1 && index <= 50) {
      return {'type': 'nghe_chon_doan_dai', 'section': 'nghe'};
    } else if (index >= 51 && index <= 60) {
      return {'type': 'doc_cau_chon_cau', 'section': 'doc'};
    } else if (index >= 61 && index <= 70) {
      return {'type': 'doc_dien_nhieu_tu', 'section': 'doc'};
    } else if (index >= 71 && index <= 80) {
      return {'type': 'doc_dien_5_tu', 'section': 'doc'};
    } else if (index >= 81 && index <= 100) {
      return {'type': 'doc_chon_lon_nho', 'section': 'doc'};
    } else if (index == 101) {
      return {'type': 'doc_nho_viet', 'section': 'viet'};
    }
    return {'type': 'doc_chon_1_cau', 'section': 'doc'};
  }

  /// Get duration cho từng level (minutes)
  int _getDurationForLevel(int level) {
    switch (level) {
      case 1:
      case 2:
        return 60; // 1 hour
      case 3:
      case 4:
        return 90; // 1.5 hours
      case 5:
      case 6:
        return 120; // 2 hours
      default:
        return 60;
    }
  }

  /// Get description cho từng level
  String _getDescriptionForLevel(int level) {
    final descriptions = {
      1: 'HSK 1 - Kiểm tra khả năng hiểu và sử dụng 150 từ vựng cơ bản.',
      2: 'HSK 2 - Kiểm tra khả năng sử dụng 300 từ vựng trong giao tiếp hàng ngày.',
      3: 'HSK 3 - Yêu cầu nắm vững 600 từ vựng và có thể giao tiếp ở mức độ cơ bản.',
      4: 'HSK 4 - Đánh giá khả năng giao tiếp với 1200 từ vựng.',
      5: 'HSK 5 - Kiểm tra khả năng đọc báo, xem phim với 2500 từ vựng.',
      6: 'HSK 6 - Trình độ cao nhất, yêu cầu 5000 từ vựng.',
    };
    return descriptions[level] ?? 'Đề thi HSK Level $level';
  }

  /// Generate sample content based on question type
  Map<String, dynamic> _generateSampleContent(
      String questionType, int orderIndex, int level) {
    // Sample content templates for different question types
    final samples = {
      // === NGHE ===
      'nghe_dung_sai': {
        'content': {
          'text': 'Nghe đoạn hội thoại và chọn Đúng hoặc Sai.',
          'audioUrl': 'audio/hsk$level/listening_${orderIndex}.mp3',
        },
        'options': ['Đúng', 'Sai'],
        'correctAnswer': 'Đúng',
        'explanation':
            'Đây là dạng câu hỏi nghe và chọn đúng/sai về nội dung vừa nghe.',
      },
      'nghe_tranh_ABC': {
        'content': {
          'text': 'Nghe và chọn tranh đúng.',
          'audioUrl': 'audio/hsk$level/listening_${orderIndex}.mp3',
        },
        'options': ['A', 'B', 'C'],
        'correctAnswer': 'B',
        'explanation': 'Nghe và chọn tranh phù hợp với nội dung vừa nghe.',
      },
      'nghe_ngan_hinh': {
        'content': {
          'text': 'Nghe và chọn hình phù hợp.',
          'audioUrl': 'audio/hsk$level/listening_${orderIndex}.mp3',
        },
        'options': ['A', 'B', 'C', 'D', 'E', 'F'],
        'correctAnswer': 'C',
        'explanation': 'Nghe đoạn ngắn và chọn hình phù hợp.',
      },
      'nghe_dai_hinh': {
        'content': {
          'text': 'Nghe đoạn dài và chọn hình phù hợp.',
          'audioUrl': 'audio/hsk$level/listening_${orderIndex}.mp3',
        },
        'options': ['A', 'B', 'C', 'D', 'E'],
        'correctAnswer': 'A',
        'explanation': 'Nghe đoạn dài và chọn hình phù hợp nhất.',
      },
      'nghe_ABC': {
        'content': {
          'text': 'Nghe hội thoại và chọn đáp án đúng.',
          'audioUrl': 'audio/hsk$level/listening_${orderIndex}.mp3',
        },
        'options': ['A. Đáp án A', 'B. Đáp án B', 'C. Đáp án C'],
        'correctAnswer': 'B',
        'explanation': 'Nghe hội thoại và chọn đáp án phù hợp.',
      },
      'nghe_chon_ngan': {
        'content': {
          'text': 'Nghe đoạn ngắn và chọn đáp án đúng.',
          'audioUrl': 'audio/hsk$level/listening_${orderIndex}.mp3',
        },
        'options': ['A. Đáp án A', 'B. Đáp án B', 'C. Đáp án C', 'D. Đáp án D'],
        'correctAnswer': 'C',
        'explanation': 'Nghe đoạn ngắn và chọn 1/4 đáp án đúng.',
      },
      'nghe_chon_dai': {
        'content': {
          'text': 'Nghe đoạn dài và chọn đáp án đúng.',
          'audioUrl': 'audio/hsk$level/listening_${orderIndex}.mp3',
        },
        'options': ['A. Đáp án A', 'B. Đáp án B', 'C. Đáp án C', 'D. Đáp án D'],
        'correctAnswer': 'A',
        'explanation': 'Nghe đoạn dài và chọn 1/4 đáp án đúng.',
      },
      'nghe_chon_doan_dai': {
        'content': {
          'text': 'Nghe đoạn dài và trả lời câu hỏi.',
          'audioUrl': 'audio/hsk$level/listening_${orderIndex}.mp3',
        },
        'options': ['A. Đáp án A', 'B. Đáp án B', 'C. Đáp án C', 'D. Đáp án D'],
        'correctAnswer': 'D',
        'explanation': 'Nghe đoạn dài (HSK6) và chọn đáp án.',
      },

      // === ĐỌC ===
      'doc_dung_sai': {
        'content': {
          'text': '我喜欢学习汉语。(Tôi thích học tiếng Trung)',
        },
        'options': ['Đúng', 'Sai'],
        'correctAnswer': 'Đúng',
        'explanation': 'Đọc câu và chọn đúng/sai.',
      },
      'doc_chon_hinh': {
        'content': {
          'text': '请选择正确的图片。',
        },
        'options': ['A', 'B', 'C', 'D', 'E', 'F'],
        'correctAnswer': 'B',
        'explanation': 'Đọc chữ và chọn hình phù hợp.',
      },
      'doc_dien_tu_cau_don': {
        'content': {
          'text': '我___学习汉语。 (Tôi ___ học tiếng Trung)',
        },
        'options': ['在', '是', '有', '去', '来', '会'],
        'correctAnswer': '在',
        'explanation': 'Chọn 1/6 từ để điền vào chỗ trống.',
      },
      'doc_ghep_cau': {
        'content': {
          'text': 'Ghép 2 câu phù hợp: A. 你好吗？',
        },
        'options': [
          'B. 我很好，谢谢',
          'C. 我不喜欢',
          'D. 今天很热',
          'E. 我要去学校'
        ],
        'correctAnswer': 'B',
        'explanation': 'Ghép 2 câu hợp lý với nhau.',
      },
      'doc_dien_tu_hoi_thoai': {
        'content': {
          'text': 'A: 你今天___？\nB: 我今天很忙。',
        },
        'options': ['怎么样', '在哪里', '什么时候', '为什么', '多少', '谁'],
        'correctAnswer': '怎么样',
        'explanation': 'Chọn từ điền vào hội thoại 2 dòng.',
      },
      'doc_chon_3': {
        'content': {
          'text': '他很喜欢学习汉语。这句话的意思是什么？',
        },
        'options': [
          'A. Anh ấy không thích học tiếng Trung',
          'B. Anh ấy rất thích học tiếng Trung',
          'C. Anh ấy đang học tiếng Trung'
        ],
        'correctAnswer': 'B',
        'explanation': 'Chọn 1/3 đáp án đúng với câu.',
      },
      'doc_sap_xep': {
        'content': {
          'text': 'Sắp xếp 3 câu hội thoại theo thứ tự đúng.',
        },
        'options': ['A. Câu 1', 'B. Câu 2', 'C. Câu 3'],
        'correctAnswer': 'ABC',
        'explanation': 'Sắp xếp câu theo thứ tự hợp lý.',
      },
      'doc_chon_1_cau': {
        'content': {
          'text':
              '我很喜欢学习汉语，因为汉语很有趣。每天我都会学习一个小时。\n\n问：他为什么喜欢学习汉语？',
        },
        'options': [
          'A. 因为汉语很难',
          'B. 因为汉语很有趣',
          'C. 因为老师很好',
          'D. 因为朋友喜欢'
        ],
        'correctAnswer': 'B',
        'explanation': 'Đọc đoạn văn và chọn 1/4 đáp án.',
      },
      'doc_chon_2_cau': {
        'content': {
          'text': '(Đoạn văn dài về một chủ đề)\n\n问题 1: ...?\n问题 2: ...?',
        },
        'options': [
          'A. Đáp án A1',
          'B. Đáp án B1',
          'C. Đáp án C1',
          'D. Đáp án D1',
          'E. Đáp án A2',
          'F. Đáp án B2',
          'G. Đáp án C2',
          'H. Đáp án D2'
        ],
        'correctAnswer': 'B,F',
        'explanation': 'Đọc đoạn văn và chọn 2 đáp án cho 2 câu hỏi.',
      },
      'doc_dien_3_tu': {
        'content': {
          'text': '(Đoạn văn có 3 chỗ trống) _1_ ... _2_ ... _3_ ...',
        },
        'options': ['A. Từ 1', 'B. Từ 2', 'C. Từ 3'],
        'correctAnswer': 'A,B,C',
        'explanation': 'Điền 3 từ vào đúng vị trí trong đoạn.',
      },
      'doc_dien_4_tu': {
        'content': {
          'text': '(Đoạn văn có 4 chỗ trống) _1_ ... _2_ ... _3_ ... _4_ ...',
        },
        'options': ['A. Từ 1', 'B. Từ 2', 'C. Từ 3', 'D. Từ 4'],
        'correctAnswer': 'A,B,C,D',
        'explanation': 'Điền 4 từ vào đúng vị trí trong đoạn.',
      },
      'doc_chon_lon_nho': {
        'content': {
          'text':
              '(Một đoạn văn dài)\n\n问题 ${orderIndex % 4 + 1}: ...?',
          'imageUrl': 'images/hsk$level/passage_${orderIndex ~/ 4}.jpg',
        },
        'options': ['A. Đáp án A', 'B. Đáp án B', 'C. Đáp án C', 'D. Đáp án D'],
        'correctAnswer': 'B',
        'explanation': 'Đọc 1 đoạn dài cho nhiều câu hỏi nhỏ.',
      },
      'doc_cau_chon_cau': {
        'content': {
          'text': 'A. Câu A\nB. Câu B\nC. Câu C\nD. Câu D\n\n哪个句子是错的？',
        },
        'options': ['A', 'B', 'C', 'D'],
        'correctAnswer': 'C',
        'explanation': 'Đọc ABCD và chọn câu sai.',
      },
      'doc_dien_nhieu_tu': {
        'content': {
          'text': '(Đoạn văn có nhiều chỗ trống) ___ ... ___ ... ___ ...',
        },
        'options': ['A. Từ 1', 'B. Từ 2', 'C. Từ 3', 'D. Từ 4'],
        'correctAnswer': 'A,B,C',
        'explanation': 'Chọn ABCD điền nhiều vị trí.',
      },
      'doc_dien_5_tu': {
        'content': {
          'text':
              '(Đoạn văn có 5 chỗ trống) _1_ ... _2_ ... _3_ ... _4_ ... _5_ ...',
        },
        'options': ['A. Từ 1', 'B. Từ 2', 'C. Từ 3', 'D. Từ 4', 'E. Từ 5'],
        'correctAnswer': 'A,B,C,D,E',
        'explanation': 'Chọn ABCDE vào 5 vị trí.',
      },

      // === VIẾT ===
      'viet_sap_xep_tu': {
        'content': {
          'text': 'Sắp xếp các từ sau thành câu hoàn chỉnh:\n学习 / 我 / 汉语 / 喜欢',
        },
        'options': [],
        'correctAnswer': '我喜欢学习汉语',
        'explanation': 'Sắp xếp từ thành câu đúng.',
      },
      'viet_pinyin': {
        'content': {
          'text': 'Điền từ tiếng Trung theo phiên âm:\nwǒ hěn xǐhuān xuéxí hànyǔ',
        },
        'options': [],
        'correctAnswer': '我很喜欢学习汉语',
        'explanation': 'Viết chữ Hán theo pinyin.',
      },
      'viet_nhin_tranh': {
        'content': {
          'text': 'Nhìn hình và từ gợi ý, viết đoạn văn 80 từ.',
          'imageUrl': 'images/hsk$level/writing_${orderIndex}.jpg',
        },
        'options': [],
        'correctAnswer': '(Học viên tự viết)',
        'explanation': 'Viết đoạn văn dựa vào hình và từ gợi ý.',
      },
      'viet_doan_van_theo_tu': {
        'content': {
          'text': 'Viết đoạn văn 80 từ với từ gợi ý: 学习、努力、进步',
        },
        'options': [],
        'correctAnswer': '(Học viên tự viết)',
        'explanation': 'Viết đoạn văn có sử dụng các từ gợi ý.',
      },
      'viet_doan_van_theo_hinh': {
        'content': {
          'text': 'Nhìn hình và viết đoạn văn 80 từ.',
          'imageUrl': 'images/hsk$level/writing_${orderIndex}.jpg',
        },
        'options': [],
        'correctAnswer': '(Học viên tự viết)',
        'explanation': 'Viết đoạn văn mô tả hình ảnh.',
      },
      'doc_nho_viet': {
        'content': {
          'text': 'Đọc đoạn văn, nhớ và viết lại bằng ngôn ngữ của bạn (1000 từ).',
        },
        'options': [],
        'correctAnswer': '(Học viên tự viết)',
        'explanation': 'Đọc nhớ và viết luận (HSK6).',
      },
    };

    // Return sample for this question type or default
    return samples[questionType] ??
        {
          'content': {
            'text': 'Sample question for $questionType',
          },
          'options': ['A', 'B', 'C', 'D'],
          'correctAnswer': 'A',
          'explanation': 'Sample explanation.',
        };
  }

  // ============================================
  // READ OPERATIONS
  // ============================================

  /// Get all active exams
  Future<List<ExamModel>> getAllExams() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.examsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('level')
          .get();

      return querySnapshot.docs
          .map((doc) => ExamModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting exams: $e');
      throw Exception('Không thể lấy danh sách đề thi: $e');
    }
  }

  /// Get exams by level
  Future<List<ExamModel>> getExamsByLevel(int level) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.examsCollection)
          .where('level', isEqualTo: level)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExamModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting exams by level: $e');
      throw Exception('Không thể lấy đề thi level $level: $e');
    }
  }

  /// Get exam by ID
  Future<ExamModel?> getExamById(String examId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .get();

      if (doc.exists) {
        return ExamModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting exam: $e');
      throw Exception('Không thể lấy đề thi: $e');
    }
  }

  /// Get all questions for an exam
  Future<List<QuestionModel>> getQuestionsByExamId(String examId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .collection(AppConstants.questionsSubCollection)
          .orderBy('orderIndex')
          .get();

      return querySnapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting questions: $e');
      throw Exception('Không thể lấy danh sách câu hỏi: $e');
    }
  }

  /// Stream để listen real-time exam changes
  Stream<List<ExamModel>> watchExams() {
    return _firestore
        .collection(AppConstants.examsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('level')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExamModel.fromFirestore(doc))
            .toList());
  }

  /// Stream để listen questions của một exam
  Stream<List<QuestionModel>> watchQuestions(String examId) {
    return _firestore
        .collection(AppConstants.examsCollection)
        .doc(examId)
        .collection(AppConstants.questionsSubCollection)
        .orderBy('orderIndex')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuestionModel.fromFirestore(doc))
            .toList());
  }

  /// Count exams by level
  Future<int> countExamsByLevel(int level) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.examsCollection)
          .where('level', isEqualTo: level)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('❌ Error counting exams: $e');
      return 0;
    }
  }
}
