import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/constants.dart';
import '../../data/models/hsk_template.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/question_model.dart';

/// Admin Exam Service
/// ONLY for ADMIN role - Quản lý exams và questions
/// Thêm, sửa, xóa đề thi và câu hỏi
class AdminExamService {
  static final AdminExamService _instance = AdminExamService._internal();
  factory AdminExamService() => _instance;
  AdminExamService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================
  // EXAM OPERATIONS (ADMIN ONLY)
  // ============================================

  /// Create new exam (Admin only)
  Future<String> createExam({
    required String title,
    required int level,
    required int duration,
    required String description,
    required int totalQuestions,
    required int passingScore,
    required String createdBy,
    bool isActive = true,
  }) async {
    try {
      final examData = {
        'title': title,
        'level': level,
        'duration': duration,
        'description': description,
        'totalQuestions': totalQuestions,
        'passingScore': passingScore,
        'isActive': isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': createdBy,
      };

      final docRef = await _firestore
          .collection(AppConstants.examsCollection)
          .add(examData);

      print('✅ Admin created exam: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating exam: $e');
      throw Exception('Không thể tạo đề thi: $e');
    }
  }

  /// Update exam (Admin only)
  Future<void> updateExam(String examId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .update(updates);

      print('✅ Admin updated exam: $examId');
    } catch (e) {
      print('❌ Error updating exam: $e');
      throw Exception('Không thể cập nhật đề thi: $e');
    }
  }

  /// Delete exam (Admin only)
  /// Soft delete: set isActive = false
  Future<void> deleteExam(String examId) async {
    try {
      await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .update({
            'isActive': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      print('✅ Admin deleted (soft) exam: $examId');
    } catch (e) {
      print('❌ Error deleting exam: $e');
      throw Exception('Không thể xóa đề thi: $e');
    }
  }

  /// Hard delete exam and all questions (Admin only)
  /// CẢNH BÁO: Xóa vĩnh viễn, không thể khôi phục!
  Future<void> hardDeleteExam(String examId) async {
    try {
      // Delete all questions first
      final questionsSnapshot = await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .collection(AppConstants.questionsSubCollection)
          .get();

      final batch = _firestore.batch();

      // Delete all questions
      for (var doc in questionsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Delete exam document
      await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .delete();

      print('✅ Admin hard deleted exam and all questions: $examId');
    } catch (e) {
      print('❌ Error hard deleting exam: $e');
      throw Exception('Không thể xóa vĩnh viễn đề thi: $e');
    }
  }

  /// Toggle exam active status (Admin only)
  Future<void> toggleExamStatus(String examId, bool isActive) async {
    try {
      await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .update({
            'isActive': isActive,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      print('✅ Admin toggled exam status: $examId -> $isActive');
    } catch (e) {
      print('❌ Error toggling exam status: $e');
      throw Exception('Không thể thay đổi trạng thái đề thi: $e');
    }
  }

  // ============================================
  // QUESTION OPERATIONS (ADMIN ONLY)
  // ============================================

  /// Add question to exam (Admin only)
  Future<String> addQuestion({
    required String examId,
    required Map<String, dynamic> content,
    required QuestionType type,
    required List<String> options,
    required dynamic correctAnswer,
    String? explanation,
    required int points,
    required int orderIndex,
    String? imageUrl,
    String? audioUrl,
  }) async {
    try {
      // Get section from question type
      final typeStr = type.toString().split('.').last;
      String section = 'nghe';
      if (typeStr.startsWith('doc_')) {
        section = 'doc';
      } else if (typeStr.startsWith('viet_')) {
        section = 'viet';
      }

      final questionData = {
        'examId': examId,
        'hskLevel': 1, // TODO: Get from exam
        'section': section,
        'content': content,
        'type': typeStr,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'points': points,
        'orderIndex': orderIndex,
        'createdBy': 'admin', // TODO: Get current user
        'updatedBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .collection(AppConstants.questionsSubCollection)
          .add(questionData);

      // Update totalQuestions count in exam
      await _updateExamQuestionCount(examId);

      print('✅ Admin added question: ${docRef.id} to exam: $examId');
      return docRef.id;
    } catch (e) {
      print('❌ Error adding question: $e');
      throw Exception('Không thể thêm câu hỏi: $e');
    }
  }

  /// Update question (Admin only)
  Future<void> updateQuestion(
    String examId,
    String questionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      updates['updatedBy'] = 'admin'; // TODO: Get current user

      await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .collection(AppConstants.questionsSubCollection)
          .doc(questionId)
          .update(updates);

      print('✅ Admin updated question: $questionId');
    } catch (e) {
      print('❌ Error updating question: $e');
      throw Exception('Không thể cập nhật câu hỏi: $e');
    }
  }

  /// Delete question (Admin only)
  Future<void> deleteQuestion(String examId, String questionId) async {
    try {
      await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .collection(AppConstants.questionsSubCollection)
          .doc(questionId)
          .delete();

      // Update totalQuestions count in exam
      await _updateExamQuestionCount(examId);

      print('✅ Admin deleted question: $questionId');
    } catch (e) {
      print('❌ Error deleting question: $e');
      throw Exception('Không thể xóa câu hỏi: $e');
    }
  }

  /// Batch add questions (Admin only)
  Future<void> batchAddQuestions(
    String examId,
    List<Map<String, dynamic>> questions,
  ) async {
    try {
      final batch = _firestore.batch();
      final questionsCollection = _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .collection(AppConstants.questionsSubCollection);

      for (var questionData in questions) {
        final docRef = questionsCollection.doc();
        questionData['createdAt'] = FieldValue.serverTimestamp();
        questionData['updatedAt'] = FieldValue.serverTimestamp();
        batch.set(docRef, questionData);
      }

      await batch.commit();

      // Update totalQuestions count
      await _updateExamQuestionCount(examId);

      print('✅ Admin batch added ${questions.length} questions to exam: $examId');
    } catch (e) {
      print('❌ Error batch adding questions: $e');
      throw Exception('Không thể thêm hàng loạt câu hỏi: $e');
    }
  }

  /// Reorder questions (Admin only)
  Future<void> reorderQuestions(
    String examId,
    List<String> questionIds,
  ) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < questionIds.length; i++) {
        final questionRef = _firestore
            .collection(AppConstants.examsCollection)
            .doc(examId)
            .collection(AppConstants.questionsSubCollection)
            .doc(questionIds[i]);

        batch.update(questionRef, {
          'orderIndex': i + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('✅ Admin reordered ${questionIds.length} questions');
    } catch (e) {
      print('❌ Error reordering questions: $e');
      throw Exception('Không thể sắp xếp lại câu hỏi: $e');
    }
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Update exam's totalQuestions count
  Future<void> _updateExamQuestionCount(String examId) async {
    try {
      final questionsSnapshot = await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .collection(AppConstants.questionsSubCollection)
          .get();

      await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .update({
            'totalQuestions': questionsSnapshot.docs.length,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('⚠️ Warning: Could not update question count: $e');
    }
  }

  /// Get all exams (including inactive) - Admin only
  Future<List<ExamModel>> getAllExamsIncludingInactive() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.examsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ExamModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting all exams: $e');
      throw Exception('Không thể lấy danh sách đề thi: $e');
    }
  }

  /// Duplicate exam with all questions (Admin only)
  Future<String> duplicateExam(String examId, String newTitle) async {
    try {
      // Get original exam
      final examDoc = await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .get();

      if (!examDoc.exists) {
        throw Exception('Exam not found');
      }

      final examData = examDoc.data()!;
      examData['title'] = newTitle;
      examData['createdAt'] = FieldValue.serverTimestamp();
      examData['updatedAt'] = FieldValue.serverTimestamp();

      // Create new exam
      final newExamRef = await _firestore
          .collection(AppConstants.examsCollection)
          .add(examData);

      // Get all questions from original exam
      final questionsSnapshot = await _firestore
          .collection(AppConstants.examsCollection)
          .doc(examId)
          .collection(AppConstants.questionsSubCollection)
          .orderBy('orderIndex')
          .get();

      // Copy questions to new exam
      final batch = _firestore.batch();
      for (var questionDoc in questionsSnapshot.docs) {
        final questionData = questionDoc.data();
        questionData['createdAt'] = FieldValue.serverTimestamp();
        questionData['updatedAt'] = FieldValue.serverTimestamp();

        final newQuestionRef = _firestore
            .collection(AppConstants.examsCollection)
            .doc(newExamRef.id)
            .collection(AppConstants.questionsSubCollection)
            .doc();

        batch.set(newQuestionRef, questionData);
      }

      await batch.commit();

      print('✅ Admin duplicated exam: $examId -> ${newExamRef.id}');
      return newExamRef.id;
    } catch (e) {
      print('❌ Error duplicating exam: $e');
      throw Exception('Không thể sao chép đề thi: $e');
    }
  }

  // ============================================
  // HSK TEMPLATE OPERATIONS
  // ============================================

  /// Create question skeletons from HSK template
  Future<void> createQuestionsFromTemplate({
    required String examId,
    required HskExamTemplate template,
  }) async {
    try {
      final batch = _firestore.batch();
      int questionNumber = 1;

      for (final section in template.sections) {
        for (final group in section.groups) {
          final indices = group.getRangeIndices();
          final startIndex = indices[0];
          final endIndex = indices[1];

          for (int i = startIndex; i <= endIndex; i++) {
            final questionRef = _firestore
                .collection(AppConstants.examsCollection)
                .doc(examId)
                .collection(AppConstants.questionsSubCollection)
                .doc();

            final questionData = {
              'examId': examId,
              'hskLevel': template.level,
              'section': section.name.toLowerCase(),
              'type': group.type.toString().split('.').last,
              'orderIndex': i,
              'content': {
                'text': '', // Empty - admin will fill
                if (group.requiresAudio) 'audioUrl': null,
                if (group.requiresImage) 'imageUrl': null,
              },
              'options': group.optionsLabels.isEmpty
                  ? []
                  : List.generate(
                      group.optionsCount,
                      (index) => '', // Empty options
                    ),
              'correctAnswer': '', // Empty - admin will fill
              'explanation': null,
              'points': 1,
              'createdBy': 'system',
              'updatedBy': 'system',
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              // Template metadata
              'templateDescription': group.description,
              'requiresAudio': group.requiresAudio,
              'requiresImage': group.requiresImage,
              'imageCount': group.imageCount,
              'isComplete': false, // Mark as incomplete until filled
            };

            batch.set(questionRef, questionData);
            questionNumber++;
          }
        }
      }

      await batch.commit();
      print('✅ Created ${questionNumber - 1} question skeletons for exam: $examId');
    } catch (e) {
      print('❌ Error creating questions from template: $e');
      throw Exception('Không thể tạo cấu trúc câu hỏi: $e');
    }
  }

  /// Get statistics (Admin only)
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final examsSnapshot = await _firestore
          .collection(AppConstants.examsCollection)
          .get();

      int totalExams = examsSnapshot.docs.length;
      int activeExams = examsSnapshot.docs.where((doc) => doc.data()['isActive'] == true).length;
      
      Map<int, int> examsByLevel = {};
      for (int level in AppConstants.hskLevels) {
        examsByLevel[level] = examsSnapshot.docs
            .where((doc) => doc.data()['level'] == level)
            .length;
      }

      return {
        'totalExams': totalExams,
        'activeExams': activeExams,
        'inactiveExams': totalExams - activeExams,
        'examsByLevel': examsByLevel,
      };
    } catch (e) {
      print('❌ Error getting statistics: $e');
      throw Exception('Không thể lấy thống kê: $e');
    }
  }
}
