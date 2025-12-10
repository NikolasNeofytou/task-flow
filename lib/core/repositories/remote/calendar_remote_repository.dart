import 'package:dio/dio.dart';

import '../../dto/task_dto.dart';
import '../../models/task_item.dart';
import '../../network/exceptions.dart';
import '../calendar_repository.dart';

class CalendarRemoteRepository implements CalendarRepository {
  CalendarRemoteRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<TaskItem>> fetchCalendarTasks() async {
    try {
      // Node mock schema uses /calendar/tasks
      final response = await _dio.get('/calendar/tasks');
      final data = response.data as List<dynamic>;
      return data
          .map((json) => TaskDto.fromJson(json as Map<String, dynamic>).toDomain())
          .toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
