/// Unit tests for model validation and serialization
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/models/task.dart';
import 'package:taskflow/core/models/project.dart';
import 'package:taskflow/core/models/user.dart';
import '../../helpers/mock_data.dart';

void main() {
  group('TaskItem Model', () {
    test('creates valid task from mock data', () {
      // Arrange & Act
      final task = MockTasks.openTask;

      // Assert
      expect(task.id, isNotEmpty);
      expect(task.title, isNotEmpty);
      expect(task.status, TaskStatus.todo);
      expect(task.priority, TaskPriority.high);
    });

    test('task with past due date is overdue', () {
      // Arrange
      final task = MockTasks.overdueTask;

      // Act
      final isOverdue = task.dueDate?.isBefore(DateTime.now()) ?? false;

      // Assert
      expect(isOverdue, true);
    });

    test('task status can be changed', () {
      // Arrange
      final task = MockTasks.openTask;

      // Act
      final updatedTask = task.copyWith(status: TaskStatus.done);

      // Assert
      expect(updatedTask.status, TaskStatus.done);
      expect(task.status, TaskStatus.todo); // Original unchanged
    });

    test('task priority levels are ordered correctly', () {
      // Assert
      expect(TaskPriority.high.index > TaskPriority.medium.index, true);
      expect(TaskPriority.medium.index > TaskPriority.low.index, true);
    });

    test('task can have multiple assignees', () {
      // Arrange
      final task = MockTasks.openTask;

      // Act
      final assignees = task.assignedTo ?? [];

      // Assert
      expect(assignees, isNotEmpty);
      expect(assignees, isA<List<String>>());
    });
  });

  group('Project Model', () {
    test('creates valid project from mock data', () {
      // Arrange & Act
      final project = MockProjects.testProject;

      // Assert
      expect(project.id, isNotEmpty);
      expect(project.name, isNotEmpty);
      expect(project.ownerId, isNotEmpty);
    });

    test('project can have multiple members', () {
      // Arrange
      final project = MockProjects.testProject;

      // Act
      final members = project.members;

      // Assert
      expect(members, isNotEmpty);
      expect(members.length, greaterThan(1));
    });

    test('project has valid color code', () {
      // Arrange
      final project = MockProjects.testProject;

      // Assert
      expect(project.color, startsWith('#'));
      expect(project.color.length, 7); // #RRGGBB
    });

    test('project owner is included in members', () {
      // Arrange
      final project = MockProjects.testProject;

      // Assert
      expect(project.members.contains(project.ownerId), true);
    });

    test('project updates timestamp correctly', () {
      // Arrange
      final project = MockProjects.testProject;
      final originalUpdate = project.updatedAt;

      // Act
      final updatedProject = project.copyWith(
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(
        updatedProject.updatedAt.isAfter(originalUpdate),
        true,
      );
    });
  });

  group('User Model', () {
    test('creates valid user from mock data', () {
      // Arrange & Act
      final user = MockUsers.testUser;

      // Assert
      expect(user.id, isNotEmpty);
      expect(user.name, isNotEmpty);
      expect(user.email, contains('@'));
    });

    test('user email is valid format', () {
      // Arrange
      final users = MockUsers.allUsers;

      // Act & Assert
      for (final user in users) {
        expect(user.email, contains('@'));
        expect(user.email, contains('.'));
      }
    });

    test('user can have optional avatar', () {
      // Arrange
      final user = MockUsers.testUser;

      // Assert
      expect(user.avatar, isNull);
      // Avatar is optional, can be null or URL
    });

    test('user has creation timestamp', () {
      // Arrange
      final user = MockUsers.testUser;

      // Assert
      expect(user.createdAt, isA<DateTime>());
      expect(user.createdAt.isBefore(DateTime.now()), true);
    });
  });

  group('Model Relationships', () {
    test('task references valid project', () {
      // Arrange
      final task = MockTasks.openTask;
      final project = MockProjects.testProject;

      // Assert
      expect(task.projectId, project.id);
    });

    test('task references valid user', () {
      // Arrange
      final task = MockTasks.openTask;
      final user = MockUsers.testUser;

      // Assert
      expect(task.createdBy, user.id);
    });

    test('project members are valid users', () {
      // Arrange
      final project = MockProjects.testProject;
      final allUserIds = MockUsers.allUsers.map((u) => u.id).toList();

      // Assert
      for (final memberId in project.members) {
        expect(allUserIds.contains(memberId), true);
      }
    });
  });

  group('Model Serialization', () {
    test('task can be converted to JSON and back', () {
      // Arrange
      final task = MockTasks.openTask;

      // Act
      final json = task.toJson();
      final reconstructed = TaskItem.fromJson(json);

      // Assert
      expect(reconstructed.id, task.id);
      expect(reconstructed.title, task.title);
      expect(reconstructed.status, task.status);
    });

    test('project can be converted to JSON and back', () {
      // Arrange
      final project = MockProjects.testProject;

      // Act
      final json = project.toJson();
      final reconstructed = Project.fromJson(json);

      // Assert
      expect(reconstructed.id, project.id);
      expect(reconstructed.name, project.name);
      expect(reconstructed.members, project.members);
    });

    test('user can be converted to JSON and back', () {
      // Arrange
      final user = MockUsers.testUser;

      // Act
      final json = user.toJson();
      final reconstructed = User.fromJson(json);

      // Assert
      expect(reconstructed.id, user.id);
      expect(reconstructed.name, user.name);
      expect(reconstructed.email, user.email);
    });
  });
}
