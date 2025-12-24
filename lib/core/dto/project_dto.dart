import '../models/project.dart';

class ProjectDto {
  const ProjectDto({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.members,
    this.status,
    this.tasks,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? color;
  final List<String>? members;
  final String? status;
  final int? tasks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    return ProjectDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      members:
          (json['members'] as List<dynamic>?)?.map((e) => e as String).toList(),
      status: json['status'] as String?,
      tasks: json['tasks'] != null ? (json['tasks'] as num).toInt() : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Project toDomain() {
    return Project(
      id: id,
      name: name,
      status: status != null ? _mapStatus(status!) : ProjectStatus.onTrack,
      tasks: tasks ?? 0,
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
