import '../models/project.dart';

class ProjectDto {
  const ProjectDto({
    required this.id,
    required this.name,
    required this.status,
    required this.tasks,
  });

  final String id;
  final String name;
  final String status;
  final int tasks;

  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    return ProjectDto(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      tasks: (json['tasks'] as num).toInt(),
    );
  }

  Project toDomain() {
    return Project(
      id: id,
      name: name,
      status: _mapStatus(status),
      tasks: tasks,
    );
  }

  ProjectStatus _mapStatus(String value) {
    switch (value.toLowerCase()) {
      case 'ontrack':
      case 'on_track':
        return ProjectStatus.onTrack;
      case 'blocked':
        return ProjectStatus.blocked;
      case 'duesoon':
      case 'due_soon':
      default:
        return ProjectStatus.dueSoon;
    }
  }
}
