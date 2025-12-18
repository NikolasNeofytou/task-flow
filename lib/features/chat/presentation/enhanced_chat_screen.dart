import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/providers/data_providers.dart';
import '../../../theme/tokens.dart';
import '../models/chat_message.dart';
import '../widgets/voice_message_widgets.dart';
import '../widgets/file_attachment_widgets.dart';
import '../widgets/file_reference_widgets.dart';
import '../widgets/chat_files_gallery.dart';
import 'audio_call_screen.dart';

/// Enhanced chat controller with support for voice, files, and references
final chatThreadsProvider =
    StateNotifierProvider<EnhancedChatController, Map<String, List<ChatMessage>>>(
  (ref) => EnhancedChatController(ref.read(analyticsProvider)),
);

class EnhancedChatController extends StateNotifier<Map<String, List<ChatMessage>>> {
  EnhancedChatController(this._analytics)
      : super({
          'all': [
            // Yesterday morning
            ChatMessage(
              id: '1',
              author: 'Sarah',
              authorRole: UserRole.projectManager,
              timestamp: DateTime.now().subtract(const Duration(hours: 28)), // Yesterday morning
              isMe: false,
              type: MessageType.text,
              text: 'Good morning team! Ready to start the sprint.',
            ),
            ChatMessage(
              id: '2',
              author: 'Alex',
              authorRole: UserRole.developer,
              timestamp: DateTime.now().subtract(const Duration(hours: 27, minutes: 55)),
              isMe: false,
              type: MessageType.text,
              text: 'Morning! Let\'s do this.',
            ),
            // Yesterday afternoon - different phase
            ChatMessage(
              id: '3',
              author: 'You',
              authorRole: UserRole.designer,
              timestamp: DateTime.now().subtract(const Duration(hours: 21)), // Yesterday afternoon
              isMe: true,
              type: MessageType.text,
              text: 'Just finished the design mockups.',
            ),
            // Today morning
            ChatMessage(
              id: '4',
              author: 'Mike',
              authorRole: UserRole.tester,
              timestamp: DateTime.now().subtract(const Duration(hours: 4)), // Today morning
              isMe: false,
              type: MessageType.text,
              text: 'Great work everyone!',
            ),
            // Today afternoon - after 30+ min gap
            ChatMessage(
              id: '5',
              author: 'Alex',
              authorRole: UserRole.developer,
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              isMe: false,
              type: MessageType.text,
              text: 'Let\'s finalize the tasks for Project X.',
            ),
            ChatMessage(
              id: '6',
              author: 'You',
              authorRole: UserRole.designer,
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
              isMe: true,
              type: MessageType.text,
              text: 'On it. Adding deadlines now.',
            ),
          ],
        });

  final AnalyticsService _analytics;
  int _messageIdCounter = 7;

  void sendTextMessage(String channelId, String text) {
    if (text.trim().isEmpty) return;

    final hasReferences = FileReferenceParser.hasReferences(text);
    final references = hasReferences ? FileReferenceParser.parse(text) : <FileReference>[];

    final msg = ChatMessage(
      id: (_messageIdCounter++).toString(),
      author: 'You',
      authorRole: UserRole.designer, // Current user role
      timestamp: DateTime.now(),
      isMe: true,
      type: hasReferences ? MessageType.textWithReferences : MessageType.text,
      text: text.trim(),
      fileReferences: references,
    );

    final list = state[channelId] ?? [];
    state = {
      ...state,
      channelId: [...list, msg],
    };

    _analytics.logEvent('chat_send_text', parameters: {'length': text.trim().length});
  }

  void sendVoiceMessage(String channelId, String voicePath, Duration duration) {
    final msg = ChatMessage(
      id: (_messageIdCounter++).toString(),
      author: 'You',
      authorRole: UserRole.designer, // Current user role
      timestamp: DateTime.now(),
      isMe: true,
      type: MessageType.voice,
      voicePath: voicePath,
      voiceDuration: duration,
    );

    final list = state[channelId] ?? [];
    state = {
      ...state,
      channelId: [...list, msg],
    };

    _analytics.logEvent('chat_send_voice', parameters: {'duration': duration.inSeconds});
  }

