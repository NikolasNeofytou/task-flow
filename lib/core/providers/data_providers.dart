import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../models/app_notification.dart';
import '../models/project.dart';
import '../models/request.dart';
import '../models/task_item.dart';
import '../models/user.dart';
import '../network/api_client.dart';
import '../repositories/calendar_repository.dart';
import '../repositories/comments_repository.dart';
import '../repositories/mock/mock_repositories.dart';
import '../repositories/notifications_repository.dart';
import '../repositories/projects_repository.dart';
import '../repositories/remote/calendar_remote_repository.dart';
import '../repositories/remote/comments_remote_repository.dart';
import '../repositories/remote/notifications_remote_repository.dart';
import '../repositories/remote/projects_remote_repository.dart';
import '../repositories/remote/requests_remote_repository.dart';
import '../repositories/requests_repository.dart';
import '../data/mock_data.dart';

enum ProjectRequestStatus { pending, accepted, denied }

class ProjectRequest {
  const ProjectRequest({
    required this.id,
    required this.projectId,
    required this.fromUserId,
    required this.toUserId,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String projectId;
  final String fromUserId;
  final String toUserId;
  final DateTime createdAt;
  final ProjectRequestStatus status;

  ProjectRequest copyWith({
    String? id,
    String? projectId,
    String? fromUserId,
    String? toUserId,
    DateTime? createdAt,
    ProjectRequestStatus? status,
  }) {
    return ProjectRequest(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
// Repository providers (mock vs remote selection)
final requestsRepositoryProvider = Provider<RequestsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMocks) return MockRequestsRepository();
  final dio = ref.watch(dioProvider);
  return RequestsRemoteRepository(dio);
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMocks) return MockNotificationsRepository();
  final dio = ref.watch(dioProvider);
  return NotificationsRemoteRepository(dio);
});

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMocks) return MockProjectsRepository();
  final dio = ref.watch(dioProvider);
  return ProjectsRemoteRepository(dio);
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMocks) return MockCalendarRepository();
  final dio = ref.watch(dioProvider);
  return CalendarRemoteRepository(dio);
});

final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMocks) return MockCommentsRepository();
  final dio = ref.watch(dioProvider);
  return CommentsRemoteRepository(dio);
});

// Data providers using repositories with autoDispose for better memory management
final requestsProvider = FutureProvider.autoDispose<List<Request>>(
  (ref) => ref.read(requestsRepositoryProvider).fetchRequests(),
);

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>(
  (ref) => ref.read(notificationsRepositoryProvider).fetchNotifications(),
);

final projectsProvider =
    AsyncNotifierProvider<ProjectsController, List<Project>>(ProjectsController.new);
final userCreatedProjectIdsProvider =
    StateNotifierProvider<UserCreatedProjectIdsController, Set<String>>(
  (ref) => UserCreatedProjectIdsController(),
);

class UserCreatedProjectIdsController extends StateNotifier<Set<String>> {
  UserCreatedProjectIdsController() : super(<String>{});

  void add(String projectId) => state = {...state, projectId};

  void remove(String projectId) {
    final next = {...state};
    next.remove(projectId);
    state = next;
  }

