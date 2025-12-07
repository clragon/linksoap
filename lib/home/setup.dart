import 'package:flutter/material.dart';
import 'package:linksoap/core/laundromat.dart';

class SetupSection extends StatefulWidget {
  const SetupSection({super.key});

  @override
  State<SetupSection> createState() => _SetupSectionState();
}

class _SetupSectionState extends State<SetupSection> {
  bool showSetupBoot = false;

  @override
  void initState() {
    super.initState();
    _checkSetupBoot();
  }

  Future<void> _checkSetupBoot() async {
    final isSetupBoot = await Laundromat.instance.isSetupBoot();
    if (isSetupBoot && mounted) {
      setState(() => showSetupBoot = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!showSetupBoot) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Card(
          margin: const EdgeInsets.all(0),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Why did the app just open?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      onPressed: () => setState(() => showSetupBoot = false),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'This was the first time you shared a link to LinkSoap. '
                  'The app needed to set up background processing. '
                  'Next time you share a link, it will be cleaned instantly without opening the app!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your link has been cleaned and copied to your clipboard.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
