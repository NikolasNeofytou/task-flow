import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/models/request.dart';
import '../../../core/providers/data_providers.dart';

final requestsControllerProvider =
    AsyncNotifierProvider<RequestsController, List<Request>>(
  RequestsController.new,
);

class RequestsController extends AsyncNotifier<List<Request>> {
  @override
  Future<List<Request>> build() async {
    return ref.read(requestsRepositoryProvider).fetchRequests();
  }

  Future<void> accept(String id) async {
    final previous = state.valueOrNull;
    if (previous == null) return;
    _updateStatusLocal(id, RequestStatus.accepted);
    try {
      await ref.read(requestsRepositoryProvider).acceptRequest(id);
      await ref.read(analyticsProvider).logEvent('request_accept', parameters: {'id': id});
    } catch (e, st) {
      state = AsyncError(e, st);
      state = AsyncData(previous);
    }
  }

  Future<void> reject(String id) async {
    final previous = state.valueOrNull;
    if (previous == null) return;
    _updateStatusLocal(id, RequestStatus.rejected);
    try {
      await ref.read(requestsRepositoryProvider).rejectRequest(id);
      await ref.read(analyticsProvider).logEvent('request_reject', parameters: {'id': id});
    } catch (e, st) {
      state = AsyncError(e, st);
      state = AsyncData(previous);
    }
  }

  Future<void> send(String title, {DateTime? dueDate}) async {
    final previous = state.valueOrNull;
    try {
      final created = await ref
          .read(requestsRepositoryProvider)
          .createRequest(title: title, dueDate: dueDate);
      final updated = [created, ...?previous];
      state = AsyncData(updated);
      await ref.read(analyticsProvider).logEvent('request_send', parameters: {
        'id': created.id,
        'has_due_date': dueDate != null,
      });
    } catch (e, st) {
      state = AsyncError(e, st);
      if (previous != null) state = AsyncData(previous);
    }
  }

  void _updateStatusLocal(String id, RequestStatus status) {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = [
      for (final r in current)
        if (r.id == id)
          Request(
            id: r.id,
            title: r.title,
            status: status,
            createdAt: r.createdAt,
          )
        else
          r
    ];
    state = AsyncData(updated);
  }

  void restore(List<Request> snapshot) {
    state = AsyncData(snapshot);
  }
}
