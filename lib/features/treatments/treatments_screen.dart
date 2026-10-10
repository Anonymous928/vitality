import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/treatment_repository.dart';

/// Treatment log (PRD §6.4): records only what the user enters, never
/// suggests anything.
class TreatmentsScreen extends ConsumerWidget {
  const TreatmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treatments = ref.watch(treatmentsProvider).value ?? const [];
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);

    String dates(Treatment t) {
      final start =
          t.startedAt == null ? 'Start not set' : loc.formatMediumDate(t.startedAt!);
      final end =
          t.endedAt == null ? 'ongoing' : loc.formatMediumDate(t.endedAt!);
      return '$start – $end';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Treatments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add treatment'),
      ),
      body: treatments.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.medication_outlined,
                        size: 56, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('Nothing logged yet',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text(
                      'Add anything you take or try: prescribed, over the '
                      'counter, supplements or diet changes. Your logs show '
                      'how episodes went with and without it.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: treatments.length,
              itemBuilder: (context, i) {
                final t = treatments[i];
                return ListTile(
                  leading: const Icon(Icons.medication_outlined),
                  title: Text(t.name),
                  subtitle: Text([
                    ?t.treatmentClass,
                    ?t.dose,
                    dates(t),
                  ].join(' · ')),
                  trailing: t.endedAt == null
                      ? Chip(
                          label: const Text('Ongoing'),
                          visualDensity: VisualDensity.compact,
                        )
                      : null,
                  onTap: () => _edit(context, t),
                );
              },
            ),
    );
  }

  void _edit(BuildContext context, Treatment? t) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => TreatmentEditScreen(treatment: t),
    ));
  }
}

class TreatmentEditScreen extends ConsumerStatefulWidget {
  const TreatmentEditScreen({super.key, this.treatment});
  final Treatment? treatment;

  @override
  ConsumerState<TreatmentEditScreen> createState() =>
      _TreatmentEditScreenState();
}

class _TreatmentEditScreenState extends ConsumerState<TreatmentEditScreen> {
  late final _name = TextEditingController(text: widget.treatment?.name);
  late final _dose = TextEditingController(text: widget.treatment?.dose);
  late final _prescriber =
      TextEditingController(text: widget.treatment?.prescriber);
  late String? _class = widget.treatment?.treatmentClass;
  late DateTime? _start = widget.treatment?.startedAt ?? DateTime.now();
  late DateTime? _end = widget.treatment?.endedAt;
  late bool _ongoing = widget.treatment == null || _end == null;

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _prescriber.dispose();
    super.dispose();
  }

  String? _clean(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  void _save() {
    if (_name.text.trim().isEmpty) return;
    ref.read(treatmentRepositoryProvider).save(
          id: widget.treatment?.id,
          name: _name.text.trim(),
          treatmentClass: _class,
          dose: _clean(_dose),
          prescriber: _clean(_prescriber),
          startedAt: _start,
          endedAt: _ongoing ? null : (_end ?? DateTime.now()),
        );
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this treatment?'),
        content: const Text('Your episode logs are not affected.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    ref.read(treatmentRepositoryProvider).delete(widget.treatment!.id);
    Navigator.of(context).pop();
  }

  Future<DateTime?> _pickDate(DateTime? initial) => showDatePicker(
        context: context,
        initialDate: initial ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.treatment == null ? 'Add treatment' : 'Edit treatment'),
        actions: [
          if (widget.treatment != null)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            autofocus: widget.treatment == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. the medicine, supplement or change you made',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DropdownMenu<String>(
            initialSelection: _class,
            expandedInsets: EdgeInsets.zero,
            label: const Text('Type (optional)'),
            dropdownMenuEntries: [
              for (final c in treatmentClasses)
                DropdownMenuEntry(value: c, label: c),
            ],
            onSelected: (v) => setState(() => _class = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dose,
            decoration: const InputDecoration(
              labelText: 'Dose (optional)',
              helperText: 'As you were told to take it. The app never suggests doses.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _prescriber,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Prescribed or suggested by (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: const Text('Started'),
            subtitle: Text(_start == null ? 'Not set' : loc.formatMediumDate(_start!)),
            onTap: () async {
              final d = await _pickDate(_start);
              if (d != null) setState(() => _start = d);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Still taking it'),
            value: _ongoing,
            onChanged: (v) => setState(() {
              _ongoing = v;
              if (!v) _end ??= DateTime.now();
            }),
          ),
          if (!_ongoing)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_busy_outlined),
              title: const Text('Stopped'),
              subtitle: Text(loc.formatMediumDate(_end ?? DateTime.now())),
              onTap: () async {
                final d = await _pickDate(_end);
                if (d != null) setState(() => _end = d);
              },
            ),
          const SizedBox(height: 16),
          Text(
            'Talk to your clinician before starting, stopping or combining '
            'treatments.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