  void sendFileMessage(
    String channelId,
    String filePath,
    String fileName,
    int fileSize,
    FileAttachmentType fileType,
  ) {
    final msg = ChatMessage(
      id: (_messageIdCounter++).toString(),
      author: 'You',
      authorRole: UserRole.designer, // Current user role
      timestamp: DateTime.now(),
      isMe: true,
      type: MessageType.file,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
    );

    final list = state[channelId] ?? [];
    state = {
      ...state,
      channelId: [...list, msg],
    };

    _analytics.logEvent('chat_send_file', parameters: {'type': fileType.name});
  }

  /// Mark a message as viewed by adding viewer information
  void markMessageAsViewed(String channelId, String messageId, String viewerName) {
    final messages = state[channelId] ?? [];
    final updatedMessages = messages.map((msg) {
      if (msg.id == messageId && !msg.isMe) {
        // Check if current user hasn't already viewed this message
        final alreadyViewed = msg.viewedBy.any((v) => v.userName == viewerName);
        
        if (!alreadyViewed) {
          final newViewer = MessageViewer(
            userId: 'current-user-id', // In real app, get from auth
            userName: viewerName,
            viewedAt: DateTime.now(),
          );
          
          return msg.copyWith(
            viewedBy: [...msg.viewedBy, newViewer],
          );
        }
      }
      return msg;
    }).toList();

    state = {
      ...state,
      channelId: updatedMessages,
    };
  }

  /// Update viewer information from socket event
  void updateMessageViewer(String channelId, String messageId, MessageViewer viewer) {
    final messages = state[channelId] ?? [];
    final updatedMessages = messages.map((msg) {
      if (msg.id == messageId) {
        // Check if viewer not already in list
        final alreadyViewed = msg.viewedBy.any((v) => v.userId == viewer.userId);
        
        if (!alreadyViewed) {
          return msg.copyWith(
            viewedBy: [...msg.viewedBy, viewer],
          );
        }
      }
      return msg;
    }).toList();

    state = {
      ...state,
      channelId: updatedMessages,
    };
  }

  /// Pin a message
  void pinMessage(String channelId, String messageId, String pinnedBy) {
    final messages = state[channelId] ?? [];
    final updatedMessages = messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(
          isPinned: true,
          pinnedBy: pinnedBy,
          pinnedAt: DateTime.now(),
        );
      }
      return msg;
    }).toList();

    state = {
      ...state,
      channelId: updatedMessages,
    };

    _analytics.logEvent('chat_pin_message', parameters: {'channel': channelId});
  }

  /// Unpin a message
  void unpinMessage(String channelId, String messageId) {
    final messages = state[channelId] ?? [];
    final updatedMessages = messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(
          isPinned: false,
          pinnedBy: null,
          pinnedAt: null,
        );
      }
      return msg;
    }).toList();

    state = {
      ...state,
      channelId: updatedMessages,
    };

    _analytics.logEvent('chat_unpin_message', parameters: {'channel': channelId});
  }

  /// Get all pinned messages for a channel
  List<ChatMessage> getPinnedMessages(String channelId) {
    final messages = state[channelId] ?? [];
    return messages.where((msg) => msg.isPinned).toList();
  }
}

/// Enhanced chat screen with voice and file support
class EnhancedChatScreen extends ConsumerWidget {
  const EnhancedChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(chatThreadsProvider);
    final projectsAsync = ref.watch(projectsProvider);

    // Build channel list
    final channels = <_ChannelView>[
      _ChannelView(
        id: 'all',
        label: 'All projects',
        messages: threads['all'] ?? const [],
      ),
    ];

