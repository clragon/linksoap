import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linksoap/core/storage.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorialSection extends StatefulWidget {
  final Storage storage;

  const TutorialSection({super.key, required this.storage});

  @override
  State<TutorialSection> createState() => _TutorialSectionState();
}

class _TutorialSectionState extends State<TutorialSection> {
  late bool tutorialExpanded;

  @override
  void initState() {
    super.initState();
    tutorialExpanded = widget.storage.isTutorialExpanded();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Card(
        margin: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('How Does This Work?'),
            initiallyExpanded: tutorialExpanded,
            onExpansionChanged: (expanded) {
              setState(() => tutorialExpanded = expanded);
              widget.storage.setTutorialExpanded(expanded);
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      const TextSpan(
                        text:
                            'LinkSoap automatically cleans URLs from your clipboard.\n\n',
                      ),
                      const TextSpan(
                        text: 'Softeners',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: ' replace hostnames using regex patterns.\n'
                            'Example: ',
                      ),
                      TextSpan(
                        text: r'twitter\.com',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const TextSpan(text: ' → '),
                      const TextSpan(
                        text: 'fxtwitter.com',
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                      const TextSpan(text: '\n\n'),
                      const TextSpan(
                        text: 'Detergents',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text:
                            ' remove query parameters matching regex patterns.\n'
                            'Example: ',
                      ),
                      TextSpan(
                        text: r'utm|ref|source',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const TextSpan(
                        text: ' removes utm_source, ref, etc.\n\n',
                      ),
                      const TextSpan(
                        text:
                            'Rules are applied sequentially from top to bottom.\n\n',
                      ),
                      const TextSpan(
                        text: 'Learn regex: ',
                      ),
                      TextSpan(
                        text: 'regexr.com',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('https://regexr.com'));
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
