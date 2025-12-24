import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/project.dart';
import '../../../core/models/task_item.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/utils/memoization.dart';
import '../../../core/utils/debouncer.dart';
import '../../../design_system/widgets/animated_card.dart';
import '../../../design_system/widgets/app_pill.dart';
import '../../../design_system/widgets/app_state.dart';
import '../../../design_system/widgets/skeleton_loader.dart';
import '../../../design_system/widgets/context_menu.dart';
import '../../../design_system/widgets/app_snackbar.dart';
import '../../../design_system/widgets/app_bottom_sheet.dart';
import '../../../theme/tokens.dart';

/// Projects overview with board + roadmap sections.
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final _searchCtrl = TextEditingController();
  final _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
  
  // Filter state
  ProjectStatus? _selectedStatus;
  String? _selectedTeamMember;
  bool _showOverdueOnly = false;
  bool _showFilters = false;
  
  // Sort state
  String _sortBy = 'status'; // status, deadline, progress, name

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }
  
  bool get _hasActiveFilters =>
      _selectedStatus != null || _selectedTeamMember != null || _showOverdueOnly;

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedTeamMember = null;
      _showOverdueOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncProjects = ref.watch(projectsProvider);
    final asyncTasks = ref.watch(calendarTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  'Projects overview',
                  style: Theme.of(context).textTheme.headlineLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            IconButton(
              tooltip: 'Add project',
              onPressed: () {
                _showAddProjectDialog(context);
              },
              icon: const Icon(Icons.add_box_outlined),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Filters(
          searchCtrl: _searchCtrl,
          onQueryChanged: () => setState(() {}),
          showFilters: _showFilters,
          onToggleFilters: () => setState(() => _showFilters = !_showFilters),
          hasActiveFilters: _hasActiveFilters,
          sortBy: _sortBy,
          onSortChanged: (value) => setState(() => _sortBy = value),
        ),
        if (_showFilters) ...[
          const SizedBox(height: AppSpacing.md),
          _FilterPanel(
            selectedStatus: _selectedStatus,
            selectedTeamMember: _selectedTeamMember,
            showOverdueOnly: _showOverdueOnly,
            onStatusChanged: (status) => setState(() => _selectedStatus = status),
            onTeamMemberChanged: (userId) => setState(() => _selectedTeamMember = userId),
            onOverdueChanged: (value) => setState(() => _showOverdueOnly = value),
            onClear: _clearFilters,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatsRow(asyncProjects: asyncProjects, asyncTasks: asyncTasks),
                const SizedBox(height: AppSpacing.xl),
                _BoardView(
                  searchCtrl: _searchCtrl,
                  onQueryChanged: () => setState(() {}),
                  selectedStatus: _selectedStatus,
                  selectedTeamMember: _selectedTeamMember,
                  showOverdueOnly: _showOverdueOnly,
                  sortBy: _sortBy,
                ),
                const SizedBox(height: AppSpacing.xl),
                _RoadmapList(asyncTasks: asyncTasks),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.searchCtrl,
    required this.onQueryChanged,
    required this.showFilters,
    required this.onToggleFilters,
    required this.hasActiveFilters,
    required this.sortBy,
    required this.onSortChanged,
  });

  final TextEditingController searchCtrl;
  final VoidCallback onQueryChanged;
  final bool showFilters;
  final VoidCallback onToggleFilters;
  final bool hasActiveFilters;
  final String sortBy;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Filter by keyword or status…',
            ),
            onChanged: (_) => onQueryChanged(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FilterChip(
          label: Text('Filters${hasActiveFilters ? ' (${hasActiveFilters ? "•" : ""})' : ''}'),
          avatar: Icon(
            showFilters ? Icons.expand_less : Icons.expand_more,
            size: 18,
          ),
          selected: showFilters,
          onSelected: (_) => onToggleFilters(),
        ),
        const SizedBox(width: AppSpacing.sm),
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          tooltip: 'Sort by',
          initialValue: sortBy,
          onSelected: onSortChanged,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'status', child: Text('Sort by Status')),
            const PopupMenuItem(value: 'deadline', child: Text('Sort by Deadline')),
            const PopupMenuItem(value: 'progress', child: Text('Sort by Progress')),
            const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
          ],
        ),
      ],
    );
  }
}

