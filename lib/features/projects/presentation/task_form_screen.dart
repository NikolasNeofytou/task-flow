import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/task_item.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../core/providers/data_providers.dart' show usersProvider;
import '../../../theme/tokens.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({
    super.key,
    required this.projectId,
    this.initialTask,
  });

  final String projectId;
  final TaskItem? initialTask;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  late final TextEditingController _titleController;
  DateTime? _dueDate;
  TaskStatus _status = TaskStatus.pending;
  User? _assignedUser;
  bool _sendAsRequest = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _dueDate = widget.initialTask?.dueDate;
    _status = widget.initialTask?.status ?? TaskStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and due date are required')),
      );
      return;
    }
    if (_saving) return;
    setState(() => _saving = true);
    
    // Create new task
    if (widget.initialTask == null) {
      final newTask = TaskItem(
        id: 'task-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        status: TaskStatus.pending,
        dueDate: _dueDate!,
        projectId: widget.projectId,
        assignedTo: _assignedUser?.id,
      );
      
      // Add task to provider to update calendar
      ref.read(tasksProvider.notifier).addTask(newTask);
    }
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    
    String message;
    if (_assignedUser != null && _sendAsRequest) {
      message = 'Task assignment request sent to ${_assignedUser!.name}';
    } else if (_assignedUser != null) {
      message = 'Task assigned to ${_assignedUser!.name}';
    } else {
      message = widget.initialTask == null ? 'Task created' : 'Task updated';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialTask != null;
    final asyncUsers = ref.watch(usersProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Semantics(
              label: 'Task title',
              textField: true,
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task title'),
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'No date selected'
                        : 'Due: ${_dueDate!.toLocal().toString().split(' ').first}',
                  ),
                ),
                Semantics(
                  label: 'Pick due date',
                  button: true,
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event),
                    label: const Text('Pick date'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              label: 'Task status',
              child: DropdownButtonFormField<TaskStatus>(
                initialValue: _status,
                items: TaskStatus.values
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(_statusLabel(s)),
                      ),
                    )
                    .toList(),
                onChanged: (s) {
                  if (s != null) setState(() => _status = s);
                },
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            
            // Assignee section
            Row(
              children: [
                Icon(Icons.person_add, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Assign to Team Member',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            asyncUsers.when(
              data: (users) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<User>(
                      initialValue: _assignedUser,
                      decoration: InputDecoration(
                        labelText: 'Select assignee',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<User>(
                          value: null,
                          child: Text('None (assign to yourself)'),
                        ),
                        ...users.map((user) => DropdownMenuItem(
                          value: user,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                child: Text(user.name[0]),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                      ],
                      onChanged: (user) {
                        setState(() => _assignedUser = user);
                      },
                    ),
                    if (_assignedUser != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _sendAsRequest ? Icons.mail_outline : Icons.check_circle_outline,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        _sendAsRequest ? 'Send as Request' : 'Direct Assignment',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    _sendAsRequest
                                        ? '${_assignedUser!.name} will receive a request notification and can accept or reject'
                                        : 'Task will be directly assigned to ${_assignedUser!.name}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _sendAsRequest,
                              onChanged: (value) {
                                setState(() => _sendAsRequest = value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Failed to load team members'),
            ),
            
            const Spacer(),
            Semantics(
              button: true,
              label: isEdit ? 'Update Task' : 'Create Task',
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Update Task' : 'Create Task'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
