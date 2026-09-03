import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/idea_request.dart';
import '../l10n/app_localizations.dart';
import '../services/idea_client.dart';

class ExcuseMePage extends StatefulWidget {
  const ExcuseMePage({super.key, required this.client});

  final IdeaClient client;

  @override
  State<ExcuseMePage> createState() => _ExcuseMePageState();
}

class _ExcuseMePageState extends State<ExcuseMePage> {
  final _situationController = TextEditingController();
  String _relationship = 'Friend';
  String _urgency = 'Soon';
  String _tone = 'Warm';
  String? _idea;
  String? _error;
  bool _loading = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _situationController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final situation = _situationController.text.trim();
    if (situation.isEmpty) {
      setState(() => _error = l10n.oldFormEmptyError);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final idea = await widget.client.generate(
        IdeaRequest(
          situation: situation,
          relationship: _relationship,
          urgency: _urgency,
          tone: _tone,
        ),
      );
      if (!mounted) return;
      setState(() => _idea = idea);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.generationError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _idea!));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.ideaCopied)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.oldFormTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.oldFormHeading,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(l10n.oldFormSubheading),
            const SizedBox(height: 24),
            TextField(
              key: const Key('situation-field'),
              controller: _situationController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.oldFormSituationLabel,
                hintText: l10n.oldFormSituationHint,
              ),
            ),
            const SizedBox(height: 12),
            _selector(l10n.oldFormRelationshipLabel, _relationship, [
              l10n.oldFormFriend,
              l10n.oldFormFamily,
              l10n.oldFormCoworker,
              l10n.oldFormClient,
            ], (value) => setState(() => _relationship = value)),
            _selector(l10n.oldFormUrgencyLabel, _urgency, [
              l10n.oldFormSoon,
              l10n.oldFormToday,
              l10n.oldFormThisWeek,
            ], (value) => setState(() => _urgency = value)),
            _selector(l10n.oldFormToneLabel, _tone, [
              l10n.oldFormToneWarm,
              l10n.oldFormToneDirect,
              l10n.oldFormToneProfessional,
            ], (value) => setState(() => _tone = value)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _generate,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _idea == null
                          ? l10n.oldFormGenerateButton
                          : l10n.oldFormRegenerateButton,
                    ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_idea != null) ...[
              const SizedBox(height: 28),
              Text(
                l10n.oldFormResultTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_idea!),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _generate,
                    child: Text(l10n.oldFormRegenerateButton),
                  ),
                  OutlinedButton(
                    onPressed: _copy,
                    child: Text(l10n.copyButton),
                  ),
                  OutlinedButton(
                    onPressed: () => Share.share(_idea!),
                    child: Text(l10n.shareButton),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _selector(
    String label,
    String selected,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: selected,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: options
            .map(
              (option) => DropdownMenuItem(value: option, child: Text(option)),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}
