import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/data_providers.dart';
import '../../../design_system/widgets/app_scaffold.dart';
import '../../../theme/gradients.dart';
import '../../../theme/tokens.dart';

const String kMeUserId = 'me';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _items = <_NavItem>[
    _NavItem(label: 'Chat', icon: Icons.chat_bubble_outline, path: '/chat'),
    _NavItem(label: 'Calendar', icon: Icons.calendar_month_outlined, path: '/calendar'),
    _NavItem(label: 'Projects', icon: Icons.folder_copy_outlined, path: '/projects'),
    _NavItem(label:'Requests', icon: Icons.outgoing_mail, path: '/requests'),
    _NavItem(label: 'Profile', icon: Icons.person_outline, path: '/profile'),
  
  ];

  int _locationToIndex(String location) {
    if (location.startsWith('/chat')) return 0;
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/projects')) return 2;
    if (location.startsWith('/profile')) return 4;
    if (location.startsWith('/requests')) return 3;
    return 2;
  }

  int _prevIndex = 2;

  void _navigateToIndex(int index) {
    if (index < 0 || index >= _items.length) return;

    final target = _items[index];
    final currentIndex = _locationToIndex(widget.location);
    if (target.path == widget.location) return;

    setState(() => _prevIndex = currentIndex);
    context.go(target.path);
  }

  void _onHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 500) return;

    final currentIndex = _locationToIndex(widget.location);

    // δεξί swipe -> πάει μπροστά (next tab)
    // αριστερό swipe -> πάει πίσω (previous tab)
    if (velocity > 0) {
      _navigateToIndex(currentIndex + 1);
    } else {
      _navigateToIndex(currentIndex - 1);
    }
  }

  Offset _slideBeginForTransition(int newIndex) {
    final goingForward = newIndex > _prevIndex;
    return goingForward ? const Offset(0.15, 0) : const Offset(-0.15, 0);
  }

  Future<void> _openNewProjectDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => const _NewProjectDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _locationToIndex(widget.location);

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
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        final begin = _slideBeginForTransition(selectedIndex);
                        final slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(animation);

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<String>(_items[selectedIndex].path),
                        child: widget.child,
                      ),
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
        floatingActionButton: selectedIndex == 2
            ? FloatingActionButton(
                onPressed: _openNewProjectDialog,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppGradients.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Icon(Icons.add, color: Colors.white)),
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

class _NewProjectDialog extends ConsumerStatefulWidget {
  const _NewProjectDialog();

  @override
  ConsumerState<_NewProjectDialog> createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends ConsumerState<_NewProjectDialog> {
  final _nameCtrl = TextEditingController();
  DateTime? _deadline;
  String _assigneeId = kMeUserId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
      initialDate: _deadline ?? DateTime(now.year, now.month, now.day),
    );

    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final teamMembers = <String>[_assigneeId];

    final notifier = ref.read(projectsProvider.notifier);

    try {
      await (notifier as dynamic).addProject(
        name: name,
        deadline: _deadline,
        teamMembers: teamMembers,
      );
    } catch (_) {
      try {
        await (notifier as dynamic).addProject(name, _deadline);
      } catch (_) {
        await (notifier as dynamic).createProject(
          name: name,
          deadline: _deadline,
          teamMembers: teamMembers,
        );
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: const Icon(Icons.folder_outlined, color: Colors.white),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'New Project',
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

              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Project name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              usersAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => const Text('Failed to load team members'),
                data: (users) {
                  final others = users.where((u) => u.id != kMeUserId).toList();

                  final items = <DropdownMenuItem<String>>[
                    const DropdownMenuItem<String>(
                      value: kMeUserId,
                      child: Text('Me'),
                    ),
                    ...others.map(
                      (u) => DropdownMenuItem<String>(
                        value: u.id,
                        child: Text(u.name),
                      ),
                    ),
                  ];

                  final validValues = items.map((e) => e.value).toSet();
                  final value = validValues.contains(_assigneeId) ? _assigneeId : kMeUserId;

                  return DropdownButtonFormField<String>(
                    value: value,
                    decoration: InputDecoration(
                      labelText: 'Assign to',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                    ),
                    items: items,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _assigneeId = v);
                    },
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDeadline,
                      icon: const Icon(Icons.event_outlined),
                      label: Text(
                        _deadline == null
                            ? 'Pick deadline'
                            : 'Deadline: ${_deadline!.toLocal().toString().split(' ').first}',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _create,
                      child: const Text('Create'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}