import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/domain.dart';
import '../../core/native_bridge.dart';
import '../../data/export.dart';
import '../../data/app_settings.dart';
import '../../data/providers.dart';
import '../../notifications/check_in_scheduler.dart';
import '../lock/lock_gate.dart';
import '../../core/brand.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    Widget header(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        t,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          header('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  label: Text('System'),
                ),
              ],
              selected: {s.themeMode},
              onSelectionChanged: (v) =>
                  ctl.update((x) => x.copyWith(themeMode: v.first)),
            ),
          ),
          SwitchListTile(
            title: const Text('Wallpaper colours'),
            subtitle: const Text('Use Android dynamic colour'),
            value: s.dynamicColor,
            onChanged: (v) => ctl.update((x) => x.copyWith(dynamicColor: v)),
          ),
          header('Your records'),
          ListTile(
            leading: const Icon(Icons.medication_outlined),
            title: const Text('Treatments'),
            subtitle: const Text('What you take or have tried'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/treatments'),
          ),
          ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            title: const Text('Self-check'),
            subtitle: const Text('Retake the POIS self-check'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/self-check'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Doctor report'),
            subtitle: const Text('Create a PDF for an appointment'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/report'),
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export data'),
            subtitle: const Text('All your logs as a JSON file'),
            onTap: () => _export(context, ref),
          ),
          header('Check-ins'),
          ListTile(
            title: const Text('Your top 3 symptoms'),
            subtitle: Text(s.topSymptoms.map((e) => e.label).join(', ')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickTopSymptoms(context, ref),
          ),
          ListTile(
            title: const Text('Send a test reminder'),
            subtitle: const Text('Arrives in about a minute'),
            trailing: const Icon(Icons.notifications_active_outlined),
            onTap: () => _testReminder(context, ref),
          ),
          ListTile(
            title: const Text('Reminders not arriving?'),
            subtitle: const Text(
              'Some phones stop reminders to save battery. Allow this app '
              'to run in the background.',
            ),
            trailing: const Icon(Icons.battery_saver_outlined),
            onTap: NativeBridge.openBatterySettings,
          ),
          ListTile(
            title: const Text('Reminder text'),
            subtitle: Text(s.notificationText),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _editNotificationText(context, ref),
          ),
          header('Privacy'),
          SwitchListTile(
            title: const Text('App lock'),
            subtitle: const Text('Require your screen lock or fingerprint'),
            value: s.appLock,
            onChanged: (v) async {
              // Confirm the user can actually authenticate before enabling.
              if (v && !await LockController.authenticate('Turn on app lock')) {
                return;
              }
              ctl.update((x) => x.copyWith(appLock: v));
            },
          ),
          SwitchListTile(
            title: const Text('Hide in recent apps'),
            subtitle: const Text(
              'Blocks screenshots and hides content in the app switcher',
            ),
            value: s.secureScreen,
            onChanged: (v) => ctl.update((x) => x.copyWith(secureScreen: v)),
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Privacy policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/privacy'),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Delete all data',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Permanently erase everything in this app'),
            onTap: () => _deleteAll(context, ref),
          ),
          const ListTile(
            leading: Icon(Icons.wifi_off),
            title: Text('No internet access'),
            subtitle: Text(
              'This app has no network permission. Your data stays on '
              'this phone unless you export it.',
            ),
          ),
          header('About'),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send feedback'),
            subtitle: const Text('Report a problem or suggest an idea'),
            onTap: () => _feedback(context),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About $appName'),
            subtitle: const Text('Version and open-source licences'),
            onTap: () async {
              final info = await NativeBridge.appInfo();
              if (!context.mounted) return;
              showAboutDialog(
                context: context,
                applicationName: appName,
                applicationVersion: '${info['version']} (${info['build']})',
                applicationLegalese:
                    'A private, offline symptom journal. Not a medical device; '
                    'it does not diagnose or recommend treatment.',
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _testReminder(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!await CheckInScheduler.instance.requestPermission()) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Notifications are turned off for this app.'),
        ),
      );
      return;
    }
    await CheckInScheduler.instance.scheduleTest(
      ref.read(settingsProvider).notificationText,
    );
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Test reminder set for about 1 minute from now. If it '
          "doesn't arrive, tap \"Reminders not arriving?\".",
        ),
        duration: Duration(seconds: 6),
      ),
    );
  }

  Future<void> _feedback(BuildContext context) async {
    final info = await NativeBridge.appInfo();
    // Diagnostics only: never include anything the user has logged.
    final body =
        '\n\n---\n'
        'Please don\'t include personal health details.\n'
        '$appName ${info['version']} (${info['build']}) · '
        'Android ${info['android']} · ${info['device']}';
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query:
          'subject=${Uri.encodeComponent('$appName feedback')}'
          '&body=${Uri.encodeComponent(body)}',
    );
    if (!await launchUrl(uri) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email us at $supportEmail')),
      );
    }
  }

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.delete_forever_outlined,
          color: theme.colorScheme.error,
        ),
        title: const Text('Delete all data?'),
        content: const Text(
          'This permanently erases every event, check-in, treatment, '
          'self-check and setting, and cancels all reminders. It cannot be '
          'undone. Export first if you want to keep a copy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    // With app lock on, also require the device credential.
    if (ref.read(settingsProvider).appLock &&
        !await LockController.authenticate('Confirm deleting all data')) {
      return;
    }
    await ref.read(databaseProvider).deleteEverything();
    await CheckInScheduler.instance.cancelAll();
    ref.read(settingsProvider.notifier).update((_) => const AppSettings());
    if (context.mounted) context.go('/onboarding');
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('This file is not encrypted'),
        content: const Text(
          'The export contains everything you have logged, in plain text. '
          'Anyone who can open the file can read it. Store it somewhere '
          'private.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'share'),
            child: const Text('Share'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Save to device'),
          ),
        ],
      ),
    );
    if (choice == null) return;
    final bytes = await buildExport(ref.read(databaseProvider));
    final d = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final name = 'journal-export-${d.year}-${two(d.month)}-${two(d.day)}.json';
    if (choice == 'save') {
      final ok = await NativeBridge.saveDocument(
        name: name,
        mime: 'application/json',
        bytes: bytes,
      );
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Export saved')));
      }
    } else {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: 'application/json')],
          fileNameOverrides: [name],
        ),
      );
    }
  }

  Future<void> _pickTopSymptoms(BuildContext context, WidgetRef ref) async {
    final current = ref.read(settingsProvider).topSymptoms;
    final picked = await showDialog<List<SymptomCluster>>(
      context: context,
      builder: (_) => _TopSymptomsDialog(initial: current),
    );
    if (picked != null) {
      ref
          .read(settingsProvider.notifier)
          .update((x) => x.copyWith(topSymptoms: picked));
    }
  }

  Future<void> _editNotificationText(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final ctl = TextEditingController(
      text: ref.read(settingsProvider).notificationText,
    );
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder text'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          maxLength: 60,
          decoration: const InputDecoration(
            helperText: 'Keep it neutral; it can appear on your screen',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (text != null && text.isNotEmpty) {
      ref
          .read(settingsProvider.notifier)
          .update((x) => x.copyWith(notificationText: text));
    }
  }
}

class _TopSymptomsDialog extends StatefulWidget {
  const _TopSymptomsDialog({required this.initial});
  final List<SymptomCluster> initial;
  @override
  State<_TopSymptomsDialog> createState() => _TopSymptomsDialogState();
}

class _TopSymptomsDialogState extends State<_TopSymptomsDialog> {
  late final _sel = [...widget.initial];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick up to 3'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final s in SymptomCluster.values)
            FilterChip(
              avatar: Icon(s.icon, size: 18),
              label: Text(s.label),
              selected: _sel.contains(s),
              onSelected: (on) => setState(() {
                if (on && _sel.length < 3) _sel.add(s);
                if (!on) _sel.remove(s);
              }),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _sel.isEmpty ? null : () => Navigator.pop(context, _sel),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
