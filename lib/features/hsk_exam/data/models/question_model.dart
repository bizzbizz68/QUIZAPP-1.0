import 'package:cloud_firestore/cloud_firestore.dart';

/// Mapping toàn bộ các dạng bài từ file TXT của bạn 
enum QuestionType {
  // Nghe
  nghe_dung_sai,
  nghe_tranh_ABC,
  nghe_ngan_hinh,
  nghe_ABC,
  nghe_dai_hinh,
  nghe_chon_ngan,
  nghe_chon_dai,
  nghe_chon_doan_dai,
  
  // Đọc
  doc_dung_sai,
  doc_chon_hinh,
  doc_dien_tu_cau_don,
  doc_ghep_cau,
  doc_dien_tu_hoi_thoai,
  doc_chon_3,
  doc_sap_xep,
  doc_chon_1_cau,
  doc_chon_2_cau,
  doc_dien_3_tu,
  doc_dien_4_tu,
  doc_chon_lon_nho, // Dành cho HSK 5-6 
  doc_cau_chon_cau,
  doc_dien_nhieu_tu,
  doc_dien_5_tu,
  
  // Viết
  viet_sap_xep_tu,
  viet_pinyin,
  viet_nhin_tranh,
  viet_doan_van_theo_tu,
  viet_doan_van_theo_hinh,
  doc_nho_viet
}

class QuestionModel {
  final String id;
  final String examId; 
  final int hskLevel; // Thêm level để dễ filter 
  final String section; // nghe, doc, viet
  final QuestionType type;
  final int orderIndex;
  
  // Dùng Map cho content để chứa: text, pinyin, imageUrl, audioUrl, passage (đoạn văn)
  final Map<String, dynamic> content; 
  final List<String> options;
  final dynamic correctAnswer; // String cho trắc nghiệm, List<String> cho điền nhiều chỗ
  final String? explanation;

  // --- PHẦN BỔ SUNG QUẢN LÝ ---
  final String createdBy; // UID người tạo
  final String updatedBy; // UID người cập nhật cuối
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestionModel({
    required this.id,
    required this.examId,
    required this.hskLevel,
    required this.section,
    required this.type,
    required this.orderIndex,
    required this.content,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      examId: data['examId'] ?? '',
      hskLevel: data['hskLevel'] ?? 1,
      section: data['section'] ?? '',
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == (data['questionType'] ?? data['type']),
        orElse: () => QuestionType.doc_dung_sai,
      ),
      orderIndex: data['orderIndex'] ?? 0,
      content: data['content'] ?? {},
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'],
      explanation: data['explanation'],
      createdBy: data['createdBy'] ?? '',
      updatedBy: data['updatedBy'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'examId': examId,
      'hskLevel': hskLevel,
      'section': section,
      'type': type.toString().split('.').last,
      'orderIndex': orderIndex,
      'content': content,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(), // Tự động lấy giờ server khi update
    };
  }
}