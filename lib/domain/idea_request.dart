import 'excuse_request.dart';

class IdeaRequest {
  const IdeaRequest({
    required this.situation,
    required this.relationship,
    required this.urgency,
    required this.tone,
    this.structuredRequest,
    this.semanticFlow = false,
  });

  const IdeaRequest.fromExcuseRequest(ExcuseRequest request)
    : situation = '',
      relationship = '',
      urgency = '',
      tone = '',
      structuredRequest = request,
      semanticFlow = false;

  const IdeaRequest.fromV6ExcuseRequest(ExcuseRequest request)
    : situation = '',
      relationship = '',
      urgency = '',
      tone = '',
      structuredRequest = request,
      semanticFlow = true;

  final String situation;
  final String relationship;
  final String urgency;
  final String tone;
  final ExcuseRequest? structuredRequest;
  final bool semanticFlow;
}
