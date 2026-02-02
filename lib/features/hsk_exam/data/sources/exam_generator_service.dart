import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exam_instance_model.dart';
import '../models/question_model.dart';
import 'hierarchical_question_bank_service.dart';

/// HSK Exam Structure Definition
class HskExamStructure {
  final int level;
  final String title;
  final int totalQuestions;
  final int durationMinutes;
  final List<QuestionGroupDef> groups;

  HskExamStructure({
    required this.level,
    required this.title,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.groups,
  });
}

class QuestionGroupDef {
  final String section; // nghe, doc, viet
  final QuestionType type;
  final int count;

  QuestionGroupDef({
    required this.section,
    required this.type,
    required this.count,
  });
}

/// Exam Generator Service - Tạo đề thi ngẫu nhiên từ Question Bank
class ExamGeneratorService {
  static final ExamGeneratorService _instance =
      ExamGeneratorService._internal();
  factory ExamGeneratorService() => _instance;
  ExamGeneratorService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _questionBankService = HierarchicalQuestionBankService();

  // ============================================
  // EXAM STRUCTURE DEFINITIONS
  // ============================================

  /// Get HSK exam structure by level
  HskExamStructure getExamStructure(int level) {
    switch (level) {
      case 1:
        return _getHSK1Structure();
      case 2:
        return _getHSK2Structure();
      case 3:
        return _getHSK3Structure();
      case 4:
        return _getHSK4Structure();
      case 5:
        return _getHSK5Structure();
      case 6:
        return _getHSK6Structure();
      default:
        throw Exception('HSK level $level not supported');
    }
  }

