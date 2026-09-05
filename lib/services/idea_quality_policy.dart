class IdeaQualityPolicy {
  const IdeaQualityPolicy._();

  static const _vaguePhrases = {
    'something came up',
    'personal reasons',
    'things happened',
    'stuff happened',
    'too busy',
    "can't make it",
  };

  static const _constructionSignals = {
    'alternative',
    'boundary',
    'budget',
    'capacity',
    'commitment',
    'constraint',
    'household',
    'impact',
    'logistics',
    'planning',
    'preference',
    'repair',
    'responsibility',
    'scheduling',
    'schedule',
    'timing',
    'time',
    'bandwidth',
    'recharge',
    'battery',
    'energy',
    'personal',
    'priority',
    'finish',
    'to-do',
    'route',
    'calendar',
    'reality',
    'work',
    'pass',
    'nope',
    'evening',
    'retreat',
    'bankruptcy',
    'night',
    'aura',
    'manufacturer',
    'council',
  };

  static bool isGeneric(String value) {
    final normalized = value.trim().toLowerCase();
    final body = normalized.startsWith('idea:')
        ? normalized.substring('idea:'.length).trim()
        : normalized;
    final words = RegExp(r"[a-z']+").allMatches(body).length;
    if (words < 5) return true;
    if (_vaguePhrases.any(body.contains)) return true;
    final hasPromptVerb = RegExp(
      r'^(use|refer|frame|set|point|turn|decline|ask|acknowledge)\b',
    ).hasMatch(body);
    final hasCuratedStatementShape = RegExp(
      r'^(you|your|the|something|home life|work)',
    ).hasMatch(body);
    if (!hasPromptVerb && !hasCuratedStatementShape) return true;
    return !_constructionSignals.any(body.contains);
  }
}
