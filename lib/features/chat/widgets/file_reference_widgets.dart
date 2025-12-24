import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../models/chat_message.dart';

/// Widget to render text with clickable file references
class MessageTextWithReferences extends StatelessWidget {
  const MessageTextWithReferences({
    super.key,
    required this.text,
    required this.references,
    this.isMe = false,
    this.onReferenceClick,
  });

  final String text;
  final List<FileReference> references;
  final bool isMe;
  final void Function(FileReference)? onReferenceClick;

  @override
  Widget build(BuildContext context) {
    if (references.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface,
        ),
      );
    }

    // Render text with references as chips below
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          FileReferenceParser.replaceWithPlaceholders(text),
          style: TextStyle(
            color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: references
              .map((ref) => FileReferenceChip(
                    reference: ref,
                    isMe: isMe,
                    onTap: () => onReferenceClick?.call(ref),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

/// Clickable chip for file references
class FileReferenceChip extends StatelessWidget {
  const FileReferenceChip({
    super.key,
    required this.reference,
    this.isMe = false,
    this.onTap,
  });

  final FileReference reference;
  final bool isMe;
  final VoidCallback? onTap;

  IconData _getIcon() {
    switch (reference.fileType) {
      case FileAttachmentType.image:
        return Icons.image;
      case FileAttachmentType.document:
        return Icons.description;
      case FileAttachmentType.video:
        return Icons.videocam;
      case FileAttachmentType.audio:
        return Icons.audiotrack;
      default:
        return Icons.attach_file;
    }
  }

  Color _getIconColor() {
    switch (reference.fileType) {
      case FileAttachmentType.image:
        return AppColors.success;
      case FileAttachmentType.document:
        return AppColors.primary;
      case FileAttachmentType.video:
        return AppColors.warning;
      case FileAttachmentType.audio:
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = _getIconColor();

    return Material(
      color: isMe
          ? Colors.white.withOpacity(0.2)
          : colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIcon(),
                size: 16,
                color: isMe ? Colors.white : iconColor,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  reference.displayName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isMe ? Colors.white : colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.open_in_new,
                size: 12,
                color: isMe
                    ? Colors.white.withOpacity(0.7)
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Input field for adding file references
class FileReferenceInput extends StatefulWidget {
  const FileReferenceInput({
    super.key,
    required this.onReferenceAdded,
    required this.availableProjects,
  });

  final void Function(FileReference) onReferenceAdded;
  final List<ProjectInfo> availableProjects;

  @override
  State<FileReferenceInput> createState() => _FileReferenceInputState();
}

class _FileReferenceInputState extends State<FileReferenceInput> {
  final _fileNameController = TextEditingController();
  final _filePathController = TextEditingController();
  String? _selectedProjectId;
  FileAttachmentType _selectedType = FileAttachmentType.document;

  @override
  void dispose() {
    _fileNameController.dispose();
    _filePathController.dispose();
    super.dispose();
  }

  void _addReference() {
    if (_selectedProjectId == null ||
        _fileNameController.text.isEmpty ||
        _filePathController.text.isEmpty) {
      return;
    }

    final reference = FileReference(
      projectId: _selectedProjectId!,
      fileName: _fileNameController.text.trim(),
      filePath: _filePathController.text.trim(),
      fileType: _selectedType,
    );

    widget.onReferenceAdded(reference);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add File Reference',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Project selector
          DropdownButtonFormField<String>(
            initialValue: _selectedProjectId,
            decoration: const InputDecoration(
              labelText: 'Project',
              prefixIcon: Icon(Icons.folder),
            ),
            items: widget.availableProjects
                .map((project) => DropdownMenuItem(
                      value: project.id,
                      child: Text(project.name),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedProjectId = value);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          // File type selector
          DropdownButtonFormField<FileAttachmentType>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'File Type',
              prefixIcon: Icon(Icons.category),
            ),
            items: const [
              DropdownMenuItem(
                value: FileAttachmentType.document,
                child: Text('Document'),
              ),
              DropdownMenuItem(
                value: FileAttachmentType.image,
                child: Text('Image'),
              ),
              DropdownMenuItem(
                value: FileAttachmentType.video,
                child: Text('Video'),
              ),
              DropdownMenuItem(
                value: FileAttachmentType.audio,
                child: Text('Audio'),
              ),
              DropdownMenuItem(
                value: FileAttachmentType.other,
                child: Text('Other'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedType = value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          // File name
          TextField(
            controller: _fileNameController,
            decoration: const InputDecoration(
              labelText: 'File Name',
              hintText: 'e.g., design.pdf',
              prefixIcon: Icon(Icons.description),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // File path
          TextField(
            controller: _filePathController,
            decoration: const InputDecoration(
              labelText: 'File Path',
              hintText: 'e.g., /documents/design.pdf',
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: _addReference,
                icon: const Icon(Icons.add),
                label: const Text('Add Reference'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Project info for reference picker
class ProjectInfo {
  const ProjectInfo({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}