class _FilterPanel extends ConsumerWidget {
  const _FilterPanel({
    required this.selectedStatus,
    required this.selectedTeamMember,
    required this.showOverdueOnly,
    required this.onStatusChanged,
    required this.onTeamMemberChanged,
    required this.onOverdueChanged,
    required this.onClear,
  });

  final ProjectStatus? selectedStatus;
  final String? selectedTeamMember;
  final bool showOverdueOnly;
  final ValueChanged<ProjectStatus?> onStatusChanged;
  final ValueChanged<String?> onTeamMemberChanged;
  final ValueChanged<bool> onOverdueChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = ref.watch(usersProvider);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Projects',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear all'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Status', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              FilterChip(
                label: const Text('On Track'),
                selected: selectedStatus == ProjectStatus.onTrack,
                onSelected: (selected) =>
                    onStatusChanged(selected ? ProjectStatus.onTrack : null),
              ),
              FilterChip(
                label: const Text('Due Soon'),
                selected: selectedStatus == ProjectStatus.dueSoon,
                onSelected: (selected) =>
                    onStatusChanged(selected ? ProjectStatus.dueSoon : null),
              ),
              FilterChip(
                label: const Text('Blocked'),
                selected: selectedStatus == ProjectStatus.blocked,
                onSelected: (selected) =>
                    onStatusChanged(selected ? ProjectStatus.blocked : null),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Team Members', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          asyncUsers.when(
            data: (users) => Wrap(
              spacing: AppSpacing.sm,
              children: users.map((user) {
                return FilterChip(
                  label: Text(user.name.split(' ')[0]),
                  avatar: CircleAvatar(
                    radius: 12,
                    child: Text(
                      user.name[0],
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  selected: selectedTeamMember == user.id,
                  onSelected: (selected) =>
                      onTeamMemberChanged(selected ? user.id : null),
                );
              }).toList(),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Failed to load team members'),
          ),
          const SizedBox(height: AppSpacing.md),
          CheckboxListTile(
            title: const Text('Show overdue only'),
            value: showOverdueOnly,
            onChanged: (value) => onOverdueChanged(value ?? false),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.asyncProjects, required this.asyncTasks});

  final AsyncValue<List<Project>> asyncProjects;
  final AsyncValue<List<TaskItem>> asyncTasks;

  @override
  Widget build(BuildContext context) {
    final projectData = asyncProjects.asData?.value ?? const <Project>[];
    final taskData = asyncTasks.asData?.value ?? const <TaskItem>[];
    final onTrack = projectData.where((p) => p.status == ProjectStatus.onTrack).length;
    final dueSoon = projectData.where((p) => p.status == ProjectStatus.dueSoon).length;
    final blocked = projectData.where((p) => p.status == ProjectStatus.blocked).length;
    final upcoming = taskData.length;

    Widget stat(String label, String value, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        stat('Projects', '${projectData.length}', Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        stat('On track', '$onTrack', AppColors.success),
        const SizedBox(width: AppSpacing.md),
        stat('Due soon', '$dueSoon', AppColors.warning),
        const SizedBox(width: AppSpacing.md),
        stat('Blocked', '$blocked', AppColors.error),
        const SizedBox(width: AppSpacing.md),
        stat('Upcoming tasks', '$upcoming', Theme.of(context).colorScheme.tertiary),
      ],
    );
  }
}

class _BoardView extends ConsumerWidget {
  const _BoardView({
    required this.searchCtrl,
    required this.onQueryChanged,
    required this.selectedStatus,
    required this.selectedTeamMember,
    required this.showOverdueOnly,
    required this.sortBy,
  });

  final TextEditingController searchCtrl;
  final VoidCallback onQueryChanged;
  final ProjectStatus? selectedStatus;
  final String? selectedTeamMember;
  final bool showOverdueOnly;
  final String sortBy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProjects = ref.watch(projectsProvider);
    return asyncProjects.when(
      data: (projects) {
        if (projects.isEmpty) {
          return const AppStateView.empty(message: 'No projects yet.');
        }
        
        // Apply filters
        var filtered = projects;
        
        final query = searchCtrl.text.trim().toLowerCase();
        if (query.isNotEmpty) {
          filtered = filtered.where((p) => p.name.toLowerCase().contains(query)).toList();
        }
        
        if (selectedStatus != null) {
          filtered = filtered.where((p) => p.status == selectedStatus).toList();
        }
        
        if (selectedTeamMember != null) {
          filtered = filtered.where((p) => p.teamMembers.contains(selectedTeamMember)).toList();
        }
        
        if (showOverdueOnly) {
          final now = DateTime.now();
          filtered = filtered.where((p) {
            if (p.deadline == null) return false;
            return p.deadline!.isBefore(now);
          }).toList();
        }
        
        // Apply sorting
        filtered = _sortProjects(filtered, sortBy);
        
        final grouped = _groupByStatus(filtered);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ProjectStatus.values.map((status) {
            final list = grouped[status] ?? [];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _StatusColumn(
                status: status,
                projects: list,
              ),
            );
          }).toList(),
        );
      },
      loading: () => ListView.separated(
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, __) => const ProjectCardSkeleton(),
      ),
      error: (err, _) => AppStateView.error(message: 'Failed to load projects: $err'),
    );
  }

  List<Project> _sortProjects(List<Project> projects, String sortBy) {
    final sorted = [...projects];
    switch (sortBy) {
      case 'deadline':
        sorted.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        break;
      case 'progress':
        sorted.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'status':
      default:
        sorted.sort((a, b) => a.status.index.compareTo(b.status.index));
        break;
    }
    return sorted;
  }

  Map<ProjectStatus, List<Project>> _groupByStatus(List<Project> items) {
    final map = <ProjectStatus, List<Project>>{};
    for (final project in items) {
      map.putIfAbsent(project.status, () => []).add(project);
    }
    return map;
  }
}

