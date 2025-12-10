import 'dart:io';
import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../models/chat_message.dart';

/// Messenger-style files gallery view showing all shared files
class ChatFilesGallery extends StatefulWidget {
  const ChatFilesGallery({
    super.key,
    required this.messages,
  });

  final List<ChatMessage> messages;

  @override
  State<ChatFilesGallery> createState() => _ChatFilesGalleryState();
}

class _ChatFilesGalleryState extends State<ChatFilesGallery>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FileAttachmentType? _filterType;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ChatMessage> get _allFiles {
    return widget.messages
        .where((msg) =>
            msg.type == MessageType.file ||
            (msg.type == MessageType.textWithReferences &&
                msg.fileReferences.isNotEmpty))
        .toList();
  }

  List<ChatMessage> get _images {
    return widget.messages
        .where((msg) =>
            msg.type == MessageType.file &&
            msg.fileType == FileAttachmentType.image)
        .toList();
  }

  List<ChatMessage> get _documents {
    return widget.messages
        .where((msg) =>
            msg.type == MessageType.file &&
            msg.fileType == FileAttachmentType.document)
        .toList();
  }

  List<FileReference> get _allReferences {
    final refs = <FileReference>[];
    for (final msg in widget.messages) {
      if (msg.type == MessageType.textWithReferences) {
        refs.addAll(msg.fileReferences);
      }
    }
    return refs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Files'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'All (${_allFiles.length})',
              icon: const Icon(Icons.folder),
            ),
            Tab(
              text: 'Images (${_images.length})',
              icon: const Icon(Icons.image),
            ),
            Tab(
              text: 'Docs (${_documents.length})',
              icon: const Icon(Icons.description),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllFilesView(),
          _buildImagesView(),
          _buildDocumentsView(),
        ],
      ),
    );
  }

  Widget _buildAllFilesView() {
    if (_allFiles.isEmpty && _allReferences.isEmpty) {
      return _buildEmptyState('No files shared yet');
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (_allFiles.isNotEmpty) ...[
          _buildSectionHeader('Attachments (${_allFiles.length})'),
          const SizedBox(height: AppSpacing.sm),
          _isGridView
              ? _buildFileGrid(_allFiles)
              : _buildFileList(_allFiles),
        ],
        if (_allReferences.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('File References (${_allReferences.length})'),
          const SizedBox(height: AppSpacing.sm),
          _buildReferencesList(_allReferences),
        ],
      ],
    );
  }

  Widget _buildImagesView() {
    if (_images.isEmpty) {
      return _buildEmptyState('No images shared yet');
    }

    return _isGridView
        ? _buildImageGrid(_images)
        : _buildFileList(_images);
  }

  Widget _buildDocumentsView() {
    if (_documents.isEmpty) {
      return _buildEmptyState('No documents shared yet');
    }

    return _buildFileList(_documents);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileGrid(List<ChatMessage> files) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return _FileGridItem(message: file);
      },
    );
  }

  Widget _buildImageGrid(List<ChatMessage> images) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.sm),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return _ImageGridItem(message: image);
      },
    );
  }

  Widget _buildFileList(List<ChatMessage> files) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: files.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final file = files[index];
        return _FileListItem(message: file);
      },
    );
  }

  Widget _buildReferencesList(List<FileReference> references) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: references.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final ref = references[index];
        return _FileReferenceListItem(reference: ref);
      },
    );
  }
}

class _FileGridItem extends StatelessWidget {
  const _FileGridItem({required this.message});

  final ChatMessage message;

  IconData _getIcon() {
    switch (message.fileType) {
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
    switch (message.fileType) {
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
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: () {
          // TODO: Open file preview
        },
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(), size: 32, color: iconColor),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                message.fileName ?? 'File',
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGridItem extends StatelessWidget {
  const _ImageGridItem({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Image.file(
        File(message.filePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: const Icon(Icons.broken_image),
          );
        },
      ),
    );
  }
}

class _FileListItem extends StatelessWidget {
  const _FileListItem({required this.message});

  final ChatMessage message;

  IconData _getIcon() {
    switch (message.fileType) {
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
    switch (message.fileType) {
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
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: () {
          // TODO: Open file preview
        },
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
                child: Icon(_getIcon(), color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileName ?? 'File',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${FileSizeFormatter.format(message.fileSize ?? 0)} • ${message.author}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.download,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileReferenceListItem extends StatelessWidget {
  const _FileReferenceListItem({required this.reference});

  final FileReference reference;

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
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to project file
        },
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
                child: Icon(_getIcon(), color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reference.fileName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reference.filePath,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
