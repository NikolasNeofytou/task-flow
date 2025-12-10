import '../../data/mock_data.dart';
import '../../models/app_notification.dart';
import '../../models/comment.dart';
import '../../models/project.dart';
import '../../models/request.dart';
import '../../models/task_item.dart';
import '../calendar_repository.dart';
import '../comments_repository.dart';
import '../notifications_repository.dart';
import '../projects_repository.dart';
import '../requests_repository.dart';

class MockRequestsRepository implements RequestsRepository {
  MockRequestsRepository()
      : _data = [
          Request(
            id: 'req-1',
            title: 'Member X asked you to take task Y',
            status: RequestStatus.pending,
            createdAt: DateTime(2025, 8, 15),
          ),
          Request(
            id: 'req-2',
            title: 'You want to take task X from member Y',
            status: RequestStatus.pending,
            createdAt: DateTime(2025, 8, 16),
          ),
          Request(
            id: 'req-3',
            title: 'Member Z accepted your request',
            status: RequestStatus.accepted,
            createdAt: DateTime(2025, 8, 17),
          ),
        ];

  List<Request> _data;

  @override
  Future<List<Request>> fetchRequests() async => _data;

  @override
  Future<void> acceptRequest(String id) async {
    _data = _data
        .map((r) => r.id == id
            ? Request(
                id: r.id,
                title: r.title,
                status: RequestStatus.accepted,
                createdAt: r.createdAt,
              )
            : r)
        .toList();
  }

  @override
  Future<void> rejectRequest(String id) async {
    _data = _data
        .map((r) => r.id == id
            ? Request(
                id: r.id,
                title: r.title,
                status: RequestStatus.rejected,
                createdAt: r.createdAt,
              )
            : r)
        .toList();
  }

  @override
  Future<Request> createRequest({
    required String title,
    DateTime? dueDate,
  }) async {
    final newRequest = Request(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      status: RequestStatus.sent,
      createdAt: DateTime.now(),
    );
    _data = [newRequest, ..._data];
    return newRequest;
  }
}

class MockNotificationsRepository implements NotificationsRepository {
  @override
  Future<List<AppNotification>> fetchNotifications() =>
      MockDataSource.fetchNotifications();
}

class MockProjectsRepository implements ProjectsRepository {
  @override
  Future<List<Project>> fetchProjects() => MockDataSource.fetchProjects();

  @override
  Future<List<TaskItem>> fetchProjectTasks(String projectId) =>
      MockDataSource.fetchProjectTasks(projectId);
}

class MockCalendarRepository implements CalendarRepository {
  @override
  Future<List<TaskItem>> fetchCalendarTasks() =>
      MockDataSource.fetchCalendarTasks();
}

class MockCommentsRepository implements CommentsRepository {
  @override
  Future<List<Comment>> fetchComments(String taskId) =>
      MockDataSource.fetchComments(taskId);

  @override
  Future<Comment> addComment({
    required String taskId,
    required String content,
  }) =>
      MockDataSource.addComment(taskId: taskId, content: content);
}
