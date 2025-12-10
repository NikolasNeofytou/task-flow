import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/project.dart';
import '../../../core/models/task_item.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/utils/memoization.dart';
import '../../../core/utils/debouncer.dart';
import '../../../design_system/widgets/app_state.dart';
import '../../../design_system/widgets/skeleton_loader.dart';
import '../../../design_system/widgets/animated_card.dart';
import '../../../design_system/widgets/swipeable_card.dart';
import '../../../design_system/widgets/context_menu.dart';
import '../../../design_system/widgets/custom_refresh_indicator.dart';
import '../../../design_system/animations/hero_transitions.dart';
import '../../../design_system/animations/micro_interactions.dart';
import '../../../theme/tokens.dart';
import '../../../theme/gradients.dart';

enum CalendarViewMode { month, week, day }

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  CalendarViewMode _viewMode = CalendarViewMode.month;
  final _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
  final _filterCache = ListFilterCache<TaskItem>();
  
  // Filter state
  String? _selectedProjectId;
  TaskStatus? _selectedStatus;
  String? _selectedUserId;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedDate = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _goToToday() {
    setState(() {
      final now = DateTime.now();
      _currentMonth = DateTime(now.year, now.month);
      _selectedDate = now;
    });
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _filterCache.clear();
    super.dispose();
  }

  List<TaskItem> _getTasksForDate(List<TaskItem> tasks, DateTime date) {
    return tasks.where((t) =>
      t.dueDate.year == date.year &&
      t.dueDate.month == date.month &&
      t.dueDate.day == date.day
    ).toList();
  }

  List<TaskItem> _getTasksForMonth(List<TaskItem> tasks) {
    return tasks.where((t) =>
      t.dueDate.year == _currentMonth.year &&
      t.dueDate.month == _currentMonth.month
    ).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
  
  List<TaskItem> _applyFilters(List<TaskItem> tasks) {
    var filtered = tasks;
    
    if (_selectedProjectId != null) {
      filtered = filtered.where((t) => t.projectId == _selectedProjectId).toList();
    }
    
    if (_selectedStatus != null) {
      filtered = filtered.where((t) => t.status == _selectedStatus).toList();
    }
    
    if (_selectedUserId != null) {
      filtered = filtered.where((t) => t.assignedTo == _selectedUserId).toList();
    }
    
    return filtered;
  }
  
  void _clearFilters() {
    setState(() {
      _selectedProjectId = null;
      _selectedStatus = null;
      _selectedUserId = null;
    });
  }
  
  bool get _hasActiveFilters => 
    _selectedProjectId != null || _selectedStatus != null || _selectedUserId != null;

  @override
  Widget build(BuildContext context) {
    final asyncTasks = ref.watch(calendarTasksProvider);
    final asyncProjects = ref.watch(projectsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text('Calendar', style: Theme.of(context).textTheme.headlineLarge),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // View mode toggle
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ViewModeButton(
                icon: Icons.calendar_view_month,
                label: 'Month',
                isSelected: _viewMode == CalendarViewMode.month,
                onTap: () => setState(() => _viewMode = CalendarViewMode.month),
              ),
              const SizedBox(width: 4),
              _ViewModeButton(
                icon: Icons.calendar_view_week,
                label: 'Week',
                isSelected: _viewMode == CalendarViewMode.week,
                onTap: () => setState(() => _viewMode = CalendarViewMode.week),
              ),
              const SizedBox(width: 4),
              _ViewModeButton(
                icon: Icons.calendar_today,
                label: 'Day',
                isSelected: _viewMode == CalendarViewMode.day,
                onTap: () => setState(() => _viewMode = CalendarViewMode.day),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Filter bar
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.filter_list, size: 16),
                          const SizedBox(width: 4),
                          Text('Filters${_hasActiveFilters ? " (${[_selectedProjectId, _selectedStatus, _selectedUserId].where((e) => e != null).length})" : ""}'),
                        ],
                      ),
                      selected: _showFilters,
                      onSelected: (selected) => setState(() => _showFilters = selected),
                    ),
                    if (_hasActiveFilters) ...[
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('Clear'),
                        avatar: const Icon(Icons.clear, size: 16),
                        onPressed: _clearFilters,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // Filter options (expandable)
        if (_showFilters) ...[
          const SizedBox(height: AppSpacing.sm),
          asyncProjects.when(
            data: (projects) {
              final asyncUsers = ref.watch(usersProvider);
              return asyncUsers.when(
                data: (users) => Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter by:',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Project filter
                          ...projects.map((project) => FilterChip(
                            label: Text(project.name),
                            selected: _selectedProjectId == project.id,
                            onSelected: (selected) {
                              setState(() {
                                _selectedProjectId = selected ? project.id : null;
                              });
                            },
                          )),
                          // Status filter
                          ...TaskStatus.values.map((status) => FilterChip(
                            label: Text(_statusLabel(status)),
                            avatar: Icon(
                              _statusIcon(status),
                              size: 16,
                              color: _selectedStatus == status 
                                ? Theme.of(context).colorScheme.onSecondaryContainer
                                : null,
                            ),
                            selected: _selectedStatus == status,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = selected ? status : null;
                              });
                            },
                          )),
                          // User filter
                          ...users.map((user) => FilterChip(
                            label: Text(user.name),
                            avatar: CircleAvatar(
                              radius: 10,
                              child: Text(
                                user.name[0],
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            selected: _selectedUserId == user.id,
                            onSelected: (selected) {
                              setState(() {
                                _selectedUserId = selected ? user.id : null;
                              });
                            },
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        
        // Month navigation
        Row(
          children: [
            IconButton(
              onPressed: _previousMonth,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous ${_viewMode == CalendarViewMode.month ? "month" : _viewMode == CalendarViewMode.week ? "week" : "day"}',
            ),
            Expanded(
              child: Center(
                child: Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _nextMonth,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next month',
            ),
            const SizedBox(width: AppSpacing.sm),
            PressableScale(
              onTap: _goToToday,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  boxShadow: AppShadows.soft,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.today, color: Colors.white, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                    const Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Calendar view based on mode
        asyncTasks.when(
          data: (tasks) {
            final filteredTasks = _applyFilters(tasks);
            return asyncProjects.when(
              data: (projects) {
                return CustomRefreshIndicator(
                  onRefresh: () async {
                    // Refresh calendar data
                    ref.invalidate(calendarTasksProvider);
                    ref.invalidate(projectsProvider);
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _viewMode == CalendarViewMode.month
                        ? _CalendarGrid(
                            currentMonth: _currentMonth,
                            selectedDate: _selectedDate,
                            tasks: filteredTasks,
                            projects: projects,
                            onDateSelected: (date) {
                              setState(() {
                                _selectedDate = date;
                              });
                            },
                          )
                        : _viewMode == CalendarViewMode.week
                            ? _WeekView(
                                currentWeek: _selectedDate ?? DateTime.now(),
                                selectedDate: _selectedDate,
                                tasks: filteredTasks,
                                projects: projects,
                                onDateSelected: (date) {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                },
                              )
                            : _DayView(
                                selectedDate: _selectedDate ?? DateTime.now(),
                                tasks: filteredTasks,
                                projects: projects,
                              ),
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 300,
                child: CalendarGridSkeleton(),
              ),
              error: (err, _) => SizedBox(
                height: 300,
                child: AppStateView.error(message: 'Failed to load calendar'),
              ),
            );
          },
          loading: () => const SizedBox(
            height: 300,
            child: CalendarGridSkeleton(),
          ),
          error: (err, _) => SizedBox(
            height: 300,
            child: AppStateView.error(message: 'Failed to load calendar'),
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.md),
        
        // Selected date tasks
        Expanded(
          child: asyncTasks.when(
            data: (tasks) {
              final filteredTasks = _applyFilters(tasks);
              if (_selectedDate == null) {
                return const AppStateView.empty(
                  message: 'Select a date to view tasks',
                );
              }
              
              final dayTasks = _getTasksForDate(filteredTasks, _selectedDate!);
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tasks for ${DateFormat('EEEE, MMMM d').format(_selectedDate!)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (dayTasks.isEmpty)
                    const Expanded(
                      child: AppStateView.empty(
                        message: 'No tasks on this date',
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: dayTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = dayTasks[index];
                          final color = _statusColor(item.status);
                          return SwipeableCard(
                            onComplete: () {
                              // Mark task as complete
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('"${item.title}" marked as complete')),
                              );
                            },
                            onDelete: () {
                              // Delete task
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('"${item.title}" deleted')),
                              );
                            },
                            child: ContextMenuRegion(
                              items: [
                                ContextMenuItem(
                                  value: 'edit',
                                  icon: Icons.edit,
                                  label: 'Edit Task',
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
                                    if (item.projectId != null) {
                                      context.go('/projects/${item.projectId}/task/${item.id}/edit');
                                    }
                                    break;
                                  case 'share':
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Share functionality coming soon')),
                                    );
                                    break;
                                  case 'duplicate':
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Duplicated "${item.title}"')),
                                    );
                                    break;
                                  case 'delete':
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Deleted "${item.title}"')),
                                    );
                                    break;
                                }
                              },
                              child: TaskCardHero(
                                tag: 'task_${item.id}',
                                child: _CalendarItem(
                              title: item.title,
                              color: color,
                              status: item.status,
                              onTap: item.projectId == null
                                  ? null
                                  : () => context.go(
                                        '/projects/${item.projectId}/task/${item.id}',
                                        extra: item,
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
            loading: () => ListView.separated(
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, __) => const TaskCardSkeleton(),
            ),
            error: (err, _) => AppStateView.error(message: 'Failed to load tasks: $err'),
          ),
        ),
      ],
    );
  }
}

// Calendar Grid Widget
class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.currentMonth,
    required this.selectedDate,
    required this.tasks,
    required this.projects,
    required this.onDateSelected,
  });

  final DateTime currentMonth;
  final DateTime? selectedDate;
  final List<TaskItem> tasks;
  final List<Project> projects;
  final Function(DateTime) onDateSelected;

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    
    final days = <DateTime>[];
    
    // Add padding days from previous month
    final weekdayOfFirst = firstDay.weekday % 7; // 0 = Sunday, 1 = Monday, etc.
    for (int i = weekdayOfFirst - 1; i >= 0; i--) {
      days.add(firstDay.subtract(Duration(days: i + 1)));
    }
    
    // Add all days of current month
    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(currentMonth.year, currentMonth.month, day));
    }
    
    // Add padding days from next month to complete the grid
    final remainingCells = (7 - (days.length % 7)) % 7;
    for (int i = 1; i <= remainingCells; i++) {
      days.add(lastDay.add(Duration(days: i)));
    }
    
    return days;
  }

  int _getTaskCountForDate(DateTime date) {
    return tasks.where((t) =>
      t.dueDate.year == date.year &&
      t.dueDate.month == date.month &&
      t.dueDate.day == date.day
    ).length;
  }

  List<Project> _getProjectsForDate(DateTime date) {
    return projects.where((p) {
      if (p.deadline == null) return false;
      return p.deadline!.year == date.year &&
             p.deadline!.month == date.month &&
             p.deadline!.day == date.day;
    }).toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    if (selectedDate == null) return false;
    return date.year == selectedDate!.year &&
           date.month == selectedDate!.month &&
           date.day == selectedDate!.day;
  }

  bool _isCurrentMonth(DateTime date) {
    return date.month == currentMonth.month && date.year == currentMonth.year;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = _getDaysInMonth();
    
    return Column(
      children: [
        // Weekday headers
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final date = days[index];
            final isToday = _isToday(date);
            final isSelected = _isSelected(date);
            final isCurrentMonth = _isCurrentMonth(date);
            final dayTasks = tasks.where((t) =>
              t.dueDate.year == date.year &&
              t.dueDate.month == date.month &&
              t.dueDate.day == date.day
            ).toList();
            final projectDeadlines = _getProjectsForDate(date);
            
            return _CalendarDay(
              date: date,
              isToday: isToday,
              isSelected: isSelected,
              isCurrentMonth: isCurrentMonth,
              tasks: dayTasks,
              projectDeadlines: projectDeadlines,
              onTap: () => onDateSelected(date),
            );
          },
        ),
      ],
    );
  }
}

// Calendar Day Cell Widget
class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isCurrentMonth,
    required this.tasks,
    required this.projectDeadlines,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isCurrentMonth;
  final List<TaskItem> tasks;
  final List<Project> projectDeadlines;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color? backgroundColor;
    Color? textColor;
    
    if (isSelected) {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (isToday) {
      backgroundColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
    }
    
    if (!isCurrentMonth) {
      textColor = colorScheme.onSurfaceVariant.withOpacity(0.4);
    }
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            // Status indicators and project deadlines
            if (tasks.isNotEmpty || projectDeadlines.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Color-coded status dots
                  if (tasks.isNotEmpty) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Group tasks by status and show colored dots
                        if (tasks.any((t) => t.status == TaskStatus.done))
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? colorScheme.onPrimary : AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (tasks.any((t) => t.status == TaskStatus.pending))
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? colorScheme.onPrimary : AppColors.info,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (tasks.any((t) => t.status == TaskStatus.blocked))
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? colorScheme.onPrimary : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        // Task count badge
                        const SizedBox(width: 2),
                        Text(
                          '${tasks.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: textColor ?? colorScheme.onSurface,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (projectDeadlines.isNotEmpty) const SizedBox(width: 4),
                  ],
                  // Project deadline flag
                  if (projectDeadlines.isNotEmpty) ...[
                    Tooltip(
                      message: projectDeadlines.map((p) => p.name).join(', '),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          gradient: AppGradients.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? colorScheme.onPrimary : Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.flag,
                          size: 8,
                          color: isSelected ? colorScheme.onPrimary : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CalendarItem extends StatelessWidget {
  const _CalendarItem({
    required this.title,
    required this.color,
    required this.status,
    this.onTap,
  });

  final String title;
  final Color color;
  final TaskStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withOpacity(0.18),
        colorScheme.surfaceContainerHighest.withOpacity(0.9),
      ],
    );

    return AnimatedCard(
      backgroundGradient: gradient,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.75),
                  color.withOpacity(0.5),
                ],
              ),
            ),
            child: Icon(
              status == TaskStatus.done ? Icons.check_circle : Icons.event_available,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    decoration: status == TaskStatus.done
                        ? TextDecoration.lineThrough
                        : null,
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
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.name.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right, color: AppColors.neutral),
        ],
      ),
    );
  }
}

