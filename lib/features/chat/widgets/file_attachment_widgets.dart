import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../theme/tokens.dart';
import '../models/chat_message.dart';

/// File attachment picker and handler
class FileAttachmentPicker {
  FileAttachmentPicker._();

  /// Pick an image file
  static Future<FileAttachment?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    return FileAttachment(
      path: file.path!,
      name: file.name,
      size: file.size,
      type: FileAttachmentType.image,
    );
  }

  /// Pick a document file
  static Future<FileAttachment?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    return FileAttachment(
      path: file.path!,
      name: file.name,
      size: file.size,
      type: FileAttachmentType.document,
    );
  }

  /// Pick any file type
  static Future<FileAttachment?> pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final type = _detectFileType(file.name);

    return FileAttachment(
      path: file.path!,
      name: file.name,
      size: file.size,
      type: type,
    );
  }

  static FileAttachmentType _detectFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) {
      return FileAttachmentType.image;
    }
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
      return FileAttachmentType.video;
    }
    if (['mp3', 'wav', 'ogg', 'm4a', 'flac'].contains(ext)) {
      return FileAttachmentType.audio;
    }
    if (['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'].contains(ext)) {
      return FileAttachmentType.document;
    }
    return FileAttachmentType.other;
  }
}

/// File attachment data
class FileAttachment {
  const FileAttachment({
    required this.path,
    required this.name,
    required this.size,
    required this.type,
  });

  final String path;
  final String name;
  final int size;
  final FileAttachmentType type;
}

/// File attachment preview in message bubble
class FileAttachmentPreview extends StatelessWidget {
  const FileAttachmentPreview({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.filePath,
    this.isMe = false,
    this.onTap,
  });

  final String fileName;
  final int fileSize;
  final FileAttachmentType fileType;
  final String filePath;
  final bool isMe;
  final VoidCallback? onTap;

  IconData _getIcon() {
    switch (fileType) {
      case FileAttachmentType.image:
        return Icons.image;
      case FileAttachmentType.document:
        return Icons.description;
      case FileAttachmentType.video:
        return Icons.videocam;
      case FileAttachmentType.audio:
        return Icons.audiotrack;
      case FileAttachmentType.other:
        return Icons.attach_file;
    }
  }

  Color _getIconColor() {
    switch (fileType) {
      case FileAttachmentType.image:
        return AppColors.success;
      case FileAttachmentType.document:
        return AppColors.primary;
      case FileAttachmentType.video:
        return AppColors.warning;
      case FileAttachmentType.audio:
        return AppColors.info;
      case FileAttachmentType.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // For images, show thumbnail
    if (fileType == FileAttachmentType.image) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 250,
              maxHeight: 250,
            ),
            child: Image.file(
              File(filePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _FileCard(
                  icon: _getIcon(),
                  iconColor: _getIconColor(),
                  fileName: fileName,
                  fileSize: fileSize,
                  isMe: isMe,
                );
              },
            ),
          ),
        ),
      );
    }

    // For other files, show card
    return GestureDetector(
      onTap: onTap,
      child: _FileCard(
        icon: _getIcon(),
        iconColor: _getIconColor(),
        fileName: fileName,
        fileSize: fileSize,
        isMe: isMe,
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  const _FileCard({
    required this.icon,
    required this.iconColor,
    required this.fileName,
    required this.fileSize,
    required this.isMe,
  });

  final IconData icon;
  final Color iconColor;
  final String fileName;
  final int fileSize;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withOpacity(0.1)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: isMe
              ? Colors.white.withOpacity(0.2)
              : colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isMe ? Colors.white : colorScheme.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  FileSizeFormatter.format(fileSize),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isMe
                            ? Colors.white.withOpacity(0.7)
                            : colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.download,
            size: 20,
            color: isMe
                ? Colors.white.withOpacity(0.7)
                : colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// File attachment picker bottom sheet
class FileAttachmentSheet extends StatelessWidget {
  const FileAttachmentSheet({
    super.key,
    required this.onImagePicked,
    required this.onDocumentPicked,
    required this.onFilePicked,
  });

  final void Function(FileAttachment) onImagePicked;
  final void Function(FileAttachment) onDocumentPicked;
  final void Function(FileAttachment) onFilePicked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Attach File',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _AttachmentOption(
            icon: Icons.image,
            iconColor: AppColors.success,
            label: 'Image',
            onTap: () async {
              final file = await FileAttachmentPicker.pickImage();
              if (file != null && context.mounted) {
                Navigator.pop(context);
                onImagePicked(file);
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _AttachmentOption(
            icon: Icons.description,
            iconColor: AppColors.primary,
            label: 'Document',
            onTap: () async {
              final file = await FileAttachmentPicker.pickDocument();
              if (file != null && context.mounted) {
                Navigator.pop(context);
                onDocumentPicked(file);
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _AttachmentOption(
            icon: Icons.attach_file,
            iconColor: AppColors.info,
            label: 'Any File',
            onTap: () async {
              final file = await FileAttachmentPicker.pickAnyFile();
              if (file != null && context.mounted) {
                Navigator.pop(context);
                onFilePicked(file);
              }
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  const _AttachmentOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
