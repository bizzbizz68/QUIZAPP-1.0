import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// File Upload Service - Upload audio/image to Firebase Storage
class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================
  // AUDIO UPLOAD
  // ============================================

  /// Upload audio file to Firebase Storage
  /// Path: hsk/audio/{hskLevel}/{questionType}/{timestamp}_{fileName}
  Future<String> uploadAudio({
    required Uint8List fileBytes,
    required String fileName,
    required int hskLevel,
    required String questionType,
  }) async {
    try {
      // Generate unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanFileName = _sanitizeFileName(fileName);
      final path =
          'hsk/audio/hsk$hskLevel/$questionType/${timestamp}_$cleanFileName';

      print('📤 Uploading audio to: $path');

      // Create reference
      final ref = _storage.ref().child(path);

      // Upload file with metadata
      final uploadTask = await ref.putData(
        fileBytes,
        SettableMetadata(
          contentType: _getAudioMimeType(fileName),
          customMetadata: {
            'hskLevel': hskLevel.toString(),
            'questionType': questionType,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('✅ Audio uploaded: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading audio: $e');
      throw Exception('Không thể upload audio: $e');
    }
  }

  /// Upload audio from file path (for mobile)
  Future<String> uploadAudioFromPath({
    required String filePath,
    required int hskLevel,
    required String questionType,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = filePath.split('/').last;
      final cleanFileName = _sanitizeFileName(fileName);
      final path =
          'hsk/audio/hsk$hskLevel/$questionType/${timestamp}_$cleanFileName';

      print('📤 Uploading audio from path: $filePath');

      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(
        // Note: Need to import dart:io for File
        // This is for mobile, web uses bytes
        throw UnimplementedError('Use uploadAudio() for web'),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('✅ Audio uploaded: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading audio from path: $e');
      throw Exception('Không thể upload audio: $e');
    }
  }

  // ============================================
  // IMAGE UPLOAD
  // ============================================

  /// Upload image file to Firebase Storage
  /// Path: hsk/images/{hskLevel}/{questionType}/{timestamp}_{fileName}
  Future<String> uploadImage({
    required Uint8List fileBytes,
    required String fileName,
    required int hskLevel,
    required String questionType,
    String? optionLabel, // "A", "B", "C" for multi-image questions
  }) async {
    try {
      // Generate unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanFileName = _sanitizeFileName(fileName);
      final suffix = optionLabel != null ? '_$optionLabel' : '';
      final path =
          'hsk/images/hsk$hskLevel/$questionType/${timestamp}$suffix\_$cleanFileName';

      print('📤 Uploading image to: $path');

      // Create reference
      final ref = _storage.ref().child(path);

      // Upload file with metadata
      final uploadTask = await ref.putData(
        fileBytes,
        SettableMetadata(
          contentType: _getImageMimeType(fileName),
          customMetadata: {
            'hskLevel': hskLevel.toString(),
            'questionType': questionType,
            if (optionLabel != null) 'optionLabel': optionLabel,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('✅ Image uploaded: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      throw Exception('Không thể upload hình ảnh: $e');
    }
  }

  /// Upload multiple images (for questions with multiple image options)
  Future<List<String>> uploadMultipleImages({
    required List<Uint8List> filesBytes,
    required List<String> fileNames,
    required int hskLevel,
    required String questionType,
    List<String>? optionLabels, // ["A", "B", "C", ...]
  }) async {
    try {
      final urls = <String>[];

      for (int i = 0; i < filesBytes.length; i++) {
        final url = await uploadImage(
          fileBytes: filesBytes[i],
          fileName: fileNames[i],
          hskLevel: hskLevel,
          questionType: questionType,
          optionLabel: optionLabels != null && i < optionLabels.length
              ? optionLabels[i]
              : null,
        );
        urls.add(url);
      }

      print('✅ Uploaded ${urls.length} images');
      return urls;
    } catch (e) {
      print('❌ Error uploading multiple images: $e');
      throw Exception('Không thể upload nhiều hình ảnh: $e');
    }
  }

  // ============================================
  // DELETE FILES
  // ============================================

  /// Delete file from Firebase Storage by URL
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      print('✅ Deleted file: $fileUrl');
    } catch (e) {
      print('❌ Error deleting file: $e');
      throw Exception('Không thể xóa file: $e');
    }
  }

  /// Delete multiple files
  Future<void> deleteFiles(List<String> fileUrls) async {
    try {
      for (final url in fileUrls) {
        await deleteFile(url);
      }
      print('✅ Deleted ${fileUrls.length} files');
    } catch (e) {
      print('❌ Error deleting files: $e');
      throw Exception('Không thể xóa files: $e');
    }
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Sanitize file name (remove special characters)
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[^\w\s\-\.]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  /// Get audio MIME type from file extension
  String _getAudioMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'ogg':
        return 'audio/ogg';
      case 'aac':
        return 'audio/aac';
      default:
        return 'audio/mpeg'; // Default to mp3
    }
  }

  /// Get image MIME type from file extension
  String _getImageMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg'; // Default to jpeg
    }
  }

  /// Get file size in MB
  double getFileSizeMB(Uint8List fileBytes) {
    return fileBytes.length / (1024 * 1024);
  }

  /// Validate file size (default: max 10MB)
  bool validateFileSize(Uint8List fileBytes, {double maxSizeMB = 10}) {
    final sizeMB = getFileSizeMB(fileBytes);
    return sizeMB <= maxSizeMB;
  }

  /// Validate audio file type
  bool validateAudioFile(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const allowedExtensions = ['mp3', 'wav', 'm4a', 'ogg', 'aac'];
    return allowedExtensions.contains(ext);
  }

  /// Validate image file type
  bool validateImageFile(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    return allowedExtensions.contains(ext);
  }

  // ============================================
  // BATCH OPERATIONS
  // ============================================

  /// Upload with progress callback
  Future<String> uploadAudioWithProgress({
    required Uint8List fileBytes,
    required String fileName,
    required int hskLevel,
    required String questionType,
    required Function(double progress) onProgress,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanFileName = _sanitizeFileName(fileName);
      final path =
          'hsk/audio/hsk$hskLevel/$questionType/${timestamp}_$cleanFileName';

      final ref = _storage.ref().child(path);

      // Start upload
      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: _getAudioMimeType(fileName)),
      );

      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });

      // Wait for completion
      final taskSnapshot = await uploadTask;
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading audio with progress: $e');
      throw Exception('Không thể upload audio: $e');
    }
  }

  /// Get storage usage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      // Note: Firebase Storage doesn't provide direct API for total usage
      // This would require listing all files and summing sizes
      // Or using Firebase Admin SDK on backend

      return {
        'message': 'Storage stats require backend implementation',
      };
    } catch (e) {
      print('❌ Error getting storage stats: $e');
      return {};
    }
  }
}
