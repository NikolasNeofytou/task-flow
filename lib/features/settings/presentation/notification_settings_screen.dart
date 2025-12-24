import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/services/local_notification_service.dart';
import '../../../theme/tokens.dart';

/// Notification settings provider
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(),
);

class NotificationSettings {
  final bool taskReminders;
  final bool commentNotifications;
  final bool assignmentNotifications;
  final bool mentionNotifications;
  final bool dailyDigest;
  final TimeOfDay digestTime;

  NotificationSettings({
    this.taskReminders = true,
    this.commentNotifications = true,
    this.assignmentNotifications = true,
    this.mentionNotifications = true,
    this.dailyDigest = false,
    this.digestTime = const TimeOfDay(hour: 9, minute: 0),
  });

  NotificationSettings copyWith({
    bool? taskReminders,
    bool? commentNotifications,
    bool? assignmentNotifications,
    bool? mentionNotifications,
    bool? dailyDigest,
    TimeOfDay? digestTime,
  }) {
    return NotificationSettings(
      taskReminders: taskReminders ?? this.taskReminders,
      commentNotifications: commentNotifications ?? this.commentNotifications,
      assignmentNotifications:
          assignmentNotifications ?? this.assignmentNotifications,
      mentionNotifications: mentionNotifications ?? this.mentionNotifications,
      dailyDigest: dailyDigest ?? this.dailyDigest,
      digestTime: digestTime ?? this.digestTime,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  NotificationSettingsNotifier() : super(NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final taskReminders = await _storage.read(key: 'notif_task_reminders');
    final commentNotifications =
        await _storage.read(key: 'notif_comment_notifications');
    final assignmentNotifications =
        await _storage.read(key: 'notif_assignment_notifications');
    final mentionNotifications =
        await _storage.read(key: 'notif_mention_notifications');
    final dailyDigest = await _storage.read(key: 'notif_daily_digest');

    state = NotificationSettings(
      taskReminders: taskReminders != 'false',
      commentNotifications: commentNotifications != 'false',
      assignmentNotifications: assignmentNotifications != 'false',
      mentionNotifications: mentionNotifications != 'false',
      dailyDigest: dailyDigest == 'true',
    );
  }

  Future<void> setTaskReminders(bool value) async {
    await _storage.write(key: 'notif_task_reminders', value: value.toString());
    state = state.copyWith(taskReminders: value);
  }

  Future<void> setCommentNotifications(bool value) async {
    await _storage.write(
        key: 'notif_comment_notifications', value: value.toString());
    state = state.copyWith(commentNotifications: value);
  }

  Future<void> setAssignmentNotifications(bool value) async {
    await _storage.write(
        key: 'notif_assignment_notifications', value: value.toString());
    state = state.copyWith(assignmentNotifications: value);
  }

  Future<void> setMentionNotifications(bool value) async {
    await _storage.write(
        key: 'notif_mention_notifications', value: value.toString());
    state = state.copyWith(mentionNotifications: value);
  }

  Future<void> setDailyDigest(bool value) async {
    await _storage.write(key: 'notif_daily_digest', value: value.toString());
    state = state.copyWith(dailyDigest: value);
  }
}

/// Notification settings screen
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Permission status
          FutureBuilder<List<PendingNotificationRequest>>(
            future: LocalNotificationService.getPendingNotifications(),
            builder: (context, snapshot) {
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  title: const Text('Notification Permissions'),
                  subtitle: Text(
                    snapshot.hasData
                        ? 'Enabled • ${snapshot.data!.length} pending'
                        : 'Check system settings',
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      await LocalNotificationService.requestPermissions();
                    },
                    child: const Text('Enable'),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Task reminders
          const _SectionHeader(title: 'Task Reminders'),
          SwitchListTile(
            title: const Text('Task due date reminders'),
            subtitle: const Text('Get notified before tasks are due'),
            value: settings.taskReminders,
            onChanged: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .setTaskReminders(value);
            },
          ),
          const Divider(),

          // Team notifications
          const _SectionHeader(title: 'Team Activity'),
          SwitchListTile(
            title: const Text('New comments'),
            subtitle: const Text('When someone comments on your tasks'),
            value: settings.commentNotifications,
            onChanged: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .setCommentNotifications(value);
            },
          ),
          SwitchListTile(
            title: const Text('Task assignments'),
            subtitle: const Text('When you\'re assigned a new task'),
            value: settings.assignmentNotifications,
            onChanged: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .setAssignmentNotifications(value);
            },
          ),
          SwitchListTile(
            title: const Text('@Mentions'),
            subtitle: const Text('When someone mentions you'),
            value: settings.mentionNotifications,
            onChanged: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .setMentionNotifications(value);
            },
          ),
          const Divider(),

          // Digest
          const _SectionHeader(title: 'Daily Digest'),
          SwitchListTile(
            title: const Text('Daily summary'),
            subtitle: const Text('Get a daily digest of your tasks'),
            value: settings.dailyDigest,
            onChanged: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .setDailyDigest(value);
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Test notification
          const _SectionHeader(title: 'Test'),
          ListTile(
            leading: const Icon(Icons.notification_add),
            title: const Text('Send test notification'),
            onTap: () async {
              await LocalNotificationService.showNotification(
                id: 999,
                title: 'Test Notification',
                body: 'This is a test notification from TaskFlow!',
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent!'),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Clear all notifications'),
            onTap: () async {
              await LocalNotificationService.cancelAllNotifications();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications cleared!'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        top: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
