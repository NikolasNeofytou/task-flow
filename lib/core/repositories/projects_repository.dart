import '../models/project.dart';
import '../models/task_item.dart';

abstract class ProjectsRepository {
  Future<List<Project>> fetchProjects();
  Future<List<TaskItem>> fetchProjectTasks(String projectId);
}
