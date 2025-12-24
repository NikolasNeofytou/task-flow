import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../../../theme/gradients.dart';

/// Empty state widget with illustration and action
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Gradient? gradient;
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.gradient,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: gradient ?? AppGradients.primary,
                shape: BoxShape.circle,
                boxShadow: AppShadows.level2,
              ),
              child: Icon(
                icon,
                size: 80,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            
            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
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

/// Predefined empty states
class EmptyStates {
  static Widget noTasks({VoidCallback? onCreateTask}) {
    return EmptyState(
      icon: Icons.task_alt,
      title: 'No Tasks Yet',
      description: 'Your task list is empty. Create your first task to get started with organizing your work.',
      actionLabel: 'Create Task',
      onAction: onCreateTask,
      gradient: AppGradients.primary,
    );
  }
  
  static Widget noProjects({VoidCallback? onCreateProject}) {
    return EmptyState(
      icon: Icons.folder_open,
      title: 'No Projects',
      description: 'You haven\'t created any projects yet. Start organizing your tasks into projects.',
      actionLabel: 'Create Project',
      onAction: onCreateProject,
      gradient: AppGradients.success,
    );
  }
  
  static Widget noRequests() {
    return EmptyState(
      icon: Icons.inbox,
      title: 'No Requests',
      description: 'You\'re all caught up! No pending change requests at the moment.',
      gradient: AppGradients.info,
    );
  }
  
  static Widget noNotifications() {
    return EmptyState(
      icon: Icons.notifications_none,
      title: 'No Notifications',
      description: 'You\'re all up to date. New notifications will appear here.',
      gradient: AppGradients.warning,
    );
  }
  
  static Widget noComments({VoidCallback? onAddComment}) {
    return EmptyState(
      icon: Icons.comment,
      title: 'No Comments',
      description: 'Be the first to comment on this task. Share your thoughts and collaborate with your team.',
      actionLabel: 'Add Comment',
      onAction: onAddComment,
      gradient: AppGradients.primary,
    );
  }
  
  static Widget searchNoResults(String query) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results',
      description: 'We couldn\'t find anything matching "$query". Try different keywords or filters.',
      gradient: AppGradients.surface,
    );
  }
  
  static Widget error({
    required String title,
    required String description,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      icon: Icons.error_outline,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      gradient: AppGradients.error,
    );
  }
  
  static Widget offline({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'You\'re Offline',
      description: 'Please check your internet connection and try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
      gradient: AppGradients.warning,
    );
  }
}

/// Loading state with animated indicator
class LoadingState extends StatelessWidget {
  final String? message;
  
  const LoadingState({
    super.key,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer loading placeholder
class ShimmerLoadingState extends StatelessWidget {
  final int itemCount;
  
  const ShimmerLoadingState({
    super.key,
    this.itemCount = 5,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 200,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
