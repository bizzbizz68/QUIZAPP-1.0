import 'package:cloud_firestore/cloud_firestore.dart';
// QuestionBankModel removed - not needed in hierarchical service
import '../models/question_model.dart';

/// Hierarchical Question Bank Service
/// Service để query questions từ hierarchical structure mới
/// Path: HSK/{level}/{skill}/{taskType}/questions/{questionId}
class HierarchicalQuestionBankService {
  static final HierarchicalQuestionBankService _instance =
      HierarchicalQuestionBankService._internal();
  factory HierarchicalQuestionBankService() => _instance;
  HierarchicalQuestionBankService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================
  // MAPPING UTILITIES
  // ============================================

  /// Map Vietnamese section to English skill
  String _mapSectionToSkill(String section) {
    switch (section) {
      case 'nghe':
        return 'listening';
      case 'doc':
        return 'reading';
      case 'viet':
        return 'writing';
      default:
        return section;
    }
  }

  /// Map QuestionType to PascalCase task type
  String _mapQuestionTypeToTaskType(QuestionType questionType) {
    final typeStr = questionType.toString().split('.').last;
    
    final mapping = {
      // Listening
      'nghe_dung_sai': 'True_False',
      'nghe_tranh_ABC': 'Match_Picture_ABC',
      'nghe_ngan_hinh': 'Match_Image_Short',
      'nghe_ABC': 'Dialogue_ABC',
      'nghe_dai_hinh': 'Match_Image_Long',
      'nghe_chon_ngan': 'Short_Dialogue_ABC',
      'nghe_chon_dai': 'Long_Dialogue_ABC',
      'nghe_chon_doan_dai': 'Long_Passage_ABC',
      
      // Reading
      'doc_dung_sai': 'True_False',
      'doc_chon_hinh': 'Match_Picture',
      'doc_dien_tu_cau_don': 'Fill_Blank_Single',
      'doc_ghep_cau': 'Match_Sentences',
      'doc_dien_tu_hoi_thoai': 'Fill_Blank_Dialogue',
      'doc_chon_3': 'Multiple_Choice',
      'doc_sap_xep': 'Sentence_Reorder',
      'doc_chon_1_cau': 'Single_Choice',
      'doc_dien_3_tu': 'Cloze_Test',
      'doc_chon_lon_nho': 'Comprehension_Group',
      'doc_dien_5_tu': 'Fill_Missing_Sentences',
      'doc_nho_viet': 'Remember_Summarize',
      
      // Writing
      'viet_sap_xep_tu': 'Sentence_Reorder',
      'viet_pinyin': 'Pinyin_To_Character',
      'viet_nhin_tranh': 'Describe_Picture',
      'viet_doan_van_theo_tu': 'Essay_From_Words',
      'viet_doan_van_theo_hinh': 'Essay_From_Picture',
    };

    return mapping[typeStr] ?? typeStr;
  }

  // ============================================
  // READ - SINGLE QUESTION
  // ============================================

  /// Get question by path components
  Future<QuestionModel?> getQuestion({
    required int hskLevel,
    required String section,
    required QuestionType questionType,
    required String questionId,
  }) async {
    try {
      final level = 'HSK$hskLevel';
      final skill = _mapSectionToSkill(section);
      final taskType = _mapQuestionTypeToTaskType(questionType);

      final doc = await _firestore
          .collection('HSK')
          .doc(level)
          .collection(skill)
          .doc(taskType)
          .collection('questions')
          .doc(questionId)
          .get();

      if (!doc.exists) return null;

      return QuestionModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting question: $e');
      return null;
    }
  }

  // ============================================
  // READ - MULTIPLE QUESTIONS
  // ============================================

  /// Get all questions of a task type
  Future<List<QuestionModel>> getQuestionsByTaskType({
    required int hskLevel,
    required String section,
    required QuestionType questionType,
    int? limit,
  }) async {
    try {
      final level = 'HSK$hskLevel';
      final skill = _mapSectionToSkill(section);
      final taskType = _mapQuestionTypeToTaskType(questionType);

      Query query = _firestore
          .collection('HSK')
          .doc(level)
          .collection(skill)
          .doc(taskType)
          .collection('questions');

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting questions by task type: $e');
      return [];
    }
  }