class _StatusColumn extends StatelessWidget {
  const _StatusColumn({required this.status, required this.projects});

  final ProjectStatus status;
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              status == ProjectStatus.blocked
                  ? Icons.block
                  : status == ProjectStatus.dueSoon
                      ? Icons.schedule
                      : Icons.check_circle_outline,
              color: color,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _statusLabel(status),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppPill(label: '${projects.length}', color: color),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (projects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.inbox_outlined, color: color.withOpacity(0.5)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'No ${_statusLabel(status).toLowerCase()} projects yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final project in projects) ...[
            _ProjectCard(project: project, statusColor: color),
            const SizedBox(height: AppSpacing.sm),
          ],
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Add new ${_statusLabel(status).toLowerCase()} project'),
                action: SnackBarAction(
                  label: 'Create',
                  onPressed: () {
                    _showAddProjectDialog(context, defaultStatus: status);
                  },
                ),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add item'),
        ),
      ],
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  const _ProjectCard({
    required this.project,
    required this.statusColor,
  });

  final Project project;
  final Color statusColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = ref.watch(usersProvider);
    final now = DateTime.now();
    final isOverdue = project.deadline != null && project.deadline!.isBefore(now);
    final daysUntilDeadline = project.deadline?.difference(now).inDays;
    
    return ContextMenuRegion(
      items: const [
        ContextMenuItem(
          value: 'edit',
          icon: Icons.edit,
          label: 'Edit Project',
        ),
        ContextMenuItem(
          value: 'share',
          icon: Icons.share,
          label: 'Share',
        ),
        ContextMenuItem(
          value: 'duplicate',
          icon: Icons.copy,
          label: 'Duplicate',
        ),
        ContextMenuItem(
          value: 'archive',
          icon: Icons.archive,
          label: 'Archive',
        ),
        ContextMenuItem(
          value: 'delete',
          icon: Icons.delete,
          label: 'Delete',
          color: AppColors.error,
          destructive: true,
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            AppSnackbar.show(
              context,
              message: 'Edit "${project.name}"',
              type: SnackbarType.info,
            );
            break;
          case 'share':
            AppSnackbar.show(
              context,
              message: 'Share functionality coming soon',
              type: SnackbarType.info,
            );
            break;
          case 'duplicate':
            AppSnackbar.show(
              context,
              message: 'Duplicated "${project.name}"',
              type: SnackbarType.success,
            );
            break;
          case 'archive':
            AppSnackbar.show(
              context,
              message: 'Archived "${project.name}"',
              type: SnackbarType.success,
            );
            break;
          case 'delete':
            AppBottomSheet.showConfirmation(
              context: context,
              title: 'Delete Project?',
              message: 'Are you sure you want to delete "${project.name}"? This action cannot be undone.',
              confirmLabel: 'Delete',
              isDestructive: true,
            ).then((confirmed) {
              if (confirmed == true) {
                AppSnackbar.show(
                  context,
                  message: 'Deleted "${project.name}"',
                  type: SnackbarType.error,
                );
              }
            });
            break;
        }
      },
      child: Hero(
        tag: 'project-${project.id}',
        child: Material(
          color: Colors.transparent,
          child: AnimatedCard(
            onTap: () => context.go('/projects/${project.id}', extra: project),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.drag_indicator, color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, size: 14, color: AppColors.error),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'OVERDUE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  )
                else if (daysUntilDeadline != null && daysUntilDeadline <= 7)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 14, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '$daysUntilDeadline days',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${project.completedTasks}/${project.tasks} tasks',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      '${(project.progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: LinearProgressIndicator(
                    value: project.progress,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      AppPill(label: _statusLabel(project.status), color: statusColor),
                    ],
                  ),
                ),
                // Team member avatars
                asyncUsers.when(
                  data: (users) {
                    final teamMembers = users
                        .where((u) => project.teamMembers.contains(u.id))
                        .toList();
                    if (teamMembers.isEmpty) return const SizedBox.shrink();
                    
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < teamMembers.length && i < 3; i++)
                          Padding(
                            padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                            child: Tooltip(
                              message: teamMembers[i].name,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  teamMembers[i].name[0],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (teamMembers.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Text(
                                '+${teamMembers.length - 3}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  ),
              ],
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}

class _RoadmapList extends StatelessWidget {
  const _RoadmapList({required this.asyncTasks});

  final AsyncValue<List<TaskItem>> asyncTasks;

  @override
  Widget build(BuildContext context) {
    return asyncTasks.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const AppStateView.empty(message: 'No tasks on the roadmap.');
        }
        final sorted = [...tasks]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        final upcoming = sorted.take(8).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Roadmap (next)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcoming.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final t = upcoming[index];
                final color = _taskStatusColor(t.status);
                final dateLabel = '${t.dueDate.month}/${t.dueDate.day}';
                return AnimatedCard(
                  onTap: () => context.go('/projects/${t.projectId}/task/${t.id}', extra: t),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              t.projectId ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                      AppPill(label: dateLabel, color: color),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => ListView.separated(
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, __) => const TaskCardSkeleton(),
      ),
      error: (err, _) => AppStateView.error(message: 'Failed to load roadmap: $err'),
    );
  }
}

String _statusLabel(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.onTrack:
      return 'On track';
    case ProjectStatus.dueSoon:
      return 'Due soon';
    case ProjectStatus.blocked:
      return 'Blocked';
  }
}

Color _statusColor(ProjectStatus status) {
  return ProjectStatusColorCache.getColor(status.name);
}

Color _taskStatusColor(TaskStatus status) {
  return StatusColorCache.getColor(status);
}

void _showAddProjectDialog(BuildContext context, {ProjectStatus? defaultStatus}) {
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Create New Project'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'Enter project name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a project name';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Status: ${defaultStatus != null ? _statusLabel(defaultStatus) : "On Track"}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Project "${nameController.text}" created'),
                  action: SnackBarAction(
                    label: 'View',
                    onPressed: () {},
                  ),
                ),
              );
            }
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}
