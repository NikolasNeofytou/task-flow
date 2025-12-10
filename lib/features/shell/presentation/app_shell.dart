import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/project.dart';
import '../../../core/providers/data_providers.dart';
import '../../../theme/tokens.dart';
import '../../../design_system/widgets/app_scaffold.dart';
import '../../../design_system/widgets/expandable_fab.dart';
import '../../../theme/gradients.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {

  static const _items = <_NavItem>[
    _NavItem(label: 'Chat', icon: Icons.chat_bubble_outline, path: '/chat'),
    _NavItem(label: 'Calendar', icon: Icons.calendar_month_outlined, path: '/calendar'),
    _NavItem(label: 'Projects', icon: Icons.folder_copy_outlined, path: '/projects'),
    _NavItem(label: 'Profile', icon: Icons.person_outline, path: '/profile'),
  ];

  int _locationToIndex(String value) {
    if (value.startsWith('/calendar')) return 1;
    if (value.startsWith('/projects')) return 2;
    if (value.startsWith('/profile')) return 3;
    return 0; // chat default
  }

  void _navigateToIndex(int index) {
    if (index >= 0 && index < _items.length) {
      final target = _items[index];
      if (target.path != widget.location) {
        context.go(target.path);
      }
    }
  }

  void _onHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    
    // Require minimum swipe velocity
    if (velocity.abs() < 500) return;

    final currentIndex = _locationToIndex(widget.location);
    
    if (velocity < 0) {
      // Swipe left - go to next page
      _navigateToIndex(currentIndex + 1);
    } else {
      // Swipe right - go to previous page
      _navigateToIndex(currentIndex - 1);
    }
  }

  void _showProjectSelectionDialog(BuildContext context) async {
    // Import required for dialog
    final projects = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => const _ProjectSelectionDialog(),
    );
    
    if (projects != null && context.mounted) {
      context.push('/projects/$projects/task/new');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _locationToIndex(widget.location);
    final isProjectsScreen = widget.location.startsWith('/projects') && !widget.location.contains('/projects/');
    final isCalendarScreen = widget.location.startsWith('/calendar');

    return AppScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Inbox (requests & notifications)',
                      icon: const Icon(Icons.inbox_outlined),
                      onPressed: () => context.go('/inbox'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: _onHorizontalSwipe,
                  behavior: HitTestBehavior.translucent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (widget, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0, 0.02),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: widget),
                        );
                      },
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: _navigateToIndex,
          destinations: [
            for (final item in _items)
              NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
          ],
        ),
        floatingActionButton: isProjectsScreen
            ? ExpandableFab(
                mainIcon: Icons.add,
                actions: [
                  FabAction(
                    icon: Icons.folder_outlined,
                    label: 'New Project',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('New project creation coming soon')),
                    ),
                  ),
                  FabAction(
                    icon: Icons.task_alt,
                    label: 'Quick Task',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quick task creation coming soon')),
                    ),
                  ),
                  FabAction(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan QR',
                    onTap: () => context.push('/qr-scanner'),
                    color: AppColors.accent,
                  ),
                ],
              )
            : isCalendarScreen
                ? FloatingActionButton(
                    onPressed: () => _showProjectSelectionDialog(context),
                    tooltip: 'Add new task',
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  )
                : null,
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final String path;
}

class _ProjectSelectionDialog extends StatelessWidget {
  const _ProjectSelectionDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: const Icon(
                    Icons.task_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Select Project',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Choose a project to add your new task',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Flexible(
              child: _ProjectList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectList extends ConsumerWidget {
  const _ProjectList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProjects = ref.watch(projectsProvider);

    return asyncProjects.when(
      data: (projects) {
        if (projects.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_off_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No projects available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          itemCount: projects.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final project = projects[index];
            final projectColor = _getProjectColor(project.status);
            
            return InkWell(
              onTap: () => Navigator.of(context).pop(project.id),
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: projectColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Icon(
                        Icons.folder,
                        color: projectColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: projectColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  project.status.name.toUpperCase(),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: projectColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '${project.tasks} tasks',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load projects',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _getProjectColor(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.onTrack:
      return AppColors.success;
    case ProjectStatus.dueSoon:
      return AppColors.warning;
    case ProjectStatus.blocked:
      return AppColors.error;
  }
}
