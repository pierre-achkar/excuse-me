import 'excuse_request.dart';

class IdeaRequest {
  const IdeaRequest({
    required this.situation,
    required this.relationship,
    required this.urgency,
    required this.tone,
    this.structuredRequest,
  });

  const IdeaRequest.fromExcuseRequest(ExcuseRequest request)
    : situation = '',
      relationship = '',
      urgency = '',
      tone = '',
      structuredRequest = request;

  final String situation;
  final String relationship;
  final String urgency;
  final String tone;
  final ExcuseRequest? structuredRequest;
}