  void clear() => state = <String>{};
}
class ProjectsController extends AsyncNotifier<List<Project>> {
@override
Future<List<Project>> build() async {
  final existing = state.valueOrNull;
  if (existing != null && existing.isNotEmpty) return existing;

  final now = DateTime.now();

  return [
  Project(
    id: 'demo_p1',
    name: 'Website Redesign Sprint',
    deadline: now.add(const Duration(days: 3)),
    teamMembers: const ['u2'], // Bob
    tasks: 8,
    status: ProjectStatus.dueSoon,
  ),
  Project(
    id: 'demo_p2',
    name: 'Backend API Update',
    deadline: now.add(const Duration(days: 10)),
    teamMembers: const [kMeUserId], // Me
    tasks: 12,
    status: ProjectStatus.onTrack,
  ),
  Project(
    id: 'demo_p3',
    name: 'UX Audit Sprint',
    deadline: now.add(const Duration(days: 1)),
    teamMembers: const ['u3'], // Carol
    tasks: 5,
    status: ProjectStatus.blocked,
  ),

  Project(
    id: 'demo_p4',
    name: 'Design System Cleanup',
    deadline: now.add(const Duration(days: 7)),
    teamMembers: const ['u1'], // Alice
    tasks: 6,
    status: ProjectStatus.onTrack,
  ),
  Project(
    id: 'demo_p5',
    name: 'Database Migration Plan',
    deadline: now.add(const Duration(days: 5)),
    teamMembers: const ['u4'], // David
    tasks: 4,
    status: ProjectStatus.dueSoon,
  ),
  Project(
    id: 'demo_p6',
    name: 'Landing Page Copy Refresh',
    deadline: now.add(const Duration(days: 14)),
    teamMembers: const ['u2'], // Bob
    tasks: 3,
    status: ProjectStatus.onTrack,
  ),
  Project(
    id: 'demo_p7',
    name: 'User Interviews Round 1',
    deadline: now.add(const Duration(days: 9)),
    teamMembers: const ['u1'], // Alice
    tasks: 5,
    status: ProjectStatus.onTrack,
  ),
  Project(
    id: 'demo_p8',
    name: 'Bug Triage & Fixes',
    deadline: now.add(const Duration(days: 2)),
    teamMembers: const ['u3'], // Carol
    tasks: 10,
    status: ProjectStatus.dueSoon,
  ),
];

}
Future<void> addProject({
  required String name,
  DateTime? deadline,
  List<String> teamMembers = const [],
}) async {
  final current = state.value ?? const <Project>[];

  final newProject = Project(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: name.trim().isEmpty ? 'Untitled' : name.trim(),
    deadline: deadline,
    teamMembers: teamMembers,
    tasks: 0,
    status: ProjectStatus.onTrack,
  );

  state = AsyncData([...current, newProject]);
  ref.read(userCreatedProjectIdsProvider.notifier).add(newProject.id);
}

Future<void> markDone(String projectId) async {
  final current = state.value ?? [];

  final updated = [
    for (final p in current)
      if (p.id == projectId)
        p.copyWith(status: ProjectStatus.done)
      else
        p,
  ];

  state = AsyncValue.data(updated);

  //  timestamp (badges)
  ref.read(projectDoneAtProvider.notifier).setDone(projectId, DateTime.now());
}
Future<void> updateDeadline(String projectId, DateTime? deadline) async {
  final current = state.value ?? <Project>[];
  state = AsyncData([
    for (final p in current)
      if (p.id == projectId) p.copyWith(deadline: deadline) else p,
  ]);
}

Future<void> transferProjectTo(String projectId, String newAssigneeId) async {
  final current = state.value ?? <Project>[];
  state = AsyncData([
    for (final p in current)
      if (p.id == projectId)
        p.copyWith(teamMembers: [newAssigneeId])
      else
        p,
  ]);
}
  //  Create project 
  Future<void> createProject({
    required String name,
    DateTime? deadline,
    List<String> teamMembers = const [],
  }) async {
    final current = state.value ?? <Project>[];

    final newProject = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      deadline: deadline,
      teamMembers: teamMembers,
    
      status: ProjectStatus.onTrack,
      tasks: 0, 
    );

    state = AsyncData([newProject, ...current]);
  }
  // un-done
Future<void> markUndone(String projectId) async {
  final current = state.value ?? <Project>[];

  state = AsyncData([
    for (final p in current)
      if (p.id == projectId) p.copyWith(status: ProjectStatus.onTrack) else p,
  ]);

  //  καθάρισε timestamp
  ref.read(projectDoneAtProvider.notifier).clear(projectId);
}
//delete project
Future<void> deleteProject(String projectId) async {
  final current = state.value ?? <Project>[];
  state = AsyncData(current.where((p) => p.id != projectId).toList());

  // καθάρισε timestamp
  ref.read(projectDoneAtProvider.notifier).clear(projectId);
  ref.read(userCreatedProjectIdsProvider.notifier).remove(projectId);
}
Future<void> assignProject(String projectId, String assigneeId) async {
  final current = state.value ?? const <Project>[];

  state = AsyncData([
    for (final p in current)
      if (p.id == projectId)
        p.copyWith(
          teamMembers:[assigneeId])
   
      else
        p,
  ]);
}

}

