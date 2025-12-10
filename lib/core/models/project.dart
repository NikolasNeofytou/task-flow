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
  });

  final String id;
  final String name;
  final ProjectStatus status;
  final int tasks;
  final DateTime? deadline;
  final int completedTasks;
  final List<String> teamMembers; // User IDs
  
  double get progress => tasks > 0 ? completedTasks / tasks : 0.0;
}
