import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'data/curated_kernel_repository.dart';
import 'services/idea_safety_policy.dart';
import 'services/local_excuse_engine.dart';
import 'services/prototype_request_mapper.dart';

void main() {
  runApp(ExcuseMeApp(client: LocalIdeaClient()));
}

class IdeaRequest {
  const IdeaRequest({
    required this.situation,
    required this.relationship,
    required this.urgency,
    required this.tone,
  });

  final String situation;
  final String relationship;
  final String urgency;
  final String tone;
}

abstract class IdeaClient {
  Future<String> generate(IdeaRequest request);
}

class LocalIdeaClient implements IdeaClient {
  final LocalExcuseEngine _engine = LocalExcuseEngine(
    CuratedKernelRepository.englishAlpha(),
  );
  final PrototypeRequestMapper _mapper = const PrototypeRequestMapper();
  String? _previousKernelId;
  String? _previousSelectionKey;

  @override
  Future<String> generate(IdeaRequest request) async {
    final structuredRequest = _mapper.map(
      situation: request.situation,
      relationship: request.relationship,
      urgency: request.urgency,
      tone: request.tone,
    );
    final result = _engine.generate(
      structuredRequest,
      previousKernelId: structuredRequest.selectionKey == _previousSelectionKey
          ? _previousKernelId
          : null,
    );
    _previousKernelId = result.kernelId;
    _previousSelectionKey = structuredRequest.selectionKey;
    return result.idea;
  }
}

class LocalIdeaGenerator {
  final LocalExcuseEngine _engine = LocalExcuseEngine(
    CuratedKernelRepository.englishAlpha(),
  );
  final PrototypeRequestMapper _mapper = const PrototypeRequestMapper();

  String generate(IdeaRequest request) {
    return _engine
        .generate(
          _mapper.map(
            situation: request.situation,
            relationship: request.relationship,
            urgency: request.urgency,
            tone: request.tone,
          ),
        )
        .idea;
  }
}

class IdeaGuardrails {
  static bool isSafeIdea(String value) => IdeaSafetyPolicy.isSafeIdea(value);
}

class ExcuseMeApp extends StatelessWidget {
  const ExcuseMeApp({super.key, required this.client});

  final IdeaClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excuse Me',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff315c4b)),
        useMaterial3: false,
      ),
      home: ExcuseMePage(client: client),
    );
  }
}

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

  @override
  void dispose() {
    _situationController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final situation = _situationController.text.trim();
    if (situation.isEmpty) {
      setState(
        () => _error = 'Describe the situation before generating an idea.',
      );
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
      setState(() => _error = 'Unable to generate an idea. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _idea!));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Idea copied.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Excuse Me')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Find a way to explain it.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Get one private, adaptable idea - never a message to send.',
            ),
            const SizedBox(height: 24),
            TextField(
              key: const Key('situation-field'),
              controller: _situationController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'What happened?',
                hintText: 'Describe the situation',
              ),
            ),
            const SizedBox(height: 12),
            _selector('Relationship', _relationship, const [
              'Friend',
              'Family',
              'Coworker',
              'Client',
            ], (value) => setState(() => _relationship = value)),
            _selector('Urgency', _urgency, const [
              'Soon',
              'Today',
              'This week',
            ], (value) => setState(() => _urgency = value)),
            _selector('Tone', _tone, const [
              'Warm',
              'Direct',
              'Professional',
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
                  : Text(_idea == null ? 'Generate idea' : 'Regenerate'),
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
              Text('Your idea', style: Theme.of(context).textTheme.titleLarge),
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
                    child: const Text('Regenerate'),
                  ),
                  OutlinedButton(onPressed: _copy, child: const Text('Copy')),
                  OutlinedButton(
                    onPressed: () => Share.share(_idea!),
                    child: const Text('Share'),
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