Color _statusColor(TaskStatus status) {
  return StatusColorCache.getColor(status);
}

String _statusLabel(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return 'Pending';
    case TaskStatus.done:
      return 'Done';
    case TaskStatus.blocked:
      return 'Blocked';
  }
}

IconData _statusIcon(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return Icons.schedule;
    case TaskStatus.done:
      return Icons.check_circle;
    case TaskStatus.blocked:
      return Icons.block;
  }
}

class _ViewModeButton extends StatelessWidget {
  const _ViewModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? AppGradients.primary : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.currentWeek,
    required this.selectedDate,
    required this.tasks,
    required this.projects,
    required this.onDateSelected,
  });

  final DateTime currentWeek;
  final DateTime? selectedDate;
  final List<TaskItem> tasks;
  final List<Project> projects;
  final Function(DateTime) onDateSelected;

  List<DateTime> _getWeekDays(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday % 7));
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  List<TaskItem> _getTasksForDate(DateTime date) {
    return tasks.where((t) =>
      t.dueDate.year == date.year &&
      t.dueDate.month == date.month &&
      t.dueDate.day == date.day
    ).toList();
  }

  List<Project> _getProjectsForDate(DateTime date) {
    return projects.where((p) {
      if (p.deadline == null) return false;
      return p.deadline!.year == date.year &&
             p.deadline!.month == date.month &&
             p.deadline!.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays(currentWeek);
    final today = DateTime.now();
    
    return Column(
      children: [
        // Week days header
        Row(
          children: weekDays.map((day) {
            final isToday = day.year == today.year &&
                day.month == today.month &&
                day.day == today.day;
            final isSelected = selectedDate != null &&
                day.year == selectedDate!.year &&
                day.month == selectedDate!.month &&
                day.day == selectedDate!.day;
            final dayTasks = _getTasksForDate(day);
            final dayProjects = _getProjectsForDate(day);
            
            return Expanded(
              child: GestureDetector(
                onTap: () => onDateSelected(day),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? AppGradients.primary
                        : isToday
                            ? LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.2),
                                  AppColors.primary.withOpacity(0.1),
                                ],
                              )
                            : null,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(
                      color: isToday
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(day),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      if (dayTasks.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.3)
                                : AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${dayTasks.length}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Selected day's tasks
        if (selectedDate != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat('EEEE, MMMM d').format(selectedDate!),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...(_getTasksForDate(selectedDate!).map((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _CalendarItem(
                title: task.title,
                color: _statusColor(task.status),
                status: task.status,
                onTap: () => context.push('/projects/${task.projectId}/task/${task.id}'),
              ),
            );
          }).toList()),
          if (_getTasksForDate(selectedDate!).isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: AppStateView.empty(
                  message: 'No tasks scheduled',
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView({
    required this.selectedDate,
    required this.tasks,
    required this.projects,
  });

  final DateTime selectedDate;
  final List<TaskItem> tasks;
  final List<Project> projects;

  List<TaskItem> _getTasksForDate() {
    return tasks.where((t) =>
      t.dueDate.year == selectedDate.year &&
      t.dueDate.month == selectedDate.month &&
      t.dueDate.day == selectedDate.day
    ).toList();
  }

  List<Project> _getProjectsForDate() {
    return projects.where((p) {
      if (p.deadline == null) return false;
      return p.deadline!.year == selectedDate.year &&
             p.deadline!.month == selectedDate.month &&
             p.deadline!.day == selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dayTasks = _getTasksForDate();
    final dayProjects = _getProjectsForDate();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(selectedDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM d, yyyy').format(selectedDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  '${dayTasks.length} ${dayTasks.length == 1 ? 'task' : 'tasks'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Project deadlines
        if (dayProjects.isNotEmpty) ...[
          Text(
            'Project Deadlines',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...dayProjects.map((project) {
            Color projectColor;
            switch (project.status) {
              case ProjectStatus.onTrack:
                projectColor = AppColors.success;
                break;
              case ProjectStatus.dueSoon:
                projectColor = AppColors.warning;
                break;
              case ProjectStatus.blocked:
                projectColor = AppColors.error;
                break;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AnimatedCard(
                backgroundGradient: LinearGradient(
                  colors: [
                    projectColor.withOpacity(0.15),
                    Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.9),
                  ],
                ),
                onTap: () => context.push('/projects/${project.id}'),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            projectColor.withOpacity(0.75),
                            projectColor.withOpacity(0.5),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Deadline Today',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: projectColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
        ],
        
        // Tasks list
        if (dayTasks.isEmpty && dayProjects.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: AppStateView.empty(
                message: 'No tasks scheduled for this day',
              ),
            ),
          )
        else
          ...dayTasks.map((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _CalendarItem(
                title: task.title,
                color: _statusColor(task.status),
                status: task.status,
                onTap: () => context.push('/projects/${task.projectId}/task/${task.id}'),
              ),
            );
          }).toList(),
      ],
    );
  }
}
