import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

void main() {
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  runApp(ExcuseMeApp(client: ApiIdeaClient(baseUrl: apiBaseUrl)));
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

  Map<String, String> toJson() => {
        'situation': situation,
        'relationship': relationship,
        'urgency': urgency,
        'tone': tone,
      };
}

abstract class IdeaClient {
  Future<String> generate(IdeaRequest request);
}

typedef IdeaTransport = Future<String> Function(IdeaRequest request);

class ApiIdeaClient implements IdeaClient {
  ApiIdeaClient({required this.baseUrl, this._transport});

  final String baseUrl;
  final IdeaTransport? _transport;
  final LocalIdeaGenerator _fallback = LocalIdeaGenerator();

  @override
  Future<String> generate(IdeaRequest request) async {
    if (baseUrl.isEmpty && _transport == null) return _fallback.generate(request);

    try {
      final idea = await (_transport?.call(request) ?? _post(request));
      return IdeaGuardrails.isSafeIdea(idea) ? idea.trim() : _fallback.generate(request);
    } catch (_) {
      return _fallback.generate(request);
    }
  }

  Future<String> _post(IdeaRequest request) async {
    final response = await http
        .post(
          Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/api/generate'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw const FormatException('Generation failed');
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic> || body['idea'] is! String) {
      throw const FormatException('Invalid response');
    }
    return body['idea'] as String;
  }
}

class LocalIdeaGenerator {
  String generate(IdeaRequest request) {
    final urgency = request.urgency.toLowerCase() == 'soon'
        ? 'time-sensitive issue'
        : '${request.urgency.toLowerCase()} scheduling conflict';
    return 'Idea: Briefly attribute the delay to a $urgency, acknowledge your '
        '${request.relationship.toLowerCase()}, and keep the explanation '
        '${request.tone.toLowerCase()}.';
  }
}

class IdeaGuardrails {
  static bool isSafeIdea(String value) {
    final idea = value.trim();
    if (!idea.startsWith('Idea:') || idea.length > 280) return false;
    if (RegExp(r'''['"“”]''').hasMatch(idea)) return false;
    if (RegExp(r'^(hello|hi|dear|hey)\b', caseSensitive: false).hasMatch(idea)) {
      return false;
    }
    if (RegExp(r'\b(regards|sincerely|best|thanks|thank you)\b', caseSensitive: false)
        .hasMatch(idea)) {
      return false;
    }
    return !RegExp(r"\b(i|i'm|i am|my|me)\b", caseSensitive: false).hasMatch(idea);
  }
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
      setState(() => _error = 'Describe the situation before generating an idea.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final idea = await widget.client.generate(IdeaRequest(
        situation: situation,
        relationship: _relationship,
        urgency: _urgency,
        tone: _tone,
      ));
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
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Idea copied.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Excuse Me')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Find a way to explain it.', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Get one private, adaptable idea - never a message to send.'),
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
            _selector('Relationship', _relationship, const ['Friend', 'Family', 'Coworker', 'Client'], (value) => setState(() => _relationship = value)),
            _selector('Urgency', _urgency, const ['Soon', 'Today', 'This week'], (value) => setState(() => _urgency = value)),
            _selector('Tone', _tone, const ['Warm', 'Direct', 'Professional'], (value) => setState(() => _tone = value)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _generate,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_idea == null ? 'Generate idea' : 'Regenerate'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (_idea != null) ...[
              const SizedBox(height: 28),
              Text('Your idea', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(_idea!))),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(onPressed: _generate, child: const Text('Regenerate')),
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

  Widget _selector(String label, String selected, List<String> options, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: selected,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}
