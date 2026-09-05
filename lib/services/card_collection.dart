import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/excuse_request.dart';
import 'idea_client.dart';

/// Only explicitly chosen cards are persisted, with their selected wording.
class CardCollection {
  static const storageKey = 'excuse_me.collection.v1';
  List<GeneratedIdea> _cards = [];
  List<GeneratedIdea> get cards => List.unmodifiable(_cards);
  Future<void>? _loading;
  Future<void> load() => _loading ??= _read().catchError((Object error) {
    _loading = null;
    throw error;
  });
  Future<void> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(storageKey) ?? [];
    _cards = raw.map((entry) {
      final data = jsonDecode(entry) as Map<String, dynamic>;
      return GeneratedIdea(
        idea: data['idea'] as String,
        kernelId: data['kernelId'] as String?,
        playfulName: data['playfulName'] as String?,
        family: data['family'] == null
            ? null
            : ExcuseFamily.values.byName(data['family'] as String),
        selectedTone: ExcuseTone.values.byName(data['tone'] as String),
      );
    }).toList();
  }

  static String identity(GeneratedIdea card) => card.kernelId ?? card.idea;
  Future<void> save(GeneratedIdea card) async {
    await load();
    final updated = [
      card,
      ..._cards.where((item) => identity(item) != identity(card)),
    ];
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setStringList(
      storageKey,
      updated
          .map(
            (item) => jsonEncode({
              'idea': item.idea,
              'kernelId': item.kernelId,
              'playfulName': item.playfulName,
              'family': item.family?.name,
              'tone': item.selectedTone.name,
            }),
          )
          .toList(),
    );
    if (!success) throw StateError('Could not save collection');
    _cards = updated;
  }
}