final projectDoneAtProvider =
    StateNotifierProvider<ProjectDoneAtController, Map<String, DateTime>>(
  (ref) => ProjectDoneAtController(),
);

class ProjectDoneAtController extends StateNotifier<Map<String, DateTime>> {
  ProjectDoneAtController() : super(const {});

  void setDone(String projectId, DateTime when) {
    state = {...state, projectId: when};
  }

  void clear(String projectId) {
    final next = {...state};
    next.remove(projectId);
    state = next;
  }
}

final calendarTasksProvider = FutureProvider.autoDispose<List<TaskItem>>(
  (ref) => ref.read(calendarRepositoryProvider).fetchCalendarTasks(),
);

final projectTasksProvider =
    FutureProvider.autoDispose.family<List<TaskItem>, String>((ref, projectId) {
  return ref.read(projectsRepositoryProvider).fetchProjectTasks(projectId);
});

const String kMeUserId = 'me';

final usersProvider = AsyncNotifierProvider<UsersController, List<User>>(
  UsersController.new,
);

final projectRequestsProvider =
    AsyncNotifierProvider<ProjectRequestsController, List<ProjectRequest>>(
  ProjectRequestsController.new,
);

class ProjectRequestsController extends AsyncNotifier<List<ProjectRequest>> {
  @override
  Future<List<ProjectRequest>> build() async {

    final existing = state.valueOrNull;
    if (existing != null) return existing;

return <ProjectRequest>[
  // 7 INCOMING -> to me
  ProjectRequest(
    id: 'r_in_1',
    projectId: 'demo_p1',
    fromUserId: 'u2',
    toUserId: kMeUserId,
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    status: ProjectRequestStatus.pending,
  ),
  ProjectRequest(
    id: 'r_in_2',
    projectId: 'demo_p3',
    fromUserId: 'u3',
    toUserId: kMeUserId,
    createdAt: DateTime.now().subtract(const Duration(hours: 9)),
    status: ProjectRequestStatus.pending,
  ),
  ProjectRequest(
    id: 'r_in_3',
    projectId: 'demo_p4',
    fromUserId: 'u1',
    toUserId: kMeUserId,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    status: ProjectRequestStatus.pending,
  ),
  ProjectRequest(
    id: 'r_in_4',
    projectId: 'demo_p5',
    fromUserId: 'u4',
    toUserId: kMeUserId,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
    status: ProjectRequestStatus.pending,
  ),
  ProjectRequest(
    id: 'r_in_5',
    projectId: 'demo_p6',
    fromUserId: 'u2',
    toUserId: kMeUserId,
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    status: ProjectRequestStatus.pending,
  ),
  ProjectRequest(
    id: 'r_in_6',
    projectId: 'demo_p7',
    fromUserId: 'u1',
    toUserId: kMeUserId,
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
    status: ProjectRequestStatus.pending,
  ),
  ProjectRequest(
    id: 'r_in_7',
    projectId: 'demo_p8',
    fromUserId: 'u3',
    toUserId: kMeUserId,
    createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 6)),
    status: ProjectRequestStatus.pending,
  ),