    projectsAsync.whenData((projects) {
      for (final p in projects) {
        channels.add(
          _ChannelView(
            id: p.id,
            label: p.name,
            messages: threads[p.id] ?? const [],
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search conversations',
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
            onPressed: () {
              // TODO: Show options menu
            },
          ),
        ],
      ),
      body: channels.isEmpty
          ? _EmptyChatState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                final last = channel.messages.isNotEmpty ? channel.messages.last : null;
                final isFirst = index == 0;
                
                return _ChatChannelCard(
                  channel: channel,
                  lastMessage: last,
                  isFirst: isFirst,
                  onTap: () {
                    context.go('/chat/${channel.id}', extra: channel.label);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: New conversation
        },
        tooltip: 'New conversation',
        child: const Icon(Icons.edit),
      ),
    );
  }
}

/// Enhanced chat thread screen with voice, files, and references
class EnhancedChatThreadScreen extends ConsumerStatefulWidget {
  const EnhancedChatThreadScreen({
    super.key,
    required this.channelId,
    required this.label,
  });

  final String channelId;
  final String label;

  @override
  ConsumerState<EnhancedChatThreadScreen> createState() => _EnhancedChatThreadScreenState();
}

class _EnhancedChatThreadScreenState extends ConsumerState<EnhancedChatThreadScreen> {
  final _controller = TextEditingController();
  bool _sending = false;
  bool _isRecordingVoice = false;
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentText = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendText() async {
    if (_controller.text.trim().isEmpty || _sending) return;

    setState(() => _sending = true);
    ref.read(chatThreadsProvider.notifier).sendTextMessage(
          widget.channelId,
          _controller.text,
        );
    _controller.clear();
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) setState(() => _sending = false);
  }

  void _sendVoice(String path, Duration duration) {
    ref.read(chatThreadsProvider.notifier).sendVoiceMessage(
          widget.channelId,
          path,
          duration,
        );
    setState(() => _isRecordingVoice = false);
  }

  void _sendFile(FileAttachment file) {
    ref.read(chatThreadsProvider.notifier).sendFileMessage(
          widget.channelId,
          file.path,
          file.name,
          file.size,
          file.type,
        );
  }

  void _showFileAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FileAttachmentSheet(
        onImagePicked: _sendFile,
        onDocumentPicked: _sendFile,
        onFilePicked: _sendFile,
      ),
    );
  }

  void _showFilesGallery() {
    final messages = ref.read(chatThreadsProvider)[widget.channelId] ?? [];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatFilesGallery(messages: messages),
      ),
    );
  }

  void _startAudioCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioCallScreen(
          channelId: widget.channelId,
          channelName: widget.label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final threads = ref.watch(chatThreadsProvider);
    final messages = threads[widget.channelId] ?? const [];
    final pinnedMessages = messages.where((msg) => msg.isPinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: _startAudioCall,
            tooltip: 'Start audio call',
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _showFilesGallery,
            tooltip: 'View shared files',
          ),
        ],
      ),
      body: Column(
        children: [
          if (pinnedMessages.isNotEmpty)
            _PinnedMessagesSection(
              pinnedMessages: pinnedMessages,
              channelId: widget.channelId,
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              reverse: true,
              itemCount: _getItemCount(messages),
              itemBuilder: (context, index) {
                return _buildChatItem(context, messages, index);
              },
            ),
          ),
          const Divider(height: 1),
          _buildInputArea(),
        ],
      ),
    );
  }

  int _getItemCount(List<ChatMessage> messages) {
    if (messages.isEmpty) return 0;
    
    int count = messages.length;
    // Add milestones
    for (int i = 0; i < messages.length; i++) {
      final currentMsg = messages[i];
      final previousMsg = i > 0 ? messages[i - 1] : null;
      
      if (TimestampFormatter.shouldShowMilestone(
        previousMsg?.timestamp,
        currentMsg.timestamp,
      )) {
        count++;
      }
    }
    return count;
  }

  Widget _buildChatItem(BuildContext context, List<ChatMessage> messages, int visualIndex) {
    // Convert visual index to actual message structure
    int currentVisualIndex = 0;
    
    for (int i = 0; i < messages.length; i++) {
      final currentMsg = messages[i];
      final previousMsg = i > 0 ? messages[i - 1] : null;
      
      // Check if milestone should be shown before this message
      if (TimestampFormatter.shouldShowMilestone(
        previousMsg?.timestamp,
        currentMsg.timestamp,
      )) {
        // Account for milestone in visual index
        if (currentVisualIndex == _getItemCount(messages) - 1 - visualIndex) {
          return _ChatMilestone(timestamp: currentMsg.timestamp);
        }
        currentVisualIndex++;
      }
      
      // Check if this is the message at visualIndex
      if (currentVisualIndex == _getItemCount(messages) - 1 - visualIndex) {
        return Column(
          children: [
            _EnhancedChatMessage(
              message: currentMsg,
              channelId: widget.channelId,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        );
      }
      currentVisualIndex++;
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildInputArea() {
    if (_isRecordingVoice) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: VoiceRecorder(
          onRecordingComplete: _sendVoice,
          onCancel: () => setState(() => _isRecordingVoice = false),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Attach file button
          IconButton(
            onPressed: _showFileAttachmentSheet,
            icon: const Icon(Icons.attach_file),
            tooltip: 'Attach file',
          ),
          // Voice button
          IconButton(
            onPressed: () => setState(() => _isRecordingVoice = true),
            icon: const Icon(Icons.mic),
            tooltip: 'Voice message',
          ),
          const SizedBox(width: AppSpacing.xs),
          // Text input
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type here...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendText(),
              maxLines: null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Send button
          FilledButton(
            onPressed: _currentText.trim().isNotEmpty && !_sending ? _sendText : null,
            child: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, size: 18),
          ),
        ],
      ),
    );
  }
}

