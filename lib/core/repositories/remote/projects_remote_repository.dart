import 'package:dio/dio.dart';

import '../../dto/project_dto.dart';
import '../../dto/task_dto.dart';
import '../../models/project.dart';
import '../../models/task_item.dart';
import '../../network/exceptions.dart';
import '../projects_repository.dart';

class ProjectsRemoteRepository implements ProjectsRepository {
  ProjectsRemoteRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Project>> fetchProjects() async {
    try {
      final response = await _dio.get('/projects');
      final data = response.data as List<dynamic>;
      return data
          .map((json) => ProjectDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  @override
  Future<List<TaskItem>> fetchProjectTasks(String projectId) async {
    try {
      // Node mock schema uses /projects/{id}/tasks
      final response = await _dio.get('/projects/$projectId/tasks');
      final data = response.data as List<dynamic>;
      return data
          .map((json) => TaskDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
