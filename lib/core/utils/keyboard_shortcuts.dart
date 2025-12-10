import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcut manager for quick actions
/// Provides command palette and keyboard shortcuts for common operations

/// Keyboard shortcut definition
class KeyboardShortcut {
  final String id;
  final String label;
  final String description;
  final LogicalKeySet keys;
  final VoidCallback action;
  final IconData? icon;
  final bool enabled;
  
  const KeyboardShortcut({
    required this.id,
    required this.label,
    required this.description,
    required this.keys,
    required this.action,
    this.icon,
    this.enabled = true,
  });
  
  /// Get human-readable key combination
  String get keysLabel {
    final triggers = keys.triggers.toList();
    final labels = <String>[];
    
    for (final key in triggers) {
      if (key == LogicalKeyboardKey.control || key == LogicalKeyboardKey.controlLeft || key == LogicalKeyboardKey.controlRight) {
        labels.add('Ctrl');
      } else if (key == LogicalKeyboardKey.shift || key == LogicalKeyboardKey.shiftLeft || key == LogicalKeyboardKey.shiftRight) {
        labels.add('Shift');
      } else if (key == LogicalKeyboardKey.alt || key == LogicalKeyboardKey.altLeft || key == LogicalKeyboardKey.altRight) {
        labels.add('Alt');
      } else if (key == LogicalKeyboardKey.meta || key == LogicalKeyboardKey.metaLeft || key == LogicalKeyboardKey.metaRight) {
        labels.add('Cmd');
      } else {
        labels.add(key.keyLabel.toUpperCase());
      }
    }
    
    return labels.join(' + ');
  }
}

/// Shortcut category for organization
enum ShortcutCategory {
  navigation,
  tasks,
  projects,
  search,
  general,
}

/// Keyboard shortcuts registry
class ShortcutsRegistry {
  final Map<String, KeyboardShortcut> _shortcuts = {};
  final Map<ShortcutCategory, List<String>> _categories = {
    ShortcutCategory.navigation: [],
    ShortcutCategory.tasks: [],
    ShortcutCategory.projects: [],
    ShortcutCategory.search: [],
    ShortcutCategory.general: [],
  };
  
  /// Register a shortcut
  void register(KeyboardShortcut shortcut, ShortcutCategory category) {
    _shortcuts[shortcut.id] = shortcut;
    _categories[category]?.add(shortcut.id);
  }
  
  /// Unregister a shortcut
  void unregister(String id) {
    _shortcuts.remove(id);
    for (final list in _categories.values) {
      list.remove(id);
    }
  }
  
  /// Get all shortcuts
  List<KeyboardShortcut> get all => _shortcuts.values.toList();
  
  /// Get shortcuts by category
  List<KeyboardShortcut> getByCategory(ShortcutCategory category) {
    final ids = _categories[category] ?? [];
    return ids.map((id) => _shortcuts[id]).whereType<KeyboardShortcut>().toList();
  }
  
  /// Get shortcut by id
  KeyboardShortcut? getById(String id) => _shortcuts[id];
  
  /// Search shortcuts by label or description
  List<KeyboardShortcut> search(String query) {
    if (query.isEmpty) return all;
    
    final normalized = query.toLowerCase();
    return all.where((shortcut) =>
      shortcut.label.toLowerCase().contains(normalized) ||
      shortcut.description.toLowerCase().contains(normalized)
    ).toList();
  }
  
  /// Create map of shortcuts for Shortcuts widget
  Map<ShortcutActivator, Intent> toShortcutsMap() {
    final map = <ShortcutActivator, Intent>{};
    for (final shortcut in all.where((s) => s.enabled)) {
      map[shortcut.keys] = CallbackIntent(shortcut.action);
    }
    return map;
  }
}

/// Intent for callback shortcuts
class CallbackIntent extends Intent {
  final VoidCallback callback;
  const CallbackIntent(this.callback);
}