  /// Get all questions of a skill
  Future<List<QuestionModel>> getQuestionsBySkill({
    required int hskLevel,
    required String section,
  }) async {
    try {
      final level = 'HSK$hskLevel';
      final skill = _mapSectionToSkill(section);

      final allQuestions = <QuestionModel>[];

      // Get all task types in this skill
      final taskTypesSnapshot = await _firestore
          .collection('HSK')
          .doc(level)
          .collection(skill)
          .get();

      // For each task type, get all questions
      for (var taskTypeDoc in taskTypesSnapshot.docs) {
        final questionsSnapshot =
            await taskTypeDoc.reference.collection('questions').get();

        final questions = questionsSnapshot.docs
            .map((doc) => QuestionModel.fromFirestore(doc))
            .toList();

        allQuestions.addAll(questions);
      }

      return allQuestions;
    } catch (e) {
      print('❌ Error getting questions by skill: $e');
      return [];
    }
  }

  /// Get all questions of a level
  Future<List<QuestionModel>> getQuestionsByLevel({
    required int hskLevel,
  }) async {
    try {
      final level = 'HSK$hskLevel';
      final allQuestions = <QuestionModel>[];

      print('🔍 DEBUG: Querying HSK collection, level: $level');

      final skills = ['listening', 'reading', 'writing'];

      for (var skill in skills) {
        try {
          print('🔍 DEBUG: Querying skill: $skill');
          final taskTypesSnapshot = await _firestore
              .collection('HSK')
              .doc(level)
              .collection(skill)
              .get();

          print('🔍 DEBUG: Found ${taskTypesSnapshot.docs.length} task types in $skill');

          for (var taskTypeDoc in taskTypesSnapshot.docs) {
            print('🔍 DEBUG: Task type: ${taskTypeDoc.id}');
            final questionsSnapshot =
                await taskTypeDoc.reference.collection('questions').get();

            print('🔍 DEBUG: Found ${questionsSnapshot.docs.length} questions in ${taskTypeDoc.id}');

            final questions = questionsSnapshot.docs
                .map((doc) => QuestionModel.fromFirestore(doc))
                .toList();

            allQuestions.addAll(questions);
          }
        } catch (e) {
          print('❌ DEBUG: Error in skill $skill: $e');
          // Skill not found, continue
        }
      }

      print('✅ DEBUG: Total questions found: ${allQuestions.length}');
      return allQuestions;
    } catch (e) {
      print('❌ Error getting questions by level: $e');
      return [];
    }
  }

  /// Get random questions from a task type
  Future<List<QuestionModel>> getRandomQuestions({
    required int hskLevel,
    required String section,
    required QuestionType questionType,
    required int count,
  }) async {
    try {
      // Get all questions of this task type
      final allQuestions = await getQuestionsByTaskType(
        hskLevel: hskLevel,
        section: section,
        questionType: questionType,
      );

      if (allQuestions.isEmpty) {
        throw Exception(
            'Không có câu hỏi nào cho HSK$hskLevel / $section / ${questionType.toString().split('.').last}');
      }

      if (allQuestions.length < count) {
        print(
            '⚠️ Chỉ có ${allQuestions.length} câu, yêu cầu $count câu. Sẽ lấy tất cả.');
        return allQuestions;
      }

      // Random selection
      allQuestions.shuffle();
      return allQuestions.take(count).toList();
    } catch (e) {
      print('❌ Error getting random questions: $e');
      rethrow;
    }
  }

  // ============================================
  // COUNT
  // ============================================

  /// Count questions by task type
  Future<int> countQuestionsByTaskType({
    required int hskLevel,
    required String section,
    required QuestionType questionType,
  }) async {
    try {
      final level = 'HSK$hskLevel';
      final skill = _mapSectionToSkill(section);
      final taskType = _mapQuestionTypeToTaskType(questionType);

      final snapshot = await _firestore
          .collection('HSK')
          .doc(level)
          .collection(skill)
          .doc(taskType)
          .collection('questions')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error counting questions: $e');
      return 0;
    }
  }

  /// Get statistics for a level
  Future<Map<String, dynamic>> getStatistics(int hskLevel) async {
    try {
      final level = 'HSK$hskLevel';
      final stats = <String, dynamic>{};

      final skills = ['listening', 'reading', 'writing'];

      for (var skill in skills) {
        try {
          final taskTypesSnapshot = await _firestore
              .collection('HSK')
              .doc(level)
              .collection(skill)
              .get();

          int skillTotal = 0;

          for (var taskTypeDoc in taskTypesSnapshot.docs) {
            final countSnapshot =
                await taskTypeDoc.reference.collection('questions').count().get();

            skillTotal += countSnapshot.count ?? 0;
          }

          stats[skill] = skillTotal;
        } catch (e) {
          stats[skill] = 0;
        }
      }

      stats['total'] = stats.values.fold<int>(0, (sum, count) => sum + (count as int));

      return stats;
    } catch (e) {
      print('❌ Error getting statistics: $e');
      return {};
    }
  }

