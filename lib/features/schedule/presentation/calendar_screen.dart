import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/models/project.dart';
import '../../../core/providers/data_providers.dart';
import '../../../theme/tokens.dart';
import '../../../core/utils/project_status_utils.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Normalize to date-only (00:00)
  DateTime _d(DateTime x) => DateTime(x.year, x.month, x.day);

  @override
  Widget build(BuildContext context) {
    final asyncProjects = ref.watch(projectsProvider);

    return asyncProjects.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (e, _) => Center(child: Text('Failed to load projects: $e')),
      data: (projects) {
        // Map deadlines -> list of projects that are due that day
        final Map<DateTime, List<Project>> dueMap = {};
        for (final p in projects) {
          final dl = p.deadline;
          if (dl == null) continue;
          final day = _d(dl.toLocal());
          (dueMap[day] ??= []).add(p);
        }

        // TableCalendar "events" map needs a LinkedHashMap with custom equals/hash
        final events = LinkedHashMap<DateTime, List<Project>>(
          equals: isSameDay,
          hashCode: _getHashCode,
        )..addAll(dueMap);

        List<Project> getEventsForDay(DateTime day) => events[_d(day)] ?? const [];

        final selected = _selectedDay ?? _focusedDay;
        final selectedEvents = getEventsForDay(selected);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendar',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Deadlines are marked on the calendar.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: TableCalendar<Project>(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                    // Swipes between months
                    availableGestures: AvailableGestures.horizontalSwipe,

                    // Make cells taller so project names fit
                    rowHeight: 72,

                    // Feed events (projects) per day
                    eventLoader: getEventsForDay,

                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },

                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      leftChevronIcon: const Icon(Icons.chevron_left),
                      rightChevronIcon: const Icon(Icons.chevron_right),
                      titleTextStyle: Theme.of(context).textTheme.titleMedium!,
                    ),

                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: true,
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(color: Colors.white),
                    ),

                    // Show project name(s) inside the day cell
                    calendarBuilders: CalendarBuilders<Project>(
                      markerBuilder: (context, day, projectsForDay) {
  if (projectsForDay.isEmpty) return const SizedBox.shrink();

  final shown = projectsForDay.take(2).toList();
  final extra = projectsForDay.length - shown.length;

  return Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in shown)
            Builder(
              builder: (context) {
                final s = effectiveProjectStatus(p);
                final c = projectStatusColor(s);

                return Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.withOpacity(0.35)),
                  ),
                  child: Text(
                    '${p.name} (${projectStatusLabel(s)})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                );
              },
            ),
          if (extra > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '+$extra',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    ),
  );
},

                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // List of projects due on selected day
              Text(
                _selectedDay == null
                    ? 'Select a day to see deadlines'
                    : 'Deadlines on ${_d(selected).toIso8601String().split("T").first}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),

              if (selectedEvents.isEmpty)
                Text(
                  'No project deadlines on this day.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                )
              else
                Column(
                  children: [
                    for (final p in selectedEvents)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: ListTile(
                          title: Text(p.name),
                          
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go('/projects/${p.id}', extra: p),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

int _getHashCode(DateTime key) => key.day * 1000000 + key.month * 10000 + key.year;

String _statusLabel(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.onTrack:
      return 'On track';
    case ProjectStatus.dueSoon:
      return 'Due soon';
    case ProjectStatus.blocked:
      return 'Blocked';
      case ProjectStatus.done:
      return 'done';  

  }
}
