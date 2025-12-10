import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/project.dart';

/// Smart notification system that analyzes tasks and projects
/// to generate intelligent, context-aware notifications

/// Notification priority levels
enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}

/// Notification type
enum SmartNotificationType {
  taskDueSoon,
  taskOverdue,
  projectDeadline,
  projectBlocked,
  inactiveTask,
  successMilestone,
  teamMention,
  suggestion,
}

/// Smart notification data
class SmartNotification {
  final String id;
  final String title;
  final String message;
  final SmartNotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final VoidCallback? action;
  final IconData icon;
  final Color? color;
  
  const SmartNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    required this.data,
    this.action,
    required this.icon,
    this.color,
  });
}

/// Smart notification generator
class SmartNotificationEngine {
  /// Generate notifications based on tasks
  static List<SmartNotification> analyzeTasksForNotifications(
    List<TaskItem> tasks,
  ) {
    final notifications = <SmartNotification>[];
    final now = DateTime.now();
    
    for (final task in tasks) {
      // Skip completed tasks
      if (task.status == TaskStatus.done) continue;
      
      // Check for overdue tasks
      if (task.dueDate.isBefore(now)) {
        final daysOverdue = now.difference(task.dueDate).inDays;
        notifications.add(SmartNotification(
          id: 'overdue_${task.id}',
          title: 'Task Overdue',
          message: '${task.title} was due $daysOverdue ${daysOverdue == 1 ? 'day' : 'days'} ago',
          type: SmartNotificationType.taskOverdue,
          priority: NotificationPriority.high,
          timestamp: now,
          data: {'taskId': task.id},
          icon: Icons.error_outline,
          color: Colors.red,
        ));
        continue;
      }
      
      // Check for tasks due soon
      final hoursUntilDue = task.dueDate.difference(now).inHours;
      if (hoursUntilDue <= 24 && hoursUntilDue > 0) {
        notifications.add(SmartNotification(
          id: 'due_soon_${task.id}',
          title: 'Task Due Soon',
          message: '${task.title} is due in $hoursUntilDue ${hoursUntilDue == 1 ? 'hour' : 'hours'}',
          type: SmartNotificationType.taskDueSoon,
          priority: hoursUntilDue <= 4 ? NotificationPriority.high : NotificationPriority.medium,
          timestamp: now,
          data: {'taskId': task.id},
          icon: Icons.access_time,
          color: Colors.orange,
        ));
      }
      
      // Check for blocked tasks (inactive for a while)
      if (task.status == TaskStatus.blocked) {
        notifications.add(SmartNotification(
          id: 'blocked_${task.id}',
          title: 'Blocked Task',
          message: '${task.title} is blocked. Consider reassigning or resolving.',
          type: SmartNotificationType.projectBlocked,
          priority: NotificationPriority.medium,
          timestamp: now,
          data: {'taskId': task.id},
          icon: Icons.block,
          color: Colors.red,
        ));
      }
    }
    
    return notifications;
  }
  
  /// Generate notifications based on projects
  static List<SmartNotification> analyzeProjectsForNotifications(
    List<Project> projects,
  ) {
    final notifications = <SmartNotification>[];
    final now = DateTime.now();
    
    for (final project in projects) {
      // Check for blocked projects
      if (project.status == ProjectStatus.blocked) {
        notifications.add(SmartNotification(
          id: 'project_blocked_${project.id}',
          title: 'Project Blocked',
          message: '${project.name} is blocked. Action needed.',
          type: SmartNotificationType.projectBlocked,
          priority: NotificationPriority.high,
          timestamp: now,
          data: {'projectId': project.id},
          icon: Icons.warning_amber,
          color: Colors.orange,
        ));
      }
      
      // Check for projects due soon
      if (project.status == ProjectStatus.dueSoon) {
        notifications.add(SmartNotification(
          id: 'project_due_${project.id}',
          title: 'Project Deadline Approaching',
          message: '${project.name} deadline is approaching',
          type: SmartNotificationType.projectDeadline,
          priority: NotificationPriority.medium,
          timestamp: now,
          data: {'projectId': project.id},
          icon: Icons.calendar_today,
          color: Colors.blue,
        ));
      }
    }
    
    return notifications;
  }
  
  /// Generate smart suggestions
  static List<SmartNotification> generateSuggestions(
    List<TaskItem> tasks,
    List<Project> projects,
  ) {
    final suggestions = <SmartNotification>[];
    final now = DateTime.now();
    
    // Suggest organizing tasks without due dates
    final tasksWithoutDates = tasks.where((t) => 
      t.status != TaskStatus.done && 
      t.dueDate.year == 1970 // Default date
    ).length;
    
    if (tasksWithoutDates > 5) {
      suggestions.add(SmartNotification(
        id: 'suggestion_add_dates',
        title: 'Schedule Your Tasks',
        message: 'You have $tasksWithoutDates tasks without due dates. Add dates to stay organized!',
        type: SmartNotificationType.suggestion,
        priority: NotificationPriority.low,
        timestamp: now,
        data: {'count': tasksWithoutDates},
        icon: Icons.lightbulb_outline,
        color: Colors.amber,
      ));
    }
    
    // Suggest completing stuck pending tasks
    final pendingTasks = tasks.where((t) => t.status == TaskStatus.pending).length;
    if (pendingTasks > 10) {
      suggestions.add(SmartNotification(
        id: 'suggestion_complete_pending',
        title: 'Clear Your Backlog',
        message: 'You have $pendingTasks pending tasks. Focus on completing them!',
        type: SmartNotificationType.suggestion,
        priority: NotificationPriority.low,
        timestamp: now,
        data: {'count': pendingTasks},
        icon: Icons.trending_up,
        color: Colors.green,
      ));
    }
    
    // Suggest archiving completed tasks from old projects
    // (This would need more context about project completion)
    
    return suggestions;
  }
  
  /// Get all notifications sorted by priority
  static List<SmartNotification> getAllNotifications(
    List<TaskItem> tasks,
    List<Project> projects,
  ) {
    final all = <SmartNotification>[
      ...analyzeTasksForNotifications(tasks),
      ...analyzeProjectsForNotifications(projects),
      ...generateSuggestions(tasks, projects),
    ];
    
    // Sort by priority (critical first)
    all.sort((a, b) {
      final priorityOrder = {
        NotificationPriority.critical: 0,
        NotificationPriority.high: 1,
        NotificationPriority.medium: 2,
        NotificationPriority.low: 3,
      };
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });
    
    return all;
  }
}

/// Notification badge counter
class NotificationBadge {
  /// Count notifications by priority
  static Map<NotificationPriority, int> countByPriority(
    List<SmartNotification> notifications,
  ) {
    final counts = <NotificationPriority, int>{
      NotificationPriority.critical: 0,
      NotificationPriority.high: 0,
      NotificationPriority.medium: 0,
      NotificationPriority.low: 0,
    };
    
    for (final notification in notifications) {
      counts[notification.priority] = counts[notification.priority]! + 1;
    }
    
    return counts;
  }
  
  /// Get total count of high-priority notifications
  static int getImportantCount(List<SmartNotification> notifications) {
    return notifications.where((n) =>
      n.priority == NotificationPriority.critical ||
      n.priority == NotificationPriority.high
    ).length;
  }
}
