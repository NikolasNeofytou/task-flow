import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/project.dart';

/// Batch operations system for multi-select and bulk actions
/// Enables efficient operations on multiple items simultaneously

/// Batch operation type
enum BatchOperationType {
  delete,
  archive,
  complete,
  updateStatus,
  assignTo,
  updateDueDate,
  addTags,
  removeTags,
  move,
  duplicate,
}

/// Batch operation result
class BatchOperationResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;
  final Duration executionTime;
  
  const BatchOperationResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
    required this.executionTime,
  });
  
  bool get hasErrors => failureCount > 0;
  bool get isSuccess => failureCount == 0;
  int get totalCount => successCount + failureCount;
}

/// Batch operation executor
class BatchOperationExecutor {
  /// Execute batch operation on tasks
  static Future<BatchOperationResult> executeBatchOnTasks({
    required List<TaskItem> tasks,
    required BatchOperationType operation,
    Map<String, dynamic>? parameters,
    void Function(int completed, int total)? onProgress,
  }) async {
    final startTime = DateTime.now();
    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];
    
    for (var i = 0; i < tasks.length; i++) {
      try {
        switch (operation) {
          case BatchOperationType.delete:
            // Simulate delete operation
            await Future.delayed(const Duration(milliseconds: 50));
            successCount++;
            break;
            
          case BatchOperationType.complete:
            // Simulate complete operation
            await Future.delayed(const Duration(milliseconds: 50));
            successCount++;
            break;
            
          case BatchOperationType.updateStatus:
            final newStatus = parameters?['status'] as TaskStatus?;
            if (newStatus != null) {
              // Simulate status update
              await Future.delayed(const Duration(milliseconds: 50));
              successCount++;
            } else {
              failureCount++;
              errors.add('Task ${tasks[i].id}: Missing status parameter');
            }
            break;
            
          case BatchOperationType.updateDueDate:
            final newDate = parameters?['dueDate'] as DateTime?;
            if (newDate != null) {
              // Simulate due date update
              await Future.delayed(const Duration(milliseconds: 50));
              successCount++;
            } else {
              failureCount++;
              errors.add('Task ${tasks[i].id}: Missing due date parameter');
            }
            break;
            
          case BatchOperationType.addTags:
            final tags = parameters?['tags'] as List<String>?;
            if (tags != null && tags.isNotEmpty) {
              // Simulate tag addition
              await Future.delayed(const Duration(milliseconds: 50));
              successCount++;
            } else {
              failureCount++;
              errors.add('Task ${tasks[i].id}: Missing tags parameter');
            }
            break;
            
          default:
            failureCount++;
            errors.add('Task ${tasks[i].id}: Operation not implemented');
        }
      } catch (e) {
        failureCount++;
        errors.add('Task ${tasks[i].id}: ${e.toString()}');
      }
      
      // Report progress
      onProgress?.call(i + 1, tasks.length);
    }
    
    final executionTime = DateTime.now().difference(startTime);
    
    return BatchOperationResult(
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
      executionTime: executionTime,
    );
  }
  
  /// Execute batch operation on projects
  static Future<BatchOperationResult> executeBatchOnProjects({
    required List<Project> projects,
    required BatchOperationType operation,
    Map<String, dynamic>? parameters,
    void Function(int completed, int total)? onProgress,
  }) async {
    final startTime = DateTime.now();
    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];
    
    for (var i = 0; i < projects.length; i++) {
      try {
        switch (operation) {
          case BatchOperationType.delete:
            // Simulate delete operation
            await Future.delayed(const Duration(milliseconds: 50));
            successCount++;
            break;
            
          case BatchOperationType.archive:
            // Simulate archive operation
            await Future.delayed(const Duration(milliseconds: 50));
            successCount++;
            break;
            
          case BatchOperationType.updateStatus:
            final newStatus = parameters?['status'] as ProjectStatus?;
            if (newStatus != null) {
              // Simulate status update
              await Future.delayed(const Duration(milliseconds: 50));
              successCount++;
            } else {
              failureCount++;
              errors.add('Project ${projects[i].id}: Missing status parameter');
            }
            break;
            
          default:
            failureCount++;
            errors.add('Project ${projects[i].id}: Operation not implemented');
        }
      } catch (e) {
        failureCount++;
        errors.add('Project ${projects[i].id}: ${e.toString()}');
      }
      
      // Report progress
      onProgress?.call(i + 1, projects.length);
    }
    
    final executionTime = DateTime.now().difference(startTime);
    
    return BatchOperationResult(
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
      executionTime: executionTime,
    );
  }
}

