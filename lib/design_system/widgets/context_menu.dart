import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// Show context menu at position
Future<T?> showContextMenu<T>({
  required BuildContext context,
  required Offset position,
  required List<ContextMenuItem<T>> items,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  
  return await showMenu<T>(
    context: context,
    position: RelativeRect.fromRect(
      position & const Size(40, 40),
      Offset.zero & overlay.size,
    ),
    items: items.map((item) {
      return PopupMenuItem<T>(
        value: item.value,
        enabled: item.enabled,
        child: Row(
          children: [
            Icon(
              item.icon,
              color: item.color ?? Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              item.label,
              style: TextStyle(
                color: item.color ?? Theme.of(context).colorScheme.onSurface,
                fontWeight: item.destructive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }).toList(),
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
    ),
  );
}

/// Context menu item configuration
class ContextMenuItem<T> {
  const ContextMenuItem({
    required this.value,
    required this.icon,
    required this.label,
    this.color,
    this.enabled = true,
    this.destructive = false,
  });

  final T value;
  final IconData icon;
  final String label;
  final Color? color;
  final bool enabled;
  final bool destructive;
}

/// Widget that shows context menu on long press
class ContextMenuRegion<T> extends StatelessWidget {
  const ContextMenuRegion({
    super.key,
    required this.child,
    required this.items,
    required this.onSelected,
  });

  final Widget child;
  final List<ContextMenuItem<T>> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) async {
        final result = await showContextMenu<T>(
          context: context,
          position: details.globalPosition,
          items: items,
        );
        
        if (result != null) {
          onSelected(result);
        }
      },
      child: child,
    );
  }
}

/// Bottom sheet context menu (alternative for mobile)
Future<T?> showBottomContextMenu<T>({
  required BuildContext context,
  required List<ContextMenuItem<T>> items,
  String? title,
}) async {
  return await showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(),
              ],
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    enabled: item.enabled,
                    leading: Icon(
                      item.icon,
                      color: item.color ?? Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: item.color ?? Theme.of(context).colorScheme.onSurface,
                        fontWeight: item.destructive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(item.value),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      );
    },
  );
}
