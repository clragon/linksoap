import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:linksoap/core/storage.dart';
import 'package:linksoap/detergent/model.dart';
import 'package:linksoap/detergent/editor.dart';

class DetergentsSection extends StatelessWidget {
  final Storage storage;
  final List<Detergent> detergents;
  final VoidCallback onDataChanged;

  const DetergentsSection({
    super.key,
    required this.storage,
    required this.detergents,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              const Icon(Icons.cleaning_services),
              const SizedBox(width: 12),
              Text(
                'Detergents',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  final result = await Navigator.push<Detergent>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetergentEditorScreen(),
                    ),
                  );
                  if (result != null) {
                    detergents.add(result);
                    await storage.saveDetergents(detergents);
                    onDataChanged();
                  }
                },
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Text(
            'Query parameter cleaners',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverReorderableList(
          itemCount: detergents.length,
          onReorder: (oldIndex, newIndex) async {
            if (newIndex > oldIndex) newIndex--;
            final item = detergents.removeAt(oldIndex);
            detergents.insert(newIndex, item);
            await storage.saveDetergents(detergents);
            onDataChanged();
          },
          itemBuilder: (context, index) {
            final detergent = detergents[index];
            return _buildDetergentTile(context, detergent, index);
          },
        ),
      ],
    );
  }

  Widget _buildDetergentTile(
      BuildContext context, Detergent detergent, int index) {
    return Slidable(
      key: ValueKey(detergent.name + detergent.domain),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              final updated = detergents
                  .map((d) =>
                      d == detergent ? d.copyWith(enabled: !d.enabled) : d)
                  .toList();
              await storage.saveDetergents(updated);
              onDataChanged();
            },
            backgroundColor: detergent.enabled ? Colors.orange : Colors.green,
            foregroundColor: Colors.white,
            icon: detergent.enabled ? Icons.pause : Icons.play_arrow,
            label: detergent.enabled ? 'Disable' : 'Enable',
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
                  title: const Text('Delete Detergent'),
                  content: Text('Delete "${detergent.name}"?'),
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
                final updated =
                    detergents.where((d) => d != detergent).toList();
                await storage.saveDetergents(updated);
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
        color: detergent.enabled
            ? null
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withAlpha(100),
        child: GestureDetector(
          onSecondaryTapDown: (details) {
            _showContextMenu(context, details.globalPosition, detergent);
          },
          onLongPressStart: (details) {
            _showContextMenu(context, details.globalPosition, detergent);
          },
          child: ListTile(
            title: Text(
              detergent.name,
              style: detergent.enabled
                  ? null
                  : TextStyle(
                      color: Theme.of(context).disabledColor,
                      decoration: TextDecoration.lineThrough,
                    ),
            ),
            subtitle: Text(
              '${detergent.domain}: remove ${detergent.rule}',
              style: TextStyle(
                fontFamily: 'monospace',
                color: detergent.enabled
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
    Detergent detergent,
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
            final updated = detergents
                .map(
                    (d) => d == detergent ? d.copyWith(enabled: !d.enabled) : d)
                .toList();
            await storage.saveDetergents(updated);
            onDataChanged();
          },
          child: Row(
            children: [
              Icon(detergent.enabled ? Icons.pause : Icons.play_arrow),
              const SizedBox(width: 12),
              Text(detergent.enabled ? 'Disable' : 'Enable'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () async {
            final result = await Navigator.push<Detergent>(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DetergentEditorScreen(detergent: detergent),
              ),
            );
            if (result != null) {
              final updated =
                  detergents.map((d) => d == detergent ? result : d).toList();
              await storage.saveDetergents(updated);
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
                title: const Text('Delete Detergent'),
                content: Text('Delete "${detergent.name}"?'),
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
              final updated = detergents.where((d) => d != detergent).toList();
              await storage.saveDetergents(updated);
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
