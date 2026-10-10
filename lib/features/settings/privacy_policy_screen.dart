import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// In-app privacy policy (PRD §9.1). The same Markdown file is published to
/// GitHub Pages for the Play listing (docs/privacy.md, kept identical by a
/// test). Works offline.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy policy')),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/legal/privacy_policy.md'),
        builder: (context, snap) => snap.hasData
            ? SimpleMarkdown(snap.data!)
            : const SizedBox.shrink(),
      ),
    );
  }
}

/// Renders the small Markdown subset our legal text uses: `#`/`##`
/// headings, paragraphs, `- ` bullets and `**bold**`. Kept deliberately tiny
/// to avoid a dependency.
class SimpleMarkdown extends StatelessWidget {
  const SimpleMarkdown(this.source, {super.key});
  final String source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocks = <Widget>[];
    for (final raw in source.split('\n')) {
      final line = raw.trimRight();
      if (line.isEmpty) continue;
      if (line.startsWith('# ')) {
        blocks.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(line.substring(2), style: theme.textTheme.headlineSmall),
        ));
      } else if (line.startsWith('## ')) {
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(line.substring(3), style: theme.textTheme.titleMedium),
        ));
      } else if (line.startsWith('- ')) {
        blocks.add(Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  '),
              Expanded(child: _inline(line.substring(2), theme)),
            ],
          ),
        ));
      } else {
        blocks.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _inline(line, theme),
        ));
      }
    }
    return SelectionArea(
      child: ListView(padding: const EdgeInsets.all(16), children: blocks),
    );
  }

  /// `**bold**` spans; everything else is plain text.
  static Widget _inline(String text, ThemeData theme) {
    final parts = text.split('**');
    return Text.rich(
      TextSpan(children: [
        for (var i = 0; i < parts.length; i++)
          TextSpan(
            text: parts[i],
            style: i.isOdd ? const TextStyle(fontWeight: FontWeight.w600) : null,
          ),
      ]),
      style: theme.textTheme.bodyMedium,
    );
  }
}
