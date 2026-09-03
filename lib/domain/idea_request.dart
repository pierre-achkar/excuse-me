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
