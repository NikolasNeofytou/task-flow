import '../models/request.dart';

abstract class RequestsRepository {
  Future<List<Request>> fetchRequests();
  Future<void> acceptRequest(String id);
  Future<void> rejectRequest(String id);
  Future<Request> createRequest({
    required String title,
    DateTime? dueDate,
  });
}
