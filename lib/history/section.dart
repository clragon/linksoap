import 'package:flutter/material.dart';
import 'package:linksoap/core/storage.dart';
import 'package:diff_match_patch/diff_match_patch.dart' as dmp;

class HistorySection extends StatelessWidget {
  final Storage storage;
  final List<Map<String, String>> history;
  final bool historyEnabled;
  final VoidCallback onDataChanged;

  const HistorySection({
    super.key,
    required this.storage,
    required this.history,
    required this.historyEnabled,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              const Icon(Icons.history),
              const SizedBox(width: 12),
              Text(
                'History',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              if (historyEnabled)
                PopupMenuButton<VoidCallback>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (callback) => callback(),
                  itemBuilder: (context) => [
                    PopupMenuItem<VoidCallback>(
                      value: () async {
                        await storage.setHistoryEnabled(false);
                        onDataChanged();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.pause),
                          SizedBox(width: 12),
                          Text('Disable tracking'),
                        ],
                      ),
                    ),
                    if (history.isNotEmpty)
                      PopupMenuItem<VoidCallback>(
                        value: () async {
                          await storage.clearHistory();
                          onDataChanged();
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.delete_sweep),
                            SizedBox(width: 12),
                            Text('Clear history'),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        if (!historyEnabled)
          SliverToBoxAdapter(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: 'History tracking is disabled. ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: InkWell(
                      onTap: () async {
                        await storage.setHistoryEnabled(true);
                        onDataChanged();
                      },
                      child: Text(
                        'Enable',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                          fontSize:
                              Theme.of(context).textTheme.bodySmall?.fontSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (historyEnabled && history.isEmpty)
          SliverToBoxAdapter(
            child: Text(
              'Nothing here yet! Copy some links to see the magic work!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        if (historyEnabled && history.isNotEmpty)
          SliverToBoxAdapter(
            child: Text(
              'Your latest scrubbed links',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        if (historyEnabled && history.isNotEmpty)
          SliverList.builder(
            itemCount: history.length > 10 ? 10 : history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              final before = entry['before'] ?? '';
              final after = entry['after'] ?? '';
              final hasChange = before != after;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: hasChange
                      ? _buildDiffText(context, before, after)
                      : Text(
                          after,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                ),
              );
            },
          ),
        if (historyEnabled && history.length > 10)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '... and ${history.length - 10} more',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDiffText(BuildContext context, String before, String after) {
    final diffs = dmp.diff(before, after);
    final spans = <TextSpan>[];

    for (final diff in diffs) {
      final text = diff.text;
      switch (diff.operation) {
        case dmp.DIFF_DELETE:
          spans.add(TextSpan(
            text: text,
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              backgroundColor: Colors.red.shade900.withAlpha(100),
              color: Colors.red.shade300,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ));
          break;
        case dmp.DIFF_INSERT:
          spans.add(TextSpan(
            text: text,
            style: TextStyle(
              backgroundColor: Colors.green.shade900.withAlpha(100),
              color: Colors.green.shade300,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ));
          break;
        case dmp.DIFF_EQUAL:
          spans.add(TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ));
          break;
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