  ProjectRequest(
    id: 'r_out_1',
    projectId: 'demo_p2',
    fromUserId: kMeUserId,
    toUserId: 'u1',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    status: ProjectRequestStatus.denied,
  ),
];

  }

  Future<void> send({
    required String projectId,
    required String toUserId,
    String fromUserId = kMeUserId,
  }) async {
    final current = state.value ?? const <ProjectRequest>[];

    final req = ProjectRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: projectId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      createdAt: DateTime.now(),
      status: ProjectRequestStatus.pending,
    );

    state = AsyncData([req, ...current]);
  }

  Future<void> accept(String requestId) async {
    final current = state.value ?? const <ProjectRequest>[];
    final idx = current.indexWhere((r) => r.id == requestId);
    if (idx == -1) return;

    final req = current[idx];
    if (req.status != ProjectRequestStatus.pending) return;

    state = AsyncData([
      for (final r in current)
        if (r.id == requestId) r.copyWith(status: ProjectRequestStatus.accepted) else r,
    ]);


    await ref.read(projectsProvider.notifier).assignProject(req.projectId, kMeUserId);
  }

  Future<void> deny(String requestId) async {
    final current = state.value ?? const <ProjectRequest>[];

    state = AsyncData([
      for (final r in current)
        if (r.id == requestId) r.copyWith(status: ProjectRequestStatus.denied) else r,
    ]);
  }
}
class UsersController extends AsyncNotifier<List<User>> {
  static const List<User> _seed = [
    User(id: kMeUserId, name: 'Me', email: 'me@GroupUp.app'),
    User(id: 'u1', name: 'Alice Johnson', email: 'alice@gmail.com'),
    User(id: 'u2', name: 'Bob Smith', email: 'bob@gmail.com'),
    User(id: 'u3', name: 'Carol Williams', email: 'carol@gmail.com'),
    User(id: 'u4', name: 'David Brown', email: 'david@gmail.com'),
  ];

  @override
  Future<List<User>> build() async {

    return List<User>.from(_seed);
  }

  Future<void> addTeammateFromInvite(String raw) async {
    final user = _tryParseUser(raw);
    if (user == null) return;
    await _upsertUser(user);
  }
  Future<void> joinTeamFromLink(String raw) async {
    final uri = Uri.tryParse(raw);
    final owner = uri?.queryParameters['owner'];
    if (owner == null || owner.isEmpty) return;

    final id = 'u${DateTime.now().millisecondsSinceEpoch}';
    final newUser = User(
      id: id,
      name: 'New Teammate',
      email: '$id@GroupUp.app',
    );

    await _upsertUser(newUser);
  }

  Future<void> applyInvite(String raw) async {

    if (_looksLikeUserInvite(raw)) {
      await addTeammateFromInvite(raw);
      return;
    }

    await joinTeamFromLink(raw);
  }

  bool _looksLikeUserInvite(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null) return raw.trim().isNotEmpty && !raw.contains('owner=');
    final qp = uri.queryParameters;
    return (qp['userId'] ?? qp['id']) != null;
  }

  User? _tryParseUser(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final looksLikeIdOnly =
        !trimmed.contains('://') && !trimmed.contains('?') && !trimmed.contains('=');

    if (looksLikeIdOnly) {

      final existingSeed = _seed.where((u) => u.id == trimmed).toList();
      if (existingSeed.isNotEmpty) return existingSeed.first;

      if (trimmed == kMeUserId) return null;
      return User(id: trimmed, name: 'Teammate $trimmed', email: '$trimmed@taskflow.app');
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;

    final qp = uri.queryParameters;
    final id = (qp['userId'] ?? qp['id'])?.trim();
    if (id == null || id.isEmpty) return null;
    if (id == kMeUserId) return null;

    final name = (qp['name'] ?? 'Teammate').trim();
    final email = (qp['email'] ?? '$id@taskflow.app').trim();

    return User(id: id, name: name.isEmpty ? 'Teammate' : name, email: email);
  }

  Future<void> _upsertUser(User user) async {
    final current = state.value ?? await future;

    final exists = current.any((u) => u.id == user.id);
    final updated = exists
        ? [
            for (final u in current) if (u.id == user.id) user else u,
          ]
        : [...current, user];

    state = AsyncData(updated);
  }
}

enum TeamRequestStatus { pending, accepted, denied }

class TeamTransferRequest {
  const TeamTransferRequest({
    required this.id,
    required this.projectId,
    required this.fromUserId,
    required this.toUserId,
    required this.createdAt,
    this.status = TeamRequestStatus.pending,
  });

  final String id;
  final String projectId;
  final String fromUserId;
  final String toUserId;
  final DateTime createdAt;
  final TeamRequestStatus status;

