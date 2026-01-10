import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/data_providers.dart';
import '../../../theme/tokens.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reqAsync = ref.watch(projectRequestsProvider);
    final usersAsync = ref.watch(usersProvider);
    final projectsAsync = ref.watch(projectsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Requests', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.lg),

        Expanded(
          child: reqAsync.when(
            loading: () => const Center(child: CircularProgressIndicator.adaptive()),
            error: (e, _) => Center(child: Text('Failed to load requests: $e')),
            data: (reqs) {
              return usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                error: (e, _) => Center(child: Text('Failed to load team: $e')),
                data: (users) {
                  return projectsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                    error: (e, _) => Center(child: Text('Failed to load projects: $e')),
                    data: (projects) {
                      String nameOfUser(String id) {
                        return users.firstWhere((u) => u.id == id,
                            orElse: () => users.first).name;
                      }

                      String nameOfProject(String id) {
                        final p = projects.where((p) => p.id == id);
                        return p.isEmpty ? 'Unknown project' : p.first.name;
                      }

                      final outgoing = reqs.where((r) => r.fromUserId == kMeUserId).toList();
                      final incoming = reqs.where((r) => r.toUserId == kMeUserId).toList();

                      Widget statusChip(ProjectRequestStatus s) {
                        switch (s) {
                          case ProjectRequestStatus.accepted:
                            return const Text('✔️ Request accepted');
                          case ProjectRequestStatus.denied:
                            return const Text('✖️ Request denied');
                          case ProjectRequestStatus.pending:
                            return const Text('➖ Request not answered yet');
                        }
                      }

                      return ListView(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                        children: [
                          Text(
                            'Outgoing requests',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          if (outgoing.isEmpty)
                            Text(
                              'No outgoing requests',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            )
                          else
                            ...outgoing.map((r) {
                              final toName = nameOfUser(r.toUserId);
                              final projectName = nameOfProject(r.projectId);

                              return Card(
                                child: ListTile(
                                  title: Text('You asked $toName to take "$projectName" from you'),
                                  subtitle: statusChip(r.status),
                                ),
                              );
                            }),

                          const SizedBox(height: AppSpacing.lg),

                          Text(
                            'Incoming requests',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          if (incoming.isEmpty)
                            Text(
                              'No incoming requests',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            )
                          else
                            ...incoming.map((r) {
                              final fromName = nameOfUser(r.fromUserId);
                              final projectName = nameOfProject(r.projectId);

                              final isPending = r.status == ProjectRequestStatus.pending;

                              return Card(
                                child: ListTile(
                                  title: Text('$fromName asked you to take "$projectName"'),
                                  subtitle: statusChip(r.status),
                                  trailing: isPending
                                      ? Wrap(
                                          spacing: 8,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () => ref
                                                  .read(projectRequestsProvider.notifier)
                                                  .deny(r.id),
                                              child: const Text('Deny'),
                                            ),
                                            FilledButton(
                                              onPressed: () => ref
                                                  .read(projectRequestsProvider.notifier)
                                                  .accept(r.id),
                                              child: const Text('Accept'),
                                            ),
                                          ],
                                        )
                                      : null,
                                ),
                              );
                            }),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}