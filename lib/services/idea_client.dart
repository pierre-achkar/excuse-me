import '../data/curated_kernel_repository.dart';
import '../domain/idea_request.dart';
import 'local_excuse_engine.dart';
import 'prototype_request_mapper.dart';

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