  TeamTransferRequest copyWith({
    TeamRequestStatus? status,
  }) {
    return TeamTransferRequest(
      id: id,
      projectId: projectId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}

final teamRequestsProvider =
    AsyncNotifierProvider<TeamRequestsController, List<TeamTransferRequest>>(
  TeamRequestsController.new,
);

class TeamRequestsController extends AsyncNotifier<List<TeamTransferRequest>> {
  @override
  Future<List<TeamTransferRequest>> build() async {
 
    return [
      TeamTransferRequest(
        id: 'r_in_1',
        projectId: 'p_u2', 
        fromUserId: 'u2',
        toUserId: kMeUserId,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        status: TeamRequestStatus.pending,
      ),
      TeamTransferRequest(
        id: 'r_in_2',
        projectId: 'p_u1',
        fromUserId: 'u1',
        toUserId: kMeUserId,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: TeamRequestStatus.pending,
      ),

      TeamTransferRequest(
        id: 'r_out_1',
        projectId: 'p_me_2',
        fromUserId: kMeUserId,
        toUserId: 'u3',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        status: TeamRequestStatus.pending,
      ),
      TeamTransferRequest(
        id: 'r_out_2',
        projectId: 'p_me_3',
        fromUserId: kMeUserId,
        toUserId: 'u4',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: TeamRequestStatus.denied,
      ),
    ];
  }

  Future<void> sendRequest({
    required String projectId,
    required String toUserId,
  }) async {
    final current = state.value ?? const <TeamTransferRequest>[];

    final req = TeamTransferRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: projectId,
      fromUserId: kMeUserId,
      toUserId: toUserId,
      createdAt: DateTime.now(),
      status: TeamRequestStatus.pending,
    );

    state = AsyncData([req, ...current]);
  }

  Future<void> acceptRequest(String requestId) async {
    final current = state.value ?? const <TeamTransferRequest>[];

    final req = current.firstWhere((r) => r.id == requestId);
    final updated = current
        .map((r) => r.id == requestId ? r.copyWith(status: TeamRequestStatus.accepted) : r)
        .toList();

    state = AsyncData(updated);

    await ref.read(projectsProvider.notifier).assignProject(req.projectId, kMeUserId);
  }

  Future<void> denyRequest(String requestId) async {
    final current = state.value ?? const <TeamTransferRequest>[];

    final updated = current
        .map((r) => r.id == requestId ? r.copyWith(status: TeamRequestStatus.denied) : r)
        .toList();

    state = AsyncData(updated);
  }
}


enum OutgoingRequestStatus { pending, accepted, denied }

class OutgoingProjectRequest {
  const OutgoingProjectRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.toUserName,
    required this.projectId,
    required this.projectName,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String fromUserId;
  final String toUserId;
  final String toUserName;
  final String projectId;
  final String projectName;
  final DateTime createdAt;
  final OutgoingRequestStatus status;

  OutgoingProjectRequest copyWith({
    OutgoingRequestStatus? status,
  }) {
    return OutgoingProjectRequest(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      toUserName: toUserName,
      projectId: projectId,
      projectName: projectName,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}

final outgoingRequestsProvider =
    AsyncNotifierProvider<OutgoingRequestsController, List<OutgoingProjectRequest>>(
  OutgoingRequestsController.new,
);

class OutgoingRequestsController extends AsyncNotifier<List<OutgoingProjectRequest>> {
  @override
  Future<List<OutgoingProjectRequest>> build() async {
    return state.value ?? <OutgoingProjectRequest>[];
  }

  Future<void> sendHelpRequest({
    required Project project,
    required User toUser,
  }) async {
    final current = state.value ?? const <OutgoingProjectRequest>[];

    final r = OutgoingProjectRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromUserId: kMeUserId,
      toUserId: toUser.id,
      toUserName: toUser.name,
      projectId: project.id,
      projectName: project.name,
      createdAt: DateTime.now(),
      status: OutgoingRequestStatus.pending,
    );

    state = AsyncData([r, ...current]);
  }

  Future<void> setStatus(String requestId, OutgoingRequestStatus status) async {
    final current = state.value ?? const <OutgoingProjectRequest>[];
    state = AsyncData([
      for (final r in current) if (r.id == requestId) r.copyWith(status: status) else r,
    ]);
  }
}