/// Action for callback shortcuts
class CallbackAction extends Action<CallbackIntent> {
  @override
  Object? invoke(CallbackIntent intent) {
    intent.callback();
    return null;
  }
}

/// Command palette for quick actions
class CommandPalette extends StatefulWidget {
  final ShortcutsRegistry registry;
  
  const CommandPalette({
    super.key,
    required this.registry,
  });
  
  @override
  State<CommandPalette> createState() => _CommandPaletteState();
  
  /// Show command palette as modal
  static Future<void> show(BuildContext context, ShortcutsRegistry registry) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 600,
          height: 500,
          child: CommandPalette(registry: registry),
        ),
      ),
    );
  }
}

class _CommandPaletteState extends State<CommandPalette> {
  final _searchController = TextEditingController();
  List<KeyboardShortcut> _filteredShortcuts = [];
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _filteredShortcuts = widget.registry.all;
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _filteredShortcuts = widget.registry.search(_searchController.text);
      _selectedIndex = 0;
    });
  }
  
  void _executeShortcut(KeyboardShortcut shortcut) {
    Navigator.of(context).pop();
    shortcut.action();
  }
  
  void _moveSelection(int delta) {
    setState(() {
      _selectedIndex = (_selectedIndex + delta).clamp(0, _filteredShortcuts.length - 1);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _moveSelection(1);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _moveSelection(-1);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (_filteredShortcuts.isNotEmpty) {
              _executeShortcut(_filteredShortcuts[_selectedIndex]);
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Type a command...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          
          // Results list
          Expanded(
            child: _filteredShortcuts.isEmpty
                ? const Center(child: Text('No commands found'))
                : ListView.builder(
                    itemCount: _filteredShortcuts.length,
                    itemBuilder: (context, index) {
                      final shortcut = _filteredShortcuts[index];
                      final isSelected = index == _selectedIndex;
                      
                      return ListTile(
                        selected: isSelected,
                        leading: Icon(shortcut.icon ?? Icons.flash_on),
                        title: Text(shortcut.label),
                        subtitle: Text(shortcut.description),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            shortcut.keysLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        onTap: () => _executeShortcut(shortcut),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Common keyboard shortcuts builder
class CommonShortcuts {
  /// Create standard app shortcuts
  static ShortcutsRegistry createStandard(BuildContext context) {
    final registry = ShortcutsRegistry();
    
    // Navigation shortcuts
    registry.register(
      KeyboardShortcut(
        id: 'go_calendar',
        label: 'Go to Calendar',
        description: 'Navigate to calendar view',
        keys: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1),
        icon: Icons.calendar_month,
        action: () => Navigator.of(context).pushNamed('/calendar'),
      ),
      ShortcutCategory.navigation,
    );
    
    registry.register(
      KeyboardShortcut(
        id: 'go_projects',
        label: 'Go to Projects',
        description: 'Navigate to projects view',
        keys: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2),
        icon: Icons.folder,
        action: () => Navigator.of(context).pushNamed('/projects'),
      ),
      ShortcutCategory.navigation,
    );
    
    // Search shortcuts
    registry.register(
      KeyboardShortcut(
        id: 'global_search',
        label: 'Global Search',
        description: 'Search across all tasks and projects',
        keys: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF),
        icon: Icons.search,
        action: () {
          // TODO: Open global search
        },
      ),
      ShortcutCategory.search,
    );
    
    // Task shortcuts
    registry.register(
      KeyboardShortcut(
        id: 'new_task',
        label: 'New Task',
        description: 'Create a new task',
        keys: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN),
        icon: Icons.add_task,
        action: () {
          // TODO: Open new task dialog
        },
      ),
      ShortcutCategory.tasks,
    );
    
    // Command palette
    registry.register(
      KeyboardShortcut(
        id: 'command_palette',
        label: 'Command Palette',
        description: 'Open command palette',
        keys: LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK),
        icon: Icons.command,
        action: () => CommandPalette.show(context, registry),
      ),
      ShortcutCategory.general,
    );
    
    return registry;
  }
}
