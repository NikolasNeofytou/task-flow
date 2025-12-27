# UX Polish Integration Guide

This guide shows how to integrate the new UX polish features into existing screens.

## 📋 Table of Contents
1. [Onboarding Integration](#onboarding-integration)
2. [Empty States](#empty-states)
3. [Pull-to-Refresh](#pull-to-refresh)
4. [Infinite Scroll](#infinite-scroll)
5. [Search History](#search-history)
6. [Recent Items](#recent-items)

---

## 1. Onboarding Integration

### Check on App Startup

**In `main.dart` or your splash screen:**

```dart
import 'package:taskflow/core/widgets/onboarding_screen.dart';

// After user authentication or on splash screen
Future<void> _checkOnboarding() async {
  final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();
  
  if (!hasSeenOnboarding && mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(
          onComplete: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
```

### Reset for Testing

```dart
// Call this to reset onboarding (for testing)
await OnboardingService.resetOnboarding();
```

### Feature Tooltips

**Add to any feature that needs contextual help:**

```dart
import 'package:taskflow/core/widgets/onboarding_screen.dart';

FeatureTooltip(
  featureName: 'create_task',  // Unique identifier
  title: 'Create Your First Task',
  description: 'Tap here to add a new task to your project',
  child: FloatingActionButton(
    onPressed: _createTask,
    child: Icon(Icons.add),
  ),
)
```

---

## 2. Empty States

### Projects Screen

**In `lib/features/projects/presentation/screens/projects_screen.dart`:**

```dart
import 'package:taskflow/core/widgets/empty_state_widget.dart';

Widget build(BuildContext context) {
  return Scaffold(
    body: projects.isEmpty
        ? EmptyProjectsWidget(
            onCreateProject: () => _showCreateProjectDialog(),
          )
        : ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return ProjectCard(project: projects[index]);
            },
          ),
  );
}
```

### Tasks Screen

**In `lib/features/tasks/presentation/screens/tasks_screen.dart`:**

```dart
import 'package:taskflow/core/widgets/empty_state_widget.dart';

Widget build(BuildContext context) {
  return Scaffold(
    body: tasks.isEmpty
        ? EmptyTasksWidget(
            onCreateTask: () => _showCreateTaskDialog(),
          )
        : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return TaskCard(task: tasks[index]);
            },
          ),
  );
}
```

### Requests Screen

**In `lib/features/requests/presentation/screens/requests_screen.dart`:**

```dart
import 'package:taskflow/core/widgets/empty_state_widget.dart';

Widget build(BuildContext context) {
  return Scaffold(
    body: requests.isEmpty
        ? const EmptyRequestsWidget()
        : ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return RequestCard(request: requests[index]);
            },
          ),
  );
}
```

### Notifications Screen

**In `lib/features/notifications/presentation/screens/notifications_screen.dart`:**

```dart
import 'package:taskflow/core/widgets/empty_state_widget.dart';

Widget build(BuildContext context) {
  return Scaffold(
    body: notifications.isEmpty
        ? const EmptyNotificationsWidget()
        : ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return NotificationCard(notification: notifications[index]);
            },
          ),
  );
}
```

### Search Results

**In your search screen:**

```dart
import 'package:taskflow/core/widgets/empty_state_widget.dart';

if (searchResults.isEmpty && searchQuery.isNotEmpty) {
  return EmptySearchWidget(searchQuery: searchQuery);
}
```

### Network Errors

**In your data fetching code:**

```dart
import 'package:taskflow/core/widgets/empty_state_widget.dart';

if (hasNetworkError) {
  return NetworkErrorWidget(
    onRetry: () => _retryFetch(),
  );
}
```

---

## 3. Pull-to-Refresh

### Simple Implementation

**Wrap any ListView, GridView, or SingleChildScrollView:**

```dart
import 'package:taskflow/core/widgets/pull_to_refresh.dart';

PullToRefreshWrapper(
  onRefresh: () async {
    // Fetch fresh data from API
    await _refreshData();
  },
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      return ItemCard(item: items[index]);
    },
  ),
)
```

### Custom Color

```dart
PullToRefreshWrapper(
  onRefresh: _refreshData,
  color: Theme.of(context).colorScheme.primary,
  child: ListView(...),
)
```

---

## 4. Infinite Scroll

### List View with Pagination

**Replace ListView.builder with InfiniteScrollListView:**

```dart
import 'package:taskflow/core/widgets/pull_to_refresh.dart';

InfiniteScrollListView<Project>(
  items: projects,
  itemBuilder: (context, project, index) {
    return ProjectCard(project: project);
  },
  onLoadMore: () async {
    // Fetch next page
    await _loadMoreProjects();
  },
  hasMore: hasMorePages,  // Boolean: are there more pages?
  isLoading: isLoadingMore,  // Boolean: currently loading?
  emptyWidget: EmptyProjectsWidget(
    onCreateProject: _showCreateDialog,
  ),
  loadingWidget: Center(
    child: CircularProgressIndicator(),
  ),
)
```

### Grid View with Pagination

```dart
InfiniteScrollGridView<Task>(
  items: tasks,
  crossAxisCount: 2,
  childAspectRatio: 1.5,
  itemBuilder: (context, task, index) {
    return TaskCard(task: task);
  },
  onLoadMore: _loadMoreTasks,
  hasMore: hasMore,
  isLoading: isLoading,
  emptyWidget: EmptyTasksWidget(),
)
```

### Combined: Pull-to-Refresh + Infinite Scroll

**Best of both worlds:**

```dart
PullToRefreshInfiniteList<Task>(
  items: tasks,
  itemBuilder: (context, task, index) {
    return TaskCard(task: task);
  },
  onRefresh: () async {
    // Refresh: fetch first page again
    await _refreshTasks();
  },
  onLoadMore: () async {
    // Load more: fetch next page
    await _loadMoreTasks();
  },
  hasMore: hasMorePages,
  isLoading: isLoadingMore,
  emptyWidget: EmptyTasksWidget(
    onCreateTask: _showCreateDialog,
  ),
)
```

### Pagination Logic Example

```dart
class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project> projects = [];
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false;
  
  Future<void> _refreshProjects() async {
    setState(() {
      currentPage = 1;
      hasMore = true;
    });
    await _loadProjects();
  }
  
  Future<void> _loadMoreProjects() async {
    if (isLoading || !hasMore) return;
    
    setState(() {
      isLoading = true;
      currentPage++;
    });
    
    await _loadProjects();
  }
  
  Future<void> _loadProjects() async {
    try {
      final newProjects = await apiService.getProjects(page: currentPage);
      
      setState(() {
        if (currentPage == 1) {
          projects = newProjects;
        } else {
          projects.addAll(newProjects);
        }
        hasMore = newProjects.length >= 20; // Page size
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
```

---

## 5. Search History

### Add to Search Screen

**In your search screen:**

```dart
import 'package:taskflow/core/widgets/search_history_widget.dart';

class SearchScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search projects, tasks...',
          ),
          onSubmitted: (query) async {
            // Save to history
            await SearchHistoryService.addToHistory(query);
            // Perform search
            _performSearch(query);
          },
        ),
        
        // Show history when no search query
        if (_searchController.text.isEmpty)
          SearchHistoryWidget(
            onSearchSelected: (query) {
              _searchController.text = query;
              _performSearch(query);
            },
          ),
        
        // Show results or empty state
        if (_searchController.text.isNotEmpty) ...[
          if (searchResults.isEmpty)
            EmptySearchWidget(searchQuery: _searchController.text)
          else
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return ResultCard(result: searchResults[index]);
                },
              ),
            ),
        ],
      ],
    );
  }
}
```

### Clear History

```dart
// Add clear button in app bar
IconButton(
  icon: Icon(Icons.clear_all),
  onPressed: () async {
    await SearchHistoryService.clearHistory();
    setState(() {});
  },
)
```

---

## 6. Recent Items

### Add to Home Screen

**In `lib/features/home/presentation/screens/home_screen.dart`:**

```dart
import 'package:taskflow/core/widgets/search_history_widget.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent projects
            FutureBuilder<List<RecentItem>>(
              future: RecentItemsService.getRecentProjects(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return RecentItemsWidget(
                    items: snapshot.data!,
                    title: 'Recent Projects',
                    onItemTap: (id) {
                      // Navigate to project
                      context.push('/projects/$id');
                    },
                    onSeeAll: () {
                      // Navigate to all projects
                      context.push('/projects');
                    },
                  );
                }
                return SizedBox.shrink();
              },
            ),
            
            SizedBox(height: 16),
            
            // Recent tasks
            FutureBuilder<List<RecentItem>>(
              future: RecentItemsService.getRecentTasks(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return RecentItemsWidget(
                    items: snapshot.data!,
                    title: 'Recent Tasks',
                    onItemTap: (id) {
                      // Navigate to task
                      context.push('/tasks/$id');
                    },
                    onSeeAll: () {
                      // Navigate to all tasks
                      context.push('/tasks');
                    },
                  );
                }
                return SizedBox.shrink();
              },
            ),
            
            // Rest of home screen...
          ],
        ),
      ),
    );
  }
}
```

### Track Item Access

**When user opens a project:**

```dart
// In project detail screen
@override
void initState() {
  super.initState();
  // Track that user accessed this project
  RecentItemsService.addRecentProject(widget.projectId);
}
```

**When user opens a task:**

```dart
// In task detail screen
@override
void initState() {
  super.initState();
  // Track that user accessed this task
  RecentItemsService.addRecentTask(widget.taskId);
}
```

---

## 🎯 Complete Example: Projects Screen

Here's a complete example showing all features together:

```dart
import 'package:flutter/material.dart';
import 'package:taskflow/core/widgets/empty_state_widget.dart';
import 'package:taskflow/core/widgets/pull_to_refresh.dart';
import 'package:taskflow/core/widgets/onboarding_screen.dart';

class ProjectsScreen extends StatefulWidget {
  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project> projects = [];
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _refreshProjects();
  }
  
  Future<void> _refreshProjects() async {
    setState(() {
      currentPage = 1;
      hasMore = true;
    });
    await _loadProjects();
  }
  
  Future<void> _loadMoreProjects() async {
    if (isLoading || !hasMore) return;
    
    setState(() {
      isLoading = true;
      currentPage++;
    });
    
    await _loadProjects();
  }
  
  Future<void> _loadProjects() async {
    try {
      final newProjects = await apiService.getProjects(page: currentPage);
      
      setState(() {
        if (currentPage == 1) {
          projects = newProjects;
        } else {
          projects.addAll(newProjects);
        }
        hasMore = newProjects.length >= 20;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  void _showCreateDialog() {
    // Show create project dialog
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
      ),
      body: PullToRefreshInfiniteList<Project>(
        items: projects,
        itemBuilder: (context, project, index) {
          return ProjectCard(
            project: project,
            onTap: () {
              // Track recent access
              RecentItemsService.addRecentProject(project.id);
              // Navigate to project detail
              context.push('/projects/${project.id}');
            },
          );
        },
        onRefresh: _refreshProjects,
        onLoadMore: _loadMoreProjects,
        hasMore: hasMore,
        isLoading: isLoading,
        emptyWidget: EmptyProjectsWidget(
          onCreateProject: _showCreateDialog,
        ),
      ),
      floatingActionButton: FeatureTooltip(
        featureName: 'create_project',
        title: 'Create Project',
        description: 'Tap here to create your first project',
        child: FloatingActionButton(
          onPressed: _showCreateDialog,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
```

---

## ✅ Integration Checklist

### Onboarding
- [ ] Add onboarding check to app startup
- [ ] Add feature tooltips to key features
- [ ] Test onboarding flow
- [ ] Test tooltip dismissal

### Empty States
- [ ] Replace empty states in Projects screen
- [ ] Replace empty states in Tasks screen
- [ ] Replace empty states in Requests screen
- [ ] Replace empty states in Notifications screen
- [ ] Add empty state to search results
- [ ] Add network error widget to API calls

### Pull-to-Refresh
- [ ] Add to Projects screen
- [ ] Add to Tasks screen
- [ ] Add to Requests screen
- [ ] Add to Notifications screen
- [ ] Test refresh on empty lists
- [ ] Test refresh with data

### Infinite Scroll
- [ ] Implement pagination in Projects screen
- [ ] Implement pagination in Tasks screen
- [ ] Implement pagination in Requests screen
- [ ] Test scroll threshold
- [ ] Test loading indicators
- [ ] Verify hasMore logic

### Search History
- [ ] Add to search screen
- [ ] Test history persistence
- [ ] Test clear history
- [ ] Test search from history

### Recent Items
- [ ] Add to home screen
- [ ] Track project access
- [ ] Track task access
- [ ] Test recent items display
- [ ] Test navigation from recent items

---

## 🎉 You're Done!

Your app now has production-level UX polish! Users will enjoy:
- Clear onboarding for first-time users
- Helpful empty states that guide actions
- Smooth pull-to-refresh on all lists
- Seamless infinite scroll pagination
- Quick access to search history
- Fast navigation with recent items

**Test everything and enjoy the polished experience!** 🚀
