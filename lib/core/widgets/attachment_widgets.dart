import 'dart:io';
import 'package:flutter/material.dart';

import '../models/file_attachment.dart';
import '../services/file_attachment_service.dart';
import '../../theme/tokens.dart';

/// Widget to display and manage file attachments
class AttachmentList extends StatelessWidget {
  final List<FileAttachment> attachments;
  final Function(FileAttachment)? onDelete;
  final Function(FileAttachment)? onTap;
  final bool readOnly;

  const AttachmentList({
    super.key,
    required this.attachments,
    this.onDelete,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments (${attachments.length})',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...attachments.map((attachment) => AttachmentTile(
              attachment: attachment,
              onDelete: onDelete != null && !readOnly
                  ? () => onDelete!(attachment)
                  : null,
              onTap: onTap != null ? () => onTap!(attachment) : null,
            )),
      ],
    );
  }
}

/// Single attachment tile
class AttachmentTile extends StatelessWidget {
  final FileAttachment attachment;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AttachmentTile({
    super.key,
    required this.attachment,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: _buildIcon(),
        title: Text(
          attachment.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(attachment.sizeFormatted),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: Colors.red,
              )
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    if (attachment.isImage) {
      icon = Icons.image;
      color = Colors.blue;
    } else if (attachment.isPDF) {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (attachment.isDocument) {
      icon = Icons.description;
      color = Colors.orange;
    } else {
      icon = Icons.attach_file;
      color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

/// Button to add attachments
class AddAttachmentButton extends StatelessWidget {
  final Function(List<FileAttachment>) onAttachmentsAdded;
  final String taskId;
  final String userId;

  const AddAttachmentButton({
    super.key,
    required this.onAttachmentsAdded,
    required this.taskId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _pickFiles(context),
      icon: const Icon(Icons.attach_file),
      label: const Text('Add Attachments'),
    );
  }

  Future<void> _pickFiles(BuildContext context) async {
    final files = await FileAttachmentService.pickFiles();

    if (files == null || files.isEmpty) return;

    // Show loading
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final attachments = <FileAttachment>[];

      for (final file in files) {
        final attachment = await FileAttachmentService.createAttachment(
          file: file,
          taskId: taskId,
          userId: userId,
        );
        attachments.add(attachment);
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        onAttachmentsAdded(attachments);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding attachments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Image preview widget
class AttachmentPreview extends StatelessWidget {
  final FileAttachment attachment;

  const AttachmentPreview({
    super.key,
    required this.attachment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(attachment.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
            },
          ),
        ],
      ),
      body: Center(
        child: attachment.isImage
            ? FutureBuilder<bool>(
                future: FileAttachmentService.fileExists(attachment.path),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return InteractiveViewer(
                      child: Image.file(File(attachment.path)),
                    );
                  }
                  return const Text('File not found');
                },
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    attachment.isPDF ? Icons.picture_as_pdf : Icons.description,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    attachment.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    attachment.sizeFormatted,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Open with external app
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open with...'),
                  ),
                ],
              ),
      ),
    );
  }
}
