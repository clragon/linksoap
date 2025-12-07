import 'package:flutter/material.dart';
import 'package:linksoap/core/laundromat.dart';
import 'package:linksoap/core/desktop_dialog.dart';
import 'package:linksoap/core/storage.dart';
import 'package:linksoap/detergent/model.dart';
import 'package:linksoap/detergent/section.dart';
import 'package:linksoap/history/section.dart';
import 'package:linksoap/home/setup.dart';
import 'package:linksoap/home/tutorial.dart';
import 'package:linksoap/home/stats.dart';
import 'package:linksoap/settings/screen.dart';
import 'package:linksoap/softener/model.dart';
import 'package:linksoap/softener/section.dart';

class HomePage extends StatefulWidget {
  final Storage storage;

  const HomePage({super.key, required this.storage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Softener> softeners = [];
  List<Detergent> detergents = [];
  int cleanedCount = 0;
  List<Map<String, String>> history = [];
  bool historyEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    Laundromat.instance.addListener(_loadData);
  }

  @override
  void dispose() {
    Laundromat.instance.removeListener(_loadData);
    super.dispose();
  }

  void _loadData() {
    setState(() {
      softeners = widget.storage.loadSofteners();
      detergents = widget.storage.loadDetergents();
      cleanedCount = widget.storage.getCleanedCount();
      history = widget.storage.loadHistory();
      historyEnabled = widget.storage.isHistoryEnabled();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding =
        screenWidth > 800 ? (screenWidth - 800) / 2 : 16.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 16),
            sliver: SliverMainAxisGroup(
              slivers: [
                StatsSection(cleanedCount: cleanedCount),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                const SetupSection(),
                TutorialSection(storage: widget.storage),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SoftenersSection(
                  storage: widget.storage,
                  softeners: softeners,
                  onDataChanged: _loadData,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                DetergentsSection(
                  storage: widget.storage,
                  detergents: detergents,
                  onDataChanged: _loadData,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                HistorySection(
                  storage: widget.storage,
                  history: history,
                  historyEnabled: historyEnabled,
                  onDataChanged: _loadData,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Icon(Icons.settings),
                      const SizedBox(width: 12),
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.chevron_right),
                        label: const Text('Open'),
                        onPressed: () => showDesktopDialog(
                          context: context,
                          child: const SettingsScreen(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
