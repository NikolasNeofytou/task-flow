import '../models/request.dart';
import '../repositories/requests_repository.dart';
import '../storage/hive_storage_service.dart';

/// Offline-first repository for requests
/// Tries to fetch from API, falls back to cache
class CachedRequestsRepository implements RequestsRepository {
  CachedRequestsRepository(this._remoteRepository);

  final RequestsRepository _remoteRepository;

  @override
  Future<List<Request>> fetchRequests() async {
    try {
      // Try to fetch from API
      final requests = await _remoteRepository.fetchRequests();
      // Cache the results
      await HiveStorageService.saveRequests(requests);
      return requests;
    } catch (e) {
      // If API fails, return cached data
      final cached = HiveStorageService.getRequests();
      if (cached.isEmpty) rethrow;
      return cached;
    }
  }

  @override
  Future<void> acceptRequest(String id) async {
    await _remoteRepository.acceptRequest(id);
    // Update local cache
    final requests = HiveStorageService.getRequests();
    final updated = requests.map((r) {
      if (r.id == id) {
        return Request(
          id: r.id,
          title: r.title,
          status: RequestStatus.accepted,
          createdAt: r.createdAt,
          type: r.type,
          fromUserId: r.fromUserId,
          toUserId: r.toUserId,
          taskId: r.taskId,
          projectId: r.projectId,
        );
      }
      return r;
    }).toList();
    await HiveStorageService.saveRequests(updated);
  }

  @override
  Future<void> rejectRequest(String id) async {
    await _remoteRepository.rejectRequest(id);
    // Update local cache
    final requests = HiveStorageService.getRequests();
    final updated = requests.map((r) {
      if (r.id == id) {
        return Request(
          id: r.id,
          title: r.title,
          status: RequestStatus.rejected,
          createdAt: r.createdAt,
          type: r.type,
          fromUserId: r.fromUserId,
          toUserId: r.toUserId,
          taskId: r.taskId,
          projectId: r.projectId,
        );
      }
      return r;
    }).toList();
    await HiveStorageService.saveRequests(updated);
  }

  @override
  Future<Request> createRequest({
    required String title,
    DateTime? dueDate,
  }) async {
    final request = await _remoteRepository.createRequest(
      title: title,
      dueDate: dueDate,
    );
    // Add to cache
    final requests = HiveStorageService.getRequests();
    await HiveStorageService.saveRequests([...requests, request]);
    return request;
  }
}
