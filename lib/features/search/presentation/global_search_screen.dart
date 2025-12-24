import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/task_item.dart';
import '../../../core/models/project.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/utils/search_utils.dart';
import '../../../theme/tokens.dart';

/// Global search screen with unified search across tasks, projects, and users
class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _query = '';
  SearchCategory _selectedCategory = SearchCategory.all;
  
  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search tasks, projects, people...',
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _query = '';
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
          textInputAction: TextInputAction.search,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildCategoryTabs(),
        ),
      ),
      body: _query.isEmpty
          ? _buildEmptyState()
          : _buildSearchResults(tasksAsync, projectsAsync, usersAsync),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          _CategoryChip(
            label: 'All',
            isSelected: _selectedCategory == SearchCategory.all,
            onTap: () => setState(() => _selectedCategory = SearchCategory.all),
          ),
          const SizedBox(width: AppSpacing.sm),
          _CategoryChip(
            label: 'Tasks',
            icon: Icons.task_alt,
            isSelected: _selectedCategory == SearchCategory.tasks,
            onTap: () => setState(() => _selectedCategory = SearchCategory.tasks),
          ),
          const SizedBox(width: AppSpacing.sm),
          _CategoryChip(
            label: 'Projects',
            icon: Icons.folder,
            isSelected: _selectedCategory == SearchCategory.projects,
            onTap: () => setState(() => _selectedCategory = SearchCategory.projects),
          ),
          const SizedBox(width: AppSpacing.sm),
          _CategoryChip(
            label: 'People',
            icon: Icons.people,
            isSelected: _selectedCategory == SearchCategory.people,
            onTap: () => setState(() => _selectedCategory = SearchCategory.people),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Search across everything',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Find tasks, projects, and teammates',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildShortcutHint(),
        ],
      ),
    );
  }

  Widget _buildShortcutHint() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              '⌘',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 4),
          const Text('+'),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'K',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text('to search'),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    AsyncValue<List<TaskItem>> tasksAsync,
    AsyncValue<List<Project>> projectsAsync,
    AsyncValue<List<User>> usersAsync,
  ) {
    return tasksAsync.when(
      data: (tasks) => projectsAsync.when(
        data: (projects) => usersAsync.when(
          data: (users) => _buildResultsList(tasks, projects, users),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error loading users')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading projects')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading tasks')),
    );
  }

  Widget _buildResultsList(
    List<TaskItem> tasks,
    List<Project> projects,
    List<User> users,
  ) {
    // Search tasks
    List<SearchResult<TaskItem>> taskResults = [];
    if (_selectedCategory == SearchCategory.all ||
        _selectedCategory == SearchCategory.tasks) {
      final taskSearchEngine = FuzzySearchEngine<TaskItem>(
        threshold: 0.3,
        caseSensitive: false,
        maxResults: 50,
      );
      taskResults = taskSearchEngine.search(
        query: _query,
        items: tasks,
        fieldExtractors: {
          'title': (task) => task.title,
        },
        fieldWeights: {
          'title': 2.0,
        },
      );
    }

    // Search projects
    List<SearchResult<Project>> projectResults = [];
    if (_selectedCategory == SearchCategory.all ||
        _selectedCategory == SearchCategory.projects) {
      final projectSearchEngine = FuzzySearchEngine<Project>(
        threshold: 0.3,
        caseSensitive: false,
        maxResults: 50,
      );
      projectResults = projectSearchEngine.search(
        query: _query,
        items: projects,
        fieldExtractors: {
          'name': (project) => project.name,
        },
        fieldWeights: {
          'name': 2.0,
        },
      );
    }

    // Search users
    List<SearchResult<User>> userResults = [];
    if (_selectedCategory == SearchCategory.all ||
        _selectedCategory == SearchCategory.people) {
      final userSearchEngine = FuzzySearchEngine<User>(
        threshold: 0.3,
        caseSensitive: false,
        maxResults: 50,
      );
      userResults = userSearchEngine.search(
        query: _query,
        items: users,
        fieldExtractors: {
          'name': (user) => user.name,
          'email': (user) => user.email,
        },
        fieldWeights: {
          'name': 2.0,
          'email': 1.0,
        },
      );
    }

    final totalResults =
        taskResults.length + projectResults.length + userResults.length;

    if (totalResults == 0) {
      return _buildNoResults();
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          '$totalResults ${totalResults == 1 ? 'result' : 'results'} found',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Tasks
        if (taskResults.isNotEmpty) ...[
          _SectionHeader(
            title: 'Tasks',
            count: taskResults.length,
            icon: Icons.task_alt,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...taskResults.map((result) => _TaskResultTile(
                task: result.item,
                matches: result.matches,
                score: result.score,
              )),
          const SizedBox(height: AppSpacing.xl),
        ],

        // Projects
        if (projectResults.isNotEmpty) ...[
          _SectionHeader(
            title: 'Projects',
            count: projectResults.length,
            icon: Icons.folder,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...projectResults.map((result) => _ProjectResultTile(
                project: result.item,
                matches: result.matches,
                score: result.score,
              )),
          const SizedBox(height: AppSpacing.xl),
        ],

        // Users
        if (userResults.isNotEmpty) ...[
          _SectionHeader(
            title: 'People',
            count: userResults.length,
            icon: Icons.people,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...userResults.map((result) => _UserResultTile(
                user: result.item,
                matches: result.matches,
                score: result.score,
              )),
        ],
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try a different search term',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}

enum SearchCategory { all, tasks, projects, people }

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}

class _TaskResultTile extends ConsumerWidget {
  final TaskItem task;
  final List<SearchMatch> matches;
  final double score;

  const _TaskResultTile({
    required this.task,
    required this.matches,
    required this.score,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(task.status).withOpacity(0.2),
          child: Icon(
            Icons.task_alt,
            color: _getStatusColor(task.status),
            size: 20,
          ),
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    task.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(task.status),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Due ${_formatDate(task.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          context.pop(); // Close search
          context.push('/projects/${task.projectId}/tasks/${task.id}');
        },
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => Colors.grey,
      TaskStatus.done => Colors.green,
      TaskStatus.blocked => Colors.red,
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    
    if (diff == 0) return 'today';
    if (diff == 1) return 'tomorrow';
    if (diff == -1) return 'yesterday';
    if (diff > 0) return 'in $diff days';
    return '${-diff} days ago';
  }
}

class _ProjectResultTile extends ConsumerWidget {
  final Project project;
  final List<SearchMatch> matches;
  final double score;

  const _ProjectResultTile({
    required this.project,
    required this.matches,
    required this.score,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: const Icon(
            Icons.folder,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          context.pop(); // Close search
          context.push('/projects/${project.id}');
        },
      ),
    );
  }
}

class _UserResultTile extends ConsumerWidget {
  final User user;
  final List<SearchMatch> matches;
  final double score;

  const _UserResultTile({
    required this.user,
    required this.matches,
    required this.score,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null
              ? Text(user.name[0].toUpperCase())
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(user.email),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          context.pop(); // Close search
          // Navigate to user profile if route exists
          // context.push('/users/${user.id}');
        },
      ),
    );
  }
}
