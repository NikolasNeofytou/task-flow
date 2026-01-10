class Project {
  const Project({
    required this.id,
    required this.name,
    required this.status,
    required this.tasks,
    this.completedTasks = 0,
    this.deadline,
    this.teamMembers = const [],
    this.description,
  });

  final String id;
  final String name;

  final ProjectStatus status;

  final int tasks;
  final int completedTasks;

  final DateTime? deadline;
  final List<String> teamMembers;
  final String? description;

  Project copyWith({
    String? id,
    String? name,
    ProjectStatus? status,
    int? tasks,
    int? completedTasks,
    DateTime? deadline,
    List<String>? teamMembers,
    String? description,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      completedTasks: completedTasks ?? this.completedTasks,
      deadline: deadline ?? this.deadline,
      teamMembers: teamMembers ?? this.teamMembers,
      description: description ?? this.description,
    );
  }
}

enum ProjectStatus {
  onTrack,
  dueSoon,
  blocked,
  done,
}
