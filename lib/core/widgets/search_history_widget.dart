import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage search history
class SearchHistoryService {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;

  /// Get search history
  static Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_searchHistoryKey) ?? [];
    return historyJson;
  }

  /// Add search query to history
  static Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final history = await getSearchHistory();

    // Remove if already exists (to move to top)
    history.remove(query);

    // Add to beginning
    history.insert(0, query);

    // Keep only max items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    await prefs.setStringList(_searchHistoryKey, history);
  }

  /// Remove specific query from history
  static Future<void> removeFromHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getSearchHistory();
    history.remove(query);
    await prefs.setStringList(_searchHistoryKey, history);
  }

  /// Clear all search history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }
}

/// Search history widget showing recent searches
class SearchHistoryWidget extends StatefulWidget {
  final Function(String) onSearchSelected;

  const SearchHistoryWidget({
    super.key,
    required this.onSearchSelected,
  });

  @override
  State<SearchHistoryWidget> createState() => _SearchHistoryWidgetState();
}

class _SearchHistoryWidgetState extends State<SearchHistoryWidget> {
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await SearchHistoryService.getSearchHistory();
    setState(() {
      _history = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              TextButton(
                onPressed: () async {
                  await SearchHistoryService.clearHistory();
                  _loadHistory();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _history.length,
          itemBuilder: (context, index) {
            final query = _history[index];
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(query),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () async {
                  await SearchHistoryService.removeFromHistory(query);
                  _loadHistory();
                },
              ),
              onTap: () => widget.onSearchSelected(query),
            );
          },
        ),
      ],
    );
  }
}

/// Service to manage recent items
class RecentItemsService {
  static const String _recentProjectsKey = 'recent_projects';
  static const String _recentTasksKey = 'recent_tasks';
  static const int _maxRecentItems = 5;

  /// Add project to recent items
  static Future<void> addRecentProject(String projectId) async {
    await _addRecentItem(_recentProjectsKey, projectId);
  }

  /// Get recent projects
  static Future<List<String>> getRecentProjects() async {
    return await _getRecentItems(_recentProjectsKey);
  }

  /// Add task to recent items
  static Future<void> addRecentTask(String taskId) async {
    await _addRecentItem(_recentTasksKey, taskId);
  }

  /// Get recent tasks
  static Future<List<String>> getRecentTasks() async {
    return await _getRecentItems(_recentTasksKey);
  }

  static Future<void> _addRecentItem(String key, String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(key) ?? [];

    // Remove if already exists
    items.remove(itemId);

    // Add to beginning
    items.insert(0, itemId);

    // Keep only max items
    if (items.length > _maxRecentItems) {
      items.removeRange(_maxRecentItems, items.length);
    }

    await prefs.setStringList(key, items);
  }

  static Future<List<String>> _getRecentItems(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  /// Clear all recent items
  static Future<void> clearAllRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentProjectsKey);
    await prefs.remove(_recentTasksKey);
  }
}

/// Widget showing recent items shortcuts
class RecentItemsWidget extends StatelessWidget {
  final List<RecentItem> items;
  final String title;
  final Function(String) onItemTap;

  const RecentItemsWidget({
    super.key,
    required this.items,
    required this.title,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: InkWell(
                    onTap: () => onItemTap(item.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item.icon, size: 24, color: item.color),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Data model for recent items
class RecentItem {
  final String id;
  final String title;
  final IconData icon;
  final Color? color;

  RecentItem({
    required this.id,
    required this.title,
    required this.icon,
    this.color,
  });
}
