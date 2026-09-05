import '../data/curated_kernel_repository.dart';
import '../domain/excuse_request.dart';
import '../domain/idea_request.dart';
import 'local_excuse_engine.dart';
import 'prototype_request_mapper.dart';

class GeneratedIdea {
  const GeneratedIdea({
    required this.idea,
    this.kernelId,
    this.playfulName,
    this.family,
    this.isPlaceholder = false,
    this.toneDirections = const {},
    this.selectedTone = ExcuseTone.lowKey,
  });

  final String idea;
  final String? kernelId;
  final String? playfulName;
  final ExcuseFamily? family;
  final bool isPlaceholder;
  final Map<ExcuseTone, String> toneDirections;
  final ExcuseTone selectedTone;

  String ideaForTone(ExcuseTone tone) {
    return toneDirections[tone] ?? idea;
  }

  GeneratedIdea withTone(ExcuseTone tone) {
    return GeneratedIdea(
      idea: ideaForTone(tone),
      kernelId: kernelId,
      playfulName: playfulName,
      family: family,
      isPlaceholder: isPlaceholder,
      toneDirections: toneDirections,
      selectedTone: tone,
    );
  }
}

abstract class IdeaClient {
  Future<String> generate(IdeaRequest request);
}

abstract class DetailedIdeaClient {
  Future<GeneratedIdea> generateDetailed(IdeaRequest request);
}

Future<GeneratedIdea> generateDetailedIdea(
  IdeaClient client,
  IdeaRequest request,
) async {
  if (client is DetailedIdeaClient) {
    return (client as DetailedIdeaClient).generateDetailed(request);
  }
  return GeneratedIdea(idea: await client.generate(request));
}

class LocalIdeaClient implements IdeaClient, DetailedIdeaClient {
  final LocalExcuseEngine _engine = LocalExcuseEngine(
    CuratedKernelRepository.englishAlpha(),
  );
  final PrototypeRequestMapper _mapper = const PrototypeRequestMapper();
  String? _previousKernelId;
  String? _previousSelectionKey;

  @override
  Future<String> generate(IdeaRequest request) async {
    return (await generateDetailed(request)).idea;
  }

  @override
  Future<GeneratedIdea> generateDetailed(IdeaRequest request) async {
    final structuredRequest =
        request.structuredRequest ??
        _mapper.map(
          situation: request.situation,
          relationship: request.relationship,
          urgency: request.urgency,
          tone: request.tone,
        );
    final selectionKey = request.semanticFlow
        ? structuredRequest.semanticSelectionKey
        : structuredRequest.selectionKey;
    final result = request.semanticFlow
        ? _engine.generateSemantic(
            structuredRequest,
            previousKernelId: selectionKey == _previousSelectionKey
                ? _previousKernelId
                : null,
          )
        : _engine.generate(
            structuredRequest,
            previousKernelId: selectionKey == _previousSelectionKey
                ? _previousKernelId
                : null,
          );
    _previousKernelId = result.kernelId;
    _previousSelectionKey = selectionKey;
    return GeneratedIdea(
      idea: result.idea,
      kernelId: result.kernelId,
      playfulName: result.playfulName,
      family: result.family,
      isPlaceholder: result.isPlaceholder,
      toneDirections: result.toneDirections,
      selectedTone: result.selectedTone,
    );
  }
}

class LocalIdeaGenerator {
  final LocalExcuseEngine _engine = LocalExcuseEngine(
    CuratedKernelRepository.englishAlpha(),
  );
  final PrototypeRequestMapper _mapper = const PrototypeRequestMapper();

  String generate(IdeaRequest request) {
    final structuredRequest =
        request.structuredRequest ??
        _mapper.map(
          situation: request.situation,
          relationship: request.relationship,
          urgency: request.urgency,
          tone: request.tone,
        );
    return _engine.generate(structuredRequest).idea;
  }
}
