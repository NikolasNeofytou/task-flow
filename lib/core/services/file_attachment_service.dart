import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/file_attachment.dart';

/// Service for handling file attachments
class FileAttachmentService {
  /// Pick files using file picker
  static Future<List<PlatformFile>?> pickFiles({
    FileType type = FileType.any,
    bool allowMultiple = true,
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: allowMultiple,
      allowedExtensions: allowedExtensions,
      withData: false,
      withReadStream: true,
    );

    return result?.files;
  }

  /// Pick images
  static Future<List<PlatformFile>?> pickImages({bool allowMultiple = true}) {
    return pickFiles(
      type: FileType.image,
      allowMultiple: allowMultiple,
    );
  }

  /// Pick documents
  static Future<List<PlatformFile>?> pickDocuments({bool allowMultiple = true}) {
    return pickFiles(
      type: FileType.custom,
      allowMultiple: allowMultiple,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'],
    );
  }

  /// Save file to app directory
  static Future<String> saveFile(PlatformFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${appDir.path}/attachments');
    
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final savedPath = '${attachmentsDir.path}/${timestamp}_${file.name}';
    
    if (file.path != null) {
      await File(file.path!).copy(savedPath);
    }

    return savedPath;
  }

  /// Create FileAttachment from PlatformFile
  static Future<FileAttachment> createAttachment({
    required PlatformFile file,
    required String taskId,
    required String userId,
  }) async {
    final savedPath = await saveFile(file);

    return FileAttachment(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      name: file.name,
      path: savedPath,
      size: file.size,
      type: file.extension ?? 'unknown',
      uploadedAt: DateTime.now(),
      uploadedBy: userId,
    );
  }

  /// Delete attachment file
  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get file size
  static Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Check if file exists
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// Get total size of all attachments
  static Future<int> getTotalAttachmentSize() async {
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${appDir.path}/attachments');
    
    if (!await attachmentsDir.exists()) {
      return 0;
    }

    int totalSize = 0;
    await for (final entity in attachmentsDir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }

    return totalSize;
  }

  /// Clear all attachments
  static Future<void> clearAllAttachments() async {
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${appDir.path}/attachments');
    
    if (await attachmentsDir.exists()) {
      await attachmentsDir.delete(recursive: true);
    }
  }
}
