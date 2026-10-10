import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Community partners (decision D6). Links open in the browser or Reddit
/// app via an Android intent; this app itself has no network access.
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No app found to open this link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('r/POIS', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  const Text(
                      'An active Reddit community where people share '
                      'experiences, questions and what they have tried.'),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        _open(context, 'https://www.reddit.com/r/POIS/'),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open r/POIS'),
                  ),
                ],
              ),
            ),
          ),
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('POISCenter forum', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  const Text(
                      'A long-running forum with detailed threads on symptoms, '
                      'types and treatment summaries.'),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        _open(context, 'https://poiscenter.com/forums/'),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open POISCenter'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('A note on advice'),
            subtitle: const Text(
                'Community posts are personal experiences, not medical '
                'advice. Talk to a clinician before starting, stopping or '
                'combining any treatment.'),
            textColor: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