/// Multi-select controller for managing selection state
class MultiSelectController<T> extends ChangeNotifier {
  final Set<T> _selectedItems = {};
  bool _selectionMode = false;
  
  /// Check if item is selected
  bool isSelected(T item) => _selectedItems.contains(item);
  
  /// Toggle item selection
  void toggle(T item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
    } else {
      _selectedItems.add(item);
    }
    
    // Exit selection mode if nothing selected
    if (_selectedItems.isEmpty) {
      _selectionMode = false;
    }
    
    notifyListeners();
  }
  
  /// Select item
  void select(T item) {
    _selectedItems.add(item);
    _selectionMode = true;
    notifyListeners();
  }
  
  /// Deselect item
  void deselect(T item) {
    _selectedItems.remove(item);
    if (_selectedItems.isEmpty) {
      _selectionMode = false;
    }
    notifyListeners();
  }
  
  /// Select all items
  void selectAll(List<T> items) {
    _selectedItems.addAll(items);
    _selectionMode = true;
    notifyListeners();
  }
  
  /// Clear selection
  void clearSelection() {
    _selectedItems.clear();
    _selectionMode = false;
    notifyListeners();
  }
  
  /// Toggle selection mode
  void toggleSelectionMode() {
    _selectionMode = !_selectionMode;
    if (!_selectionMode) {
      _selectedItems.clear();
    }
    notifyListeners();
  }
  
  /// Get selected items
  List<T> get selectedItems => _selectedItems.toList();
  
  /// Get selection count
  int get selectedCount => _selectedItems.length;
  
  /// Check if in selection mode
  bool get isSelectionMode => _selectionMode;
  
  /// Check if any items selected
  bool get hasSelection => _selectedItems.isNotEmpty;
  
  @override
  void dispose() {
    _selectedItems.clear();
    super.dispose();
  }
}

/// Batch action bar widget
class BatchActionBar extends StatelessWidget {
  final int selectedCount;
  final List<BatchAction> actions;
  final VoidCallback onCancel;
  
  const BatchActionBar({
    super.key,
    required this.selectedCount,
    required this.actions,
    required this.onCancel,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onCancel,
              ),
              const SizedBox(width: 8),
              Text(
                '$selectedCount selected',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              ...actions.map((action) => IconButton(
                icon: Icon(action.icon),
                tooltip: action.label,
                onPressed: action.onPressed,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Batch action definition
class BatchAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  
  const BatchAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

/// Batch operation progress dialog
class BatchOperationProgressDialog extends StatelessWidget {
  final String title;
  final int completed;
  final int total;
  
  const BatchOperationProgressDialog({
    super.key,
    required this.title,
    required this.completed,
    required this.total,
  });
  
  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text('Processing $completed of $total items...'),
        ],
      ),
    );
  }
  
  /// Show progress dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required Future<BatchOperationResult> Function(
      void Function(int completed, int total) onProgress
    ) operation,
  }) async {
    int completed = 0;
    int total = 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BatchOperationProgressDialog(
        title: title,
        completed: completed,
        total: total,
      ),
    );
    
    try {
      final result = await operation((c, t) {
        completed = c;
        total = t;
      });
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close progress dialog
        
        // Show result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isSuccess
                  ? 'Successfully processed ${result.successCount} items'
                  : 'Completed with ${result.failureCount} errors',
            ),
            backgroundColor: result.isSuccess ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
