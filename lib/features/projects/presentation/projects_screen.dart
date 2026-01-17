import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/project.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/utils/project_status_utils.dart';
import '../../../design_system/widgets/animated_card.dart';
import '../../../design_system/widgets/app_pill.dart';
import '../../../design_system/widgets/app_state.dart';
import '../../../theme/tokens.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final _searchCtrl = TextEditingController();
  ProjectStatus? _status;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openEditDeadlineDialog(BuildContext context, Project p) async {
    DateTime? temp = p.deadline;

    final result = await showDialog<_DeadlineResult>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> pick() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: ctx,
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 5),
                initialDate: temp ?? DateTime(now.year, now.month, now.day),
              );
              if (picked != null) setLocal(() => temp = picked);
            }

            return AlertDialog(
              title: const Text('Edit deadline'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    temp == null
                        ? 'No deadline'
                        : 'Deadline: ${temp!.toLocal().toString().split(' ').first}',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: pick,
                    icon: const Icon(Icons.event_outlined),
                    label: const Text('Pick date'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: () => setLocal(() => temp = null),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear deadline'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(_DeadlineResult.cancel()),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(_DeadlineResult.save(temp)),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result.isCancel) return;

    await ref.read(projectsProvider.notifier).updateDeadline(
          p.id,
          result.deadline,
        );
  }

  Future<void> _askForHelp({
    required BuildContext context,
    required Project project,
    required List<User> users,
  }) async {
    final others = users.where((u) => u.id != kMeUserId).toList();
    if (others.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No teammates available')),
      );
      return;
    }

    String selectedUserId = others.first.id;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: const Text('Ask for help'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedUserId,
                decoration: const InputDecoration(labelText: 'Send to'),
                items: [
                  for (final u in others)
                    DropdownMenuItem<String>(
                      value: u.id,
                      child: Text(u.name),
                    ),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setLocal(() => selectedUserId = v);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Send request'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;

    ref.read(projectRequestsProvider.notifier).send(
          projectId: project.id,
          toUserId: selectedUserId,
        );

    if (!context.mounted) return;

    final toName = others.firstWhere((u) => u.id == selectedUserId).name;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request sent to $toName')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncProjects = ref.watch(projectsProvider);
    final asyncUsers = ref.watch(usersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Projects', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.md),

        TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Search projects…',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
          ),
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: AppSpacing.md),

        Wrap(
          spacing: AppSpacing.sm,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: _status == null,
              onSelected: (_) => setState(() => _status = null),
            ),
            ChoiceChip(
              label: const Text('On Track'),
              selected: _status == ProjectStatus.onTrack,
              onSelected: (_) => setState(() => _status = ProjectStatus.onTrack),
            ),
            ChoiceChip(
              label: const Text('Due Soon'),
              selected: _status == ProjectStatus.dueSoon,
              onSelected: (_) => setState(() => _status = ProjectStatus.dueSoon),
            ),
            ChoiceChip(
              label: const Text('Blocked'),
              selected: _status == ProjectStatus.blocked,
              onSelected: (_) => setState(() => _status = ProjectStatus.blocked),
            ),
            ChoiceChip(
              label: const Text('Done'),
              selected: _status == ProjectStatus.done,
              onSelected: (_) => setState(() => _status = ProjectStatus.done),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        Expanded(
          child: asyncProjects.when(
            loading: () => const Center(child: CircularProgressIndicator.adaptive()),
            error: (e, _) => Center(child: Text('Failed to load projects: $e')),
            data: (projects) {
              final q = _searchCtrl.text.trim().toLowerCase();

              final filtered = projects.where((p) {
                final matchQuery = q.isEmpty || p.name.toLowerCase().contains(q);
                final s = effectiveProjectStatus(p);
                final matchStatus = _status == null || s == _status;
                return matchQuery && matchStatus;
              }).toList();

              filtered.sort((a, b) {
                final ad = a.deadline;
                final bd = b.deadline;
                if (ad == null && bd == null) return a.name.compareTo(b.name);
                if (ad == null) return 1;
                if (bd == null) return -1;
                return ad.compareTo(bd);
              });

              if (filtered.isEmpty) {
                return const AppStateView.empty(message: 'No projects found.');
              }

              return asyncUsers.when(
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                error: (e, _) => Center(child: Text('Failed to load team members: $e')),
                data: (users) {
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_,__) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final p = filtered[index];

                      final s = effectiveProjectStatus(p);
                      final statusColor = projectStatusColor(s);

                      final deadlineText = p.deadline == null
                          ? 'No deadline'
                          : 'Deadline: ${p.deadline!.toLocal().toString().split(' ').first}';

                      final team = users.where((u) => p.teamMembers.contains(u.id)).toList();

                      final assigneeId = p.teamMembers.isNotEmpty ? p.teamMembers.first : '';
                      final isMine = assigneeId == kMeUserId;

                      return AnimatedCard(
                        onTap: () => context.go('/projects/${p.id}', extra: p),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),

                                  // Edit deadline
                                  IconButton(
                                    tooltip: 'Edit deadline',
                                    icon: const Icon(Icons.edit_calendar_outlined),
                                    onPressed: () => _openEditDeadlineDialog(context, p),
                                  ),

                                  //  Ask for help 
                                  if (isMine && s != ProjectStatus.done)
                                    IconButton(
                                      tooltip: 'Ask for help',
                                      icon: const Icon(Icons.pan_tool_alt_outlined),
                                      onPressed: () => _askForHelp(
                                        context: context,
                                        project: p,
                                        users: users,
                                      ),
                                    ),

                                  //  Done
                                  if (s != ProjectStatus.done)
                                    IconButton(
                                      tooltip: 'Mark as done',
                                      icon: const Icon(Icons.check_circle_outline),
                                      onPressed: () => ref.read(projectsProvider.notifier).markDone(p.id),
                                    ),

                                  AppPill(label: projectStatusLabel(s), color: statusColor),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              Text(
                                deadlineText,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),

                              if (team.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.md),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (final u in team.take(6))
                                      Chip(
                                        label: Text(u.name.split(' ').first),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    if (team.length > 6)
                                      Chip(
                                        label: Text('+${team.length - 6}'),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DeadlineResult {
  const _DeadlineResult._(this.deadline, this.isCancel);

  final DateTime? deadline;
  final bool isCancel;

  factory _DeadlineResult.cancel() => const _DeadlineResult._(null, true);
  factory _DeadlineResult.save(DateTime? deadline) => _DeadlineResult._(deadline, false);
}