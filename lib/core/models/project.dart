enum ProjectStatus { onTrack, dueSoon, blocked }

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.status,
    required this.tasks,
    this.deadline,
    this.completedTasks = 0,
    this.teamMembers = const [],
    this.description,
    this.color,
    this.ownerId,
    this.members,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final ProjectStatus status;
  final int tasks;
  final DateTime? deadline;
  final int completedTasks;
  final List<String> teamMembers; // User IDs
  final String? description;
  final String? color;
  final String? ownerId;
  final List<String>? members;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  double get progress => tasks > 0 ? completedTasks / tasks : 0.0;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.name,
      'tasks': tasks,
      'deadline': deadline?.toIso8601String(),
      'completedTasks': completedTasks,
      'teamMembers': teamMembers,
      'description': description,
      'color': color,
      'ownerId': ownerId,
      'members': members,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.onTrack,
      ),
      tasks: json['tasks'] as int,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      completedTasks: json['completedTasks'] as int? ?? 0,
      teamMembers: List<String>.from(json['teamMembers'] as List? ?? []),
      description: json['description'] as String?,
      color: json['color'] as String?,
      ownerId: json['ownerId'] as String?,
      members: json['members'] != null
          ? List<String>.from(json['members'] as List)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Copy with method for immutable updates
  Project copyWith({
    String? id,
    String? name,
    ProjectStatus? status,
    int? tasks,
    DateTime? deadline,
    int? completedTasks,
    List<String>? teamMembers,
    String? description,
    String? color,
    String? ownerId,
    List<String>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      deadline: deadline ?? this.deadline,
      completedTasks: completedTasks ?? this.completedTasks,
      teamMembers: teamMembers ?? this.teamMembers,
      description: description ?? this.description,
      color: color ?? this.color,
      ownerId: ownerId ?? this.ownerId,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
