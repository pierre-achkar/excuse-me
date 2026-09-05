import '../data/curated_kernel_repository.dart';
import '../domain/excuse_kernel.dart';
import 'idea_quality_policy.dart';
import 'idea_safety_policy.dart';

class ExcuseResult {
  const ExcuseResult({
    required this.kernelId,
    required this.playfulName,
    required this.family,
    required this.idea,
    required this.isPlaceholder,
  });

  final String kernelId;
  final String playfulName;
  final ExcuseFamily family;
  final String idea;
  final bool isPlaceholder;
}

class LocalExcuseEngine {
  const LocalExcuseEngine(this.repository);

  final CuratedKernelRepository repository;

  ExcuseResult generate(ExcuseRequest request, {String? previousKernelId}) {
    if (request.risk != RequestRisk.none ||
        request.clarity == RequestClarity.ambiguous) {
      return _fallbackResult(previousKernelId);
    }
    final compatible = repository.kernels
        .where((kernel) => !kernel.isFallback && kernel.supports(request))
        .toList(growable: true);
    if (previousKernelId != null) {
      compatible.removeWhere((kernel) => kernel.id == previousKernelId);
    }
    if (compatible.isEmpty) {
      return _fallbackResult(previousKernelId);
    }

    final kernel =
        compatible[_stableHash(request.selectionKey) % compatible.length];
    return _resultFor(kernel);
  }

  ExcuseResult _fallbackResult(String? previousKernelId) {
    final fallbacks = repository.kernels
        .where((kernel) => kernel.isFallback)
        .toList(growable: true);
    if (previousKernelId != null && fallbacks.length > 1) {
      fallbacks.removeWhere((kernel) => kernel.id == previousKernelId);
    }
    if (fallbacks.isEmpty) {
      throw StateError('No safe fallback kernel is configured.');
    }
    return _resultFor(fallbacks.first);
  }

  ExcuseResult _resultFor(ExcuseKernel kernel) {
    if (!IdeaSafetyPolicy.isSafeIdea(kernel.ideaDirection)) {
      throw StateError('Generated idea failed safety checks.');
    }
    if (!kernel.isPlaceholder &&
        IdeaQualityPolicy.isGeneric(kernel.ideaDirection)) {
      throw StateError('Generated idea failed quality checks.');
    }
    final idea = kernel.isPlaceholder
        ? 'Placeholder: Add the curated idea for ${kernel.playfulName}.'
        : kernel.ideaDirection;
    return ExcuseResult(
      kernelId: kernel.id,
      playfulName: kernel.playfulName,
      family: kernel.family,
      idea: idea,
      isPlaceholder: kernel.isPlaceholder,
    );
  }

  int _stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