  HskExamStructure _getHSK1Structure() {
    return HskExamStructure(
      level: 1,
      title: 'HSK 1 - Bài Thi',
      totalQuestions: 35,
      durationMinutes: 60,
      groups: [
        // NGHE (20 câu)
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_dung_sai, count: 5),
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_tranh_ABC, count: 5),
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_ngan_hinh, count: 5),
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_ABC, count: 5),
        // DOC (15 câu)
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_dung_sai, count: 5),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_chon_hinh, count: 5),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_chon_3, count: 5),
      ],
    );
  }

  HskExamStructure _getHSK2Structure() {
    return HskExamStructure(
      level: 2,
      title: 'HSK 2 - Bài Thi',
      totalQuestions: 60,
      durationMinutes: 70,
      groups: [
        // NGHE (35 câu)
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_dung_sai, count: 10),
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_ngan_hinh, count: 5),
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_dai_hinh, count: 5),
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_ABC, count: 15),
        // DOC (25 câu)
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_chon_hinh, count: 5),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_dien_tu_cau_don, count: 5),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_dung_sai, count: 5),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_ghep_cau, count: 10),
      ],
    );
  }

  HskExamStructure _getHSK3Structure() {
    return HskExamStructure(
      level: 3,
      title: 'HSK 3 - Bài Thi',
      totalQuestions: 80,
      durationMinutes: 90,
      groups: [
        // NGHE (40 câu)
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_ngan_hinh, count: 5),
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_dai_hinh, count: 5),
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_dung_sai, count: 10),
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_ABC, count: 20),
        // DOC (30 câu)
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_ghep_cau, count: 10),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_dien_tu_cau_don, count: 5),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_dien_tu_hoi_thoai, count: 5),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_chon_3, count: 10),
        // VIET (10 câu)
        QuestionGroupDef(
            section: 'viet', type: QuestionType.viet_sap_xep_tu, count: 5),
        QuestionGroupDef(
            section: 'viet', type: QuestionType.viet_pinyin, count: 5),
      ],
    );
  }

  // HSK 4-6: Similar structure (simplified for now)
  HskExamStructure _getHSK4Structure() {
    return HskExamStructure(
      level: 4,
      title: 'HSK 4 - Bài Thi',
      totalQuestions: 100,
      durationMinutes: 105,
      groups: [
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_dung_sai, count: 10),
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_chon_ngan, count: 15),
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_chon_dai, count: 20),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_dien_tu_cau_don, count: 5),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_dien_tu_hoi_thoai, count: 5),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_sap_xep, count: 10),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_chon_1_cau, count: 14),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_chon_2_cau, count: 6),
        QuestionGroupDef(
            section: 'viet', type: QuestionType.viet_sap_xep_tu, count: 10),
        QuestionGroupDef(
            section: 'viet', type: QuestionType.viet_nhin_tranh, count: 5),
      ],
    );
  }

  HskExamStructure _getHSK5Structure() {
    return HskExamStructure(
      level: 5,
      title: 'HSK 5 - Bài Thi',
      totalQuestions: 100,
      durationMinutes: 125,
      groups: [
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_chon_ngan, count: 20),
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_chon_dai, count: 25),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_dien_3_tu, count: 3),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_dien_4_tu, count: 12),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_chon_1_cau, count: 10),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_chon_lon_nho, count: 20),
        QuestionGroupDef(
            section: 'viet', type: QuestionType.viet_sap_xep_tu, count: 8),
        QuestionGroupDef(
            section: 'viet', type: QuestionType.viet_doan_van_theo_tu, count: 1),
        QuestionGroupDef(
            section: 'viet',
            type: QuestionType.viet_doan_van_theo_hinh,
            count: 1),
      ],
    );
  }

  HskExamStructure _getHSK6Structure() {
    return HskExamStructure(
      level: 6,
      title: 'HSK 6 - Bài Thi',
      totalQuestions: 101,
      durationMinutes: 140,
      groups: [
        QuestionGroupDef(
            section: 'nghe', type: QuestionType.nghe_chon_doan_dai, count: 50),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_cau_chon_cau, count: 10),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_dien_nhieu_tu, count: 10),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_dien_5_tu, count: 10),
        QuestionGroupDef(
            section: 'doc', type: QuestionType.doc_chon_lon_nho, count: 20),
        QuestionGroupDef(
            section: 'viet', type: QuestionType.doc_nho_viet, count: 1),
      ],
    );
  }

  // ============================================
  // EXAM GENERATION
  // ============================================

  /// Generate exam instance for student
  Future<String> generateExamInstance({
    required String studentId,
    required int hskLevel,
  }) async {
    try {
      print('🎲 Generating exam for student: $studentId, HSK: $hskLevel');

      // 1. Get exam structure
      final structure = getExamStructure(hskLevel);

      // 2. Select random questions from bank
      final List<QuestionModel> selectedQuestions = [];
      final List<Map<String, dynamic>> questionDetails = [];
      int orderIndex = 1;

      for (final group in structure.groups) {
        print(
            '  Selecting ${group.count} questions: ${group.section} / ${group.type}');

        final questions = await _questionBankService.getRandomQuestions(
          hskLevel: hskLevel,
          section: group.section,
          questionType: group.type,
          count: group.count,
        );

        // Add to selected list
        selectedQuestions.addAll(questions);

        // Create question details snapshot
        for (final q in questions) {
          questionDetails.add({
            'questionId': q.id,
            'orderIndex': orderIndex++,
            'type': q.type.toString().split('.').last,
            'section': q.section,
            'content': q.content,
            'options': q.options,
            'correctAnswer': q.correctAnswer,
            'explanation': q.explanation,
          });

          // TODO: Implement increment usage count in hierarchical service
          // await _questionBankService.incrementUsageCount(q.id);
        }
      }

      // 3. Create exam instance
      final now = DateTime.now();
      final expiresAt =
          now.add(Duration(minutes: structure.durationMinutes));

      final examData = {
        'studentId': studentId,
        'hskLevel': hskLevel,
        'title':
            '${structure.title} - #${now.millisecondsSinceEpoch.toString().substring(8)}',
        'questionIds': selectedQuestions.map((q) => q.id).toList(),
        'questionDetails': questionDetails,
        'startedAt': FieldValue.serverTimestamp(),
        'submittedAt': null,
        'durationSeconds': structure.durationMinutes * 60,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'status': 'in_progress',
        'score': null,
        'totalQuestions': structure.totalQuestions,
        'correctAnswers': null,
        'wrongAnswers': null,
        'sectionScores': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef =
          await _firestore.collection('exam_instances').add(examData);

      print('✅ Exam instance created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error generating exam: $e');
      throw Exception('Không thể tạo đề thi: $e');
    }
  }

  /// Get exam instance by ID
  Future<ExamInstanceModel?> getExamInstance(String instanceId) async {
    try {
      final doc =
          await _firestore.collection('exam_instances').doc(instanceId).get();
      if (!doc.exists) return null;
      return ExamInstanceModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting exam instance: $e');
      return null;
    }
  }

  /// Get student's exam instances
  Future<List<ExamInstanceModel>> getStudentExamInstances(
      String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('exam_instances')
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExamInstanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting student exams: $e');
      return [];
    }
  }

  /// Update exam instance
  Future<void> updateExamInstance(
    String instanceId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection('exam_instances')
          .doc(instanceId)
          .update(updates);
    } catch (e) {
      print('❌ Error updating exam instance: $e');
      throw Exception('Không thể cập nhật bài thi: $e');
    }
  }

  /// Submit exam
  Future<void> submitExam(String instanceId) async {
    try {
      await updateExamInstance(instanceId, {
        'submittedAt': FieldValue.serverTimestamp(),
        'status': 'completed',
      });
      print('✅ Exam submitted: $instanceId');
    } catch (e) {
      print('❌ Error submitting exam: $e');
      throw Exception('Không thể nộp bài: $e');
    }
  }

  /// Check and expire exams
  Future<void> expireExam(String instanceId) async {
    try {
      await updateExamInstance(instanceId, {
        'status': 'expired',
      });
      print('⏰ Exam expired: $instanceId');
    } catch (e) {
      print('❌ Error expiring exam: $e');
    }
  }
}
