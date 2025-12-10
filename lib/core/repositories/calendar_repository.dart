import '../models/task_item.dart';

abstract class CalendarRepository {
  Future<List<TaskItem>> fetchCalendarTasks();
}
