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
    'timing',
  };

  static bool isGeneric(String value) {
    final normalized = value.trim().toLowerCase();
    final body = normalized.startsWith('idea:')
        ? normalized.substring('idea:'.length).trim()
        : normalized;
    final words = RegExp(r"[a-z']+").allMatches(body).length;
    if (words < 6) return true;
    if (_vaguePhrases.any(body.contains)) return true;
    if (!RegExp(r'^(use|refer|frame|set|point|turn|decline|ask|acknowledge)\b')
        .hasMatch(body)) {
      return true;
    }
    return !_constructionSignals.any(body.contains);
  }
}
