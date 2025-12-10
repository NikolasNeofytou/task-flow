import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/providers/data_providers.dart';
import '../../../theme/tokens.dart';

/// Threaded chats per project; "all" represents the general channel.
final _chatThreadsProvider =
    StateNotifierProvider<ChatController, Map<String, List<_ChatMessageData>>>(
  (ref) => ChatController(ref.read(analyticsProvider)),
);

class ChatController extends StateNotifier<Map<String, List<_ChatMessageData>>> {
  ChatController(this._analytics)
      : super({
          'all': const [
            _ChatMessageData(
              author: 'Alex',
              text: 'Let’s finalize the tasks for Project X.',
              isMe: false,
            ),
            _ChatMessageData(
              author: 'You',
              text: 'On it. Adding deadlines now.',
              isMe: true,
            ),
            _ChatMessageData(
              author: 'Dana',
              text: 'I can take the calendar integration.',
              isMe: false,
            ),
          ],
          'proj-1': const [
            _ChatMessageData(
              author: 'Alex',
              text: 'Kickoff slides ready for Project A?',
              isMe: false,
            ),
            _ChatMessageData(
              author: 'You',
              text: 'Uploading them now.',
              isMe: true,
            ),
          ],
        });

  final AnalyticsService _analytics;

  void send(String channelId, String text) {
    if (text.trim().isEmpty) return;
    final msg = _ChatMessageData(author: 'You', text: text.trim(), isMe: true);
    final list = state[channelId] ?? [];
    state = {
      ...state,
      channelId: [...list, msg],
    };
    _analytics.logEvent('chat_send', parameters: {'length': text.trim().length});
  }
}

/// Chat list (WhatsApp-style): shows channels with last message; tap to open thread.
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(_chatThreadsProvider);
    final projectsAsync = ref.watch(projectsProvider);

    // Build channel list: general + all projects (even if empty).
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

    // Include any stored threads not yet in the list (e.g., seeded demo threads).
    for (final entry in threads.entries) {
      final id = entry.key;
      if (channels.any((c) => c.id == id)) continue;
      channels.add(
        _ChannelView(
          id: id,
          label: id == 'all' ? 'All projects' : 'Channel $id',
          messages: entry.value,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: channels.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final channel = channels[index];
          final last = channel.messages.isNotEmpty ? channel.messages.last : null;
          final subtitle = last?.text ?? 'No messages yet';
          final accent = Theme.of(context).colorScheme.primary.withOpacity(0.15);
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            leading: CircleAvatar(
              backgroundColor: accent,
              child: Text(channel.label.isNotEmpty ? channel.label[0].toUpperCase() : '?'),
            ),
            title: Text(channel.label, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              // Use go_router so the bottom nav stays in sync.
              context.go('/chat/${channel.id}', extra: channel.label);
            },
          );
        },
      ),
    );
  }
}

/// Thread view for a single channel.
class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.channelId, required this.label});

  final String channelId;
  final String label;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _controller = TextEditingController();
  bool _sending = false;
  bool get _canSend => _controller.text.trim().isNotEmpty && !_sending;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_canSend) return;
    ref.read(_chatThreadsProvider.notifier).send(widget.channelId, _controller.text);
    setState(() => _sending = true);
    _controller.clear();
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final threads = ref.watch(_chatThreadsProvider);
    final messages = threads[widget.channelId] ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(widget.label)),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _ChatMessage(
                  author: msg.author,
                  text: msg.text,
                  isMe: msg.isMe,
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Chat input',
                    textField: true,
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type here...',
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Semantics(
                  label: 'Send message',
                  button: true,
                  child: FilledButton(
                    onPressed: _canSend ? _send : null,
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  const _ChatMessage({
    required this.author,
    required this.text,
    required this.isMe,
  });

  final String author;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isMe
        ? AppColors.primary.withOpacity(0.18)
        : colorScheme.surfaceContainerHighest;
    final border = isMe ? AppColors.primary : colorScheme.outline.withOpacity(0.35);
    final textColor = isMe ? Colors.white : colorScheme.onSurface;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(author, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: border),
          ),
          child: Text(text, style: TextStyle(color: textColor)),
        ),
      ],
    );
  }
}

class _ChatMessageData {
  const _ChatMessageData({
    required this.author,
    required this.text,
    required this.isMe,
  });

  final String author;
  final String text;
  final bool isMe;
}

class _ChannelView {
  const _ChannelView({
    required this.id,
    required this.label,
    required this.messages,
  });

  final String id;
  final String label;
  final List<_ChatMessageData> messages;
}
