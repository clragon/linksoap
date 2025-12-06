import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:linksoap/core/desktop_dialog.dart';
import 'package:linksoap/core/storage.dart';
import 'package:linksoap/softener/model.dart';
import 'package:linksoap/softener/editor.dart';

class SoftenersSection extends StatelessWidget {
  final Storage storage;
  final List<Softener> softeners;
  final VoidCallback onDataChanged;

  const SoftenersSection({
    super.key,
    required this.storage,
    required this.softeners,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              const Icon(Icons.auto_fix_high),
              const SizedBox(width: 12),
              Text(
                'Softeners',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  final result = await Navigator.push<Softener>(
                    context,
                    DialogRoute(
                      context: context,
                      builder: (context) =>
                          DesktopDialog(child: const SoftenerEditorScreen()),
                      fullscreenDialog: true,
                    ),
                  );
                  if (result != null) {
                    softeners.add(result);
                    await storage.saveSofteners(softeners);
                    onDataChanged();
                  }
                },
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Text(
            'Hostname replacements',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverReorderableList(
          itemCount: softeners.length,
          onReorder: (oldIndex, newIndex) async {
            if (newIndex > oldIndex) newIndex--;
            final item = softeners.removeAt(oldIndex);
            softeners.insert(newIndex, item);
            await storage.saveSofteners(softeners);
            onDataChanged();
          },
          itemBuilder: (context, index) {
            final softener = softeners[index];
            return _buildSoftenerTile(context, softener, index);
          },
        ),
      ],
    );
  }

  Widget _buildSoftenerTile(
      BuildContext context, Softener softener, int index) {
    return Slidable(
      key: ValueKey(softener.name + softener.domain),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              final updated = softeners
                  .map((s) =>
                      s == softener ? s.copyWith(enabled: !s.enabled) : s)
                  .toList();
              await storage.saveSofteners(updated);
              onDataChanged();
            },
            backgroundColor: softener.enabled ? Colors.orange : Colors.green,
            foregroundColor: Colors.white,
            icon: softener.enabled ? Icons.pause : Icons.play_arrow,
            label: softener.enabled ? 'Disable' : 'Enable',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (ctx) async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Softener'),
                  content: Text('Delete "${softener.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                final updated = softeners.where((s) => s != softener).toList();
                await storage.saveSofteners(updated);
                onDataChanged();
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: softener.enabled
            ? null
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withAlpha(100),
        child: GestureDetector(
          onSecondaryTapDown: (details) {
            _showContextMenu(context, details.globalPosition, softener);
          },
          onLongPressStart: (details) {
            _showContextMenu(context, details.globalPosition, softener);
          },
          child: ListTile(
            title: Text(
              softener.name,
              style: softener.enabled
                  ? null
                  : TextStyle(
                      color: Theme.of(context).disabledColor,
                      decoration: TextDecoration.lineThrough,
                    ),
            ),
            subtitle: Text(
              '${softener.domain} → ${softener.replacement}',
              style: TextStyle(
                fontFamily: 'monospace',
                color: softener.enabled
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).disabledColor,
              ),
            ),
            trailing: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(
    BuildContext context,
    Offset position,
    Softener softener,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          onTap: () async {
            final updated = softeners
                .map((s) => s == softener ? s.copyWith(enabled: !s.enabled) : s)
                .toList();
            await storage.saveSofteners(updated);
            onDataChanged();
          },
          child: Row(
            children: [
              Icon(
                softener.enabled ? Icons.pause : Icons.play_arrow,
                color: softener.enabled ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 12),
              Text(
                softener.enabled ? 'Disable' : 'Enable',
                style: TextStyle(
                  color: softener.enabled ? Colors.orange : Colors.green,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () async {
            final result = await Navigator.push<Softener>(
              context,
              DialogRoute(
                context: context,
                builder: (context) => DesktopDialog(
                    child: SoftenerEditorScreen(softener: softener)),
                fullscreenDialog: true,
              ),
            );
            if (result != null) {
              final updated =
                  softeners.map((s) => s == softener ? result : s).toList();
              await storage.saveSofteners(updated);
              onDataChanged();
            }
          },
          child: const Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 12),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Softener'),
                content: Text('Delete "${softener.name}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              final updated = softeners.where((s) => s != softener).toList();
              await storage.saveSofteners(updated);
              onDataChanged();
            }
          },
          child: const Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