  // ============================================
  // STREAM
  // ============================================

  /// Watch questions of a task type real-time
  Stream<List<QuestionModel>> watchQuestionsByTaskType({
    required int hskLevel,
    required String section,
    required QuestionType questionType,
  }) {
    final level = 'HSK$hskLevel';
    final skill = _mapSectionToSkill(section);
    final taskType = _mapQuestionTypeToTaskType(questionType);

    return _firestore
        .collection('HSK')
        .doc(level)
        .collection(skill)
        .doc(taskType)
        .collection('questions')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================
  // CREATE (Admin only)
  // ============================================

  /// Add new question to hierarchical structure
  Future<String> addQuestion({
    required int hskLevel,
    required String section,
    required QuestionType questionType,
    required Map<String, dynamic> content,
    required List<String> options,
    required dynamic correctAnswer,
    String? explanation,
    String? difficulty,
    List<String> tags = const [],
    required String createdBy,
  }) async {
    try {
      final level = 'HSK$hskLevel';
      final skill = _mapSectionToSkill(section);
      final taskType = _mapQuestionTypeToTaskType(questionType);

      // 1. Ensure HSK level document exists (not phantom)
      await _firestore
          .collection('HSK')
          .doc(level)
          .set({
            'level': hskLevel,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // 2. Ensure task type document exists (not phantom)
      await _firestore
          .collection('HSK')
          .doc(level)
          .collection(skill)
          .doc(taskType)
          .set({
            'taskType': taskType,
            'skill': skill,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // 3. Get next question ID
      final existingQuestionsSnapshot = await _firestore
          .collection('HSK')
          .doc(level)
          .collection(skill)
          .doc(taskType)
          .collection('questions')
          .get();

      final nextId = (existingQuestionsSnapshot.docs.length + 1)
          .toString()
          .padLeft(3, '0');

      final questionData = {
        'hskLevel': hskLevel,
        'section': section,
        'questionType': questionType.toString().split('.').last,
        'level': level,
        'skill': skill,
        'taskType': taskType,
        'questionId': nextId,
        'content': content,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'difficulty': difficulty,
        'tags': tags,
        'isActive': true,
        'usageCount': 0,
        'correctRate': 0.0,
        'createdBy': createdBy,
        'updatedBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('HSK')
          .doc(level)
          .collection(skill)
          .doc(taskType)
          .collection('questions')
          .doc(nextId)
          .set(questionData);

      print('✅ Added question: $level/$skill/$taskType/$nextId');
      return nextId;
    } catch (e) {
      print('❌ Error adding question: $e');
      throw Exception('Không thể thêm câu hỏi: $e');
    }
  }

  // ============================================
  // UPDATE (Admin only)
  // ============================================

  /// Update question
  Future<void> updateQuestion({
    required int hskLevel,
    required String section,
    required QuestionType questionType,
    required String questionId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final level = 'HSK$hskLevel';
      final skill = _mapSectionToSkill(section);
      final taskType = _mapQuestionTypeToTaskType(questionType);

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('HSK')
          .doc(level)
          .collection(skill)
          .doc(taskType)
          .collection('questions')
          .doc(questionId)
          .update(updates);

      print('✅ Updated question: $level/$skill/$taskType/$questionId');
    } catch (e) {
      print('❌ Error updating question: $e');
      throw Exception('Không thể cập nhật câu hỏi: $e');
    }
  }

  // ============================================
  // DELETE (Admin only)
  // ============================================

  /// Delete question
  Future<void> deleteQuestion({
    required int hskLevel,
    required String section,
    required QuestionType questionType,
    required String questionId,
  }) async {
    try {
      final level = 'HSK$hskLevel';
      final skill = _mapSectionToSkill(section);
      final taskType = _mapQuestionTypeToTaskType(questionType);

      await _firestore
          .collection('HSK')
          .doc(level)
          .collection(skill)
          .doc(taskType)
          .collection('questions')
          .doc(questionId)
          .delete();

      print('✅ Deleted question: $level/$skill/$taskType/$questionId');
    } catch (e) {
      print('❌ Error deleting question: $e');
      throw Exception('Không thể xóa câu hỏi: $e');
    }
  }
}
