import 'package:flutter/material.dart';

/// Empty state widget with illustration and action button
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? color;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: themeColor,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specific empty state widgets for different screens

class EmptyProjectsWidget extends StatelessWidget {
  final VoidCallback? onCreateProject;

  const EmptyProjectsWidget({
    super.key,
    this.onCreateProject,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.folder_open,
      title: 'No Projects Yet',
      message:
          'Create your first project to get started with organizing your tasks',
      actionLabel: 'Create Project',
      onAction: onCreateProject,
      color: Colors.blue,
    );
  }
}

class EmptyTasksWidget extends StatelessWidget {
  final VoidCallback? onCreateTask;

  const EmptyTasksWidget({
    super.key,
    this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.task_alt,
      title: 'No Tasks',
      message: 'Add tasks to track your work and stay organized',
      actionLabel: 'Add Task',
      onAction: onCreateTask,
      color: Colors.green,
    );
  }
}

class EmptyRequestsWidget extends StatelessWidget {
  const EmptyRequestsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.inbox,
      title: 'No Requests',
      message: 'You\'re all caught up! No pending requests at the moment',
      color: Colors.orange,
    );
  }
}

class EmptyNotificationsWidget extends StatelessWidget {
  const EmptyNotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.notifications_none,
      title: 'No Notifications',
      message:
          'You\'re all caught up! We\'ll notify you when something important happens',
      color: Colors.purple,
    );
  }
}

class EmptySearchWidget extends StatelessWidget {
  final String searchQuery;

  const EmptySearchWidget({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      message:
          'We couldn\'t find anything matching "$searchQuery".\nTry different keywords',
      color: Colors.grey,
    );
  }
}

class EmptyMessagesWidget extends StatelessWidget {
  final VoidCallback? onSendMessage;

  const EmptyMessagesWidget({
    super.key,
    this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.chat_bubble_outline,
      title: 'No Messages Yet',
      message: 'Start the conversation by sending your first message',
      actionLabel: 'Send Message',
      onAction: onSendMessage,
      color: Colors.teal,
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'Connection Error',
      message:
          'Unable to connect to the server.\nPlease check your internet connection',
      actionLabel: 'Retry',
      onAction: onRetry,
      color: Colors.red,
    );
  }
}
