class IdeaSafetyPolicy {
  const IdeaSafetyPolicy._();

  static bool isSafeIdea(String value) {
    final idea = value.trim();
    final isPlaceholder = idea.startsWith('Placeholder:');
    if ((!idea.startsWith('Idea:') && !isPlaceholder) || idea.length > 280) {
      return false;
    }
    if (!RegExp(r'[.!?]$').hasMatch(idea)) return false;
    if (RegExp(r'''['"“”]''').hasMatch(idea)) return false;
    if (!isPlaceholder) {
      if (RegExp(
        r'^Idea:\s*(hello|hi|dear|hey)\b',
        caseSensitive: false,
      ).hasMatch(idea)) {
        return false;
      }
      if (RegExp(
        r'^Idea:\s*(sorry|apologies|unfortunately)\b',
        caseSensitive: false,
      ).hasMatch(idea)) {
        return false;
      }
      if (RegExp(r'\bplease\b', caseSensitive: false).hasMatch(idea)) {
        return false;
      }
      if (RegExp(
        r"\b(cannot|can't|won't|will not)\s+(attend|come|join)\b",
        caseSensitive: false,
      ).hasMatch(idea)) {
        return false;
      }
      if (RegExp(
        r'\b(regards|sincerely|best|thanks|thank you)\b',
        caseSensitive: false,
      ).hasMatch(idea)) {
        return false;
      }
      if (RegExp(
        r"\b(i|i'm|i am|my|me)\b",
        caseSensitive: false,
      ).hasMatch(idea)) {
        return false;
      }
    }
    final lower = idea.toLowerCase();
    const riskyTerms =
        r'(?:death|died|dying|passed away|hospital|diagnosis|police|court|identity theft|emergenc(?:y|ies))';
    final withoutProhibitions = lower.replaceAll(
      RegExp(r'\b(?:without|avoid|never)\b[^.!?]{0,80}\b' + riskyTerms + r'\b'),
      '',
    );
    return !RegExp(
      r'\b(?:use|claim|pretend|invent|fabricate|cite|say|tell|telling)\b[^.!?]{0,80}\b' +
          riskyTerms +
          r'\b',
    ).hasMatch(withoutProhibitions);
  }
}