enum InputMode { text, voice }

/// Enhanced message bubble supporting voice, files, and references
class _EnhancedChatMessage extends ConsumerStatefulWidget {
  const _EnhancedChatMessage({
    required this.message,
    required this.channelId,
  });

  final ChatMessage message;
  final String channelId;

  @override
  ConsumerState<_EnhancedChatMessage> createState() => _EnhancedChatMessageState();
}

class _EnhancedChatMessageState extends ConsumerState<_EnhancedChatMessage> {
  bool _hasBeenViewed = false;

  @override
  void initState() {
    super.initState();
    // Mark message as viewed after a short delay (simulate reading)
    if (!widget.message.isMe && !_hasBeenViewed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_hasBeenViewed) {
          _hasBeenViewed = true;
          ref.read(chatThreadsProvider.notifier).markMessageAsViewed(
                widget.channelId,
                widget.message.id,
                'You', // In real app, get from auth
              );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final alignment = widget.message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = widget.message.isMe
        ? AppColors.primary
        : colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        // Author name and role
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.message.author,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            if (widget.message.authorRole != null) ...[
              const SizedBox(width: AppSpacing.xs),
              _RoleBadge(role: widget.message.authorRole!),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        // Message bubble
        GestureDetector(
          onLongPress: () => _showMessageActions(context),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: widget.message.isPinned
                  ? Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.message.isPinned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppRadii.md),
                        topRight: Radius.circular(AppRadii.md),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.push_pin,
                          size: 12,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pinned',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                _buildMessageContent(),
                // Timestamp and viewer info
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 
                    AppSpacing.xs, 
                    AppSpacing.md, 
                    AppSpacing.sm
                  ),
                  child: _buildMessageFooter(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMessageActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                widget.message.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              ),
              title: Text(widget.message.isPinned ? 'Unpin Message' : 'Pin Message'),
              onTap: () {
                Navigator.pop(context);
                if (widget.message.isPinned) {
                  ref.read(chatThreadsProvider.notifier).unpinMessage(
                        widget.channelId,
                        widget.message.id,
                      );
                } else {
                  ref.read(chatThreadsProvider.notifier).pinMessage(
                        widget.channelId,
                        widget.message.id,
                        'You', // In real app, get from auth
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = widget.message.isMe 
        ? Colors.white.withOpacity(0.7)
        : colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timestamp - tap to show full timestamp
        InkWell(
          onTap: () => _showFullTimestamp(context),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  size: 12,
                  color: textColor,
                ),
                const SizedBox(width: 4),
                Text(
                  TimestampFormatter.formatRelative(widget.message.timestamp),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: textColor,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ),
        // Viewer count - tap to show viewer list
        if (widget.message.viewedBy.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.xs),
          InkWell(
            onTap: () => _showViewerList(context),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility,
                    size: 12,
                    color: textColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.message.viewedBy.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: textColor,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showFullTimestamp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message Timestamp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sent:',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(
              TimestampFormatter.formatFull(widget.message.timestamp),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showViewerList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.visibility, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text('Viewed by ${widget.message.viewedBy.length}'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: widget.message.viewedBy.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final viewer = widget.message.viewedBy[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Text(viewer.userName[0].toUpperCase()),
                ),
                title: Text(viewer.userName),
                subtitle: Text(
                  TimestampFormatter.formatFull(viewer.viewedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (widget.message.type) {
      case MessageType.text:
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            widget.message.text ?? '',
            style: TextStyle(
              color: widget.message.isMe ? Colors.white : null,
            ),
          ),
        );

      case MessageType.textWithReferences:
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: MessageTextWithReferences(
            text: widget.message.text ?? '',
            references: widget.message.fileReferences,
            isMe: widget.message.isMe,
          ),
        );

      case MessageType.voice:
        return VoiceMessagePlayer(
          voicePath: widget.message.voicePath ?? '',
          duration: widget.message.voiceDuration ?? Duration.zero,
          isMe: widget.message.isMe,
        );

      case MessageType.file:
        return FileAttachmentPreview(
          fileName: widget.message.fileName ?? 'File',
          fileSize: widget.message.fileSize ?? 0,
          fileType: widget.message.fileType ?? FileAttachmentType.other,
          filePath: widget.message.filePath ?? '',
          isMe: widget.message.isMe,
        );
    }
  }
}

class _ChannelView {
  const _ChannelView({
    required this.id,
    required this.label,
    required this.messages,
  });

  final String id;
  final String label;
  final List<ChatMessage> messages;
}

/// Milestone separator widget showing phase of day and timestamp
class _ChatMilestone extends StatelessWidget {
  const _ChatMilestone({required this.timestamp});

  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Text(
                TimestampFormatter.formatMilestone(timestamp),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Role badge widget displaying user role
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    // Parse hex color
    final hexColor = role.colorHex.replaceAll('#', '');
    final color = Color(int.parse('FF$hexColor', radix: 16));
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        role.shortName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

/// Pinned messages section at the top of the chat
class _PinnedMessagesSection extends ConsumerWidget {
  const _PinnedMessagesSection({
    required this.pinnedMessages,
    required this.channelId,
  });

  final List<ChatMessage> pinnedMessages;
  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.push_pin,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Pinned Messages (${pinnedMessages.length})',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              itemCount: pinnedMessages.length,
              itemBuilder: (context, index) {
                final message = pinnedMessages[index];
                return _PinnedMessageCard(
                  message: message,
                  channelId: channelId,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual pinned message card
class _PinnedMessageCard extends ConsumerWidget {
  const _PinnedMessageCard({
    required this.message,
    required this.channelId,
  });

  final ChatMessage message;
  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      child: Text(
                        message.author[0].toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                message.author,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (message.authorRole != null) ...[
                                const SizedBox(width: 4),
                                _RoleBadge(role: message.authorRole!),
                              ],
                            ],
                          ),
                          Text(
                            TimestampFormatter.formatRelative(message.timestamp),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 9,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Message preview
                Expanded(
                  child: Text(
                    _getMessagePreview(),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Unpin button
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(
                Icons.close,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              onPressed: () {
                ref.read(chatThreadsProvider.notifier).unpinMessage(
                      channelId,
                      message.id,
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getMessagePreview() {
    switch (message.type) {
      case MessageType.text:
      case MessageType.textWithReferences:
        return message.text ?? 'Message';
      case MessageType.voice:
        return '🎤 Voice message (${message.voiceDuration?.inSeconds ?? 0}s)';
      case MessageType.file:
        return '📎 ${message.fileName ?? 'File'}';
    }
  }
}

/// Aesthetic chat channel card widget
class _ChatChannelCard extends StatelessWidget {
  const _ChatChannelCard({
    required this.channel,
    required this.lastMessage,
    required this.isFirst,
    required this.onTap,
  });

  final _ChannelView channel;
  final ChatMessage? lastMessage;
  final bool isFirst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Generate colors based on channel name
    final colors = _getChannelColors(channel.label);
    const hasUnread = false; // TODO: Implement unread logic
    
    return Card(
      margin: EdgeInsets.only(
        bottom: AppSpacing.md,
        top: isFirst ? AppSpacing.sm : 0,
      ),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Avatar with gradient
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    channel.label.isNotEmpty 
                        ? channel.label.substring(0, 1).toUpperCase() 
                        : '?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with timestamp
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            channel.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastMessage != null)
                          const SizedBox(width: AppSpacing.xs),
                        if (lastMessage != null)
                          Text(
                            _formatTimestamp(lastMessage!.timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: hasUnread 
                                  ? colorScheme.primary 
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    
                    // Message preview row
                    Row(
                      children: [
                        // Message type icon
                        if (lastMessage != null)
                          Icon(
                            _getMessageIcon(lastMessage!.type),
                            size: 16,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        if (lastMessage != null)
                          const SizedBox(width: AppSpacing.xs),
                        
                        // Preview text
                        Expanded(
                          child: Text(
                            _getMessagePreview(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: hasUnread 
                                  ? colorScheme.onSurface 
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Unread badge (TODO: Will be shown when unread logic is implemented)
                        // if (hasUnread && unreadCount > 0)
                        //   const SizedBox(width: AppSpacing.sm),
                        // if (hasUnread && unreadCount > 0)
                        //   Container(
                        //     constraints: const BoxConstraints(minWidth: 20),
                        //     height: 20,
                        //     padding: const EdgeInsets.symmetric(horizontal: 6),
                        //     decoration: BoxDecoration(
                        //       color: colorScheme.primary,
                        //       borderRadius: BorderRadius.circular(10),
                        //     ),
                        //     child: Center(
                        //       child: Text(
                        //         unreadCount > 99 ? '99+' : unreadCount.toString(),
                        //         style: theme.textTheme.labelSmall?.copyWith(
                        //           color: colorScheme.onPrimary,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getChannelColors(String label) {
    // Generate gradient colors based on channel name
    final hash = label.hashCode;
    final hue = (hash % 360).toDouble();
    
    return [
      HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor(),
      HSLColor.fromAHSL(1.0, (hue + 30) % 360, 0.7, 0.6).toColor(),
    ];
  }

  IconData _getMessageIcon(MessageType type) {
    switch (type) {
      case MessageType.text:
      case MessageType.textWithReferences:
        return Icons.chat_bubble_outline;
      case MessageType.voice:
        return Icons.mic;
      case MessageType.file:
        return Icons.attach_file;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      // Today - show time
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[(timestamp.weekday - 1) % 7];
    } else {
      // Older - show date
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  String _getMessagePreview() {
    if (lastMessage == null) return 'No messages yet';
    
    final prefix = lastMessage!.isMe ? 'You: ' : '${lastMessage!.author}: ';
    
    switch (lastMessage!.type) {
      case MessageType.text:
      case MessageType.textWithReferences:
        return '$prefix${lastMessage!.text ?? 'Message'}';
      case MessageType.voice:
        return '${prefix}Voice message';
      case MessageType.file:
        return '$prefix${lastMessage!.fileName ?? 'File'}';
    }
  }
}

/// Empty state for chat when no conversations exist
class _EmptyChatState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(0.2),
                    colorScheme.secondary.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No conversations yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start a conversation with your team\nto collaborate on projects',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () {
                // TODO: New conversation
              },
              icon: const Icon(Icons.add),
              label: const Text('Start a conversation'),
            ),
          ],
        ),
      ),
    );
  }
}

