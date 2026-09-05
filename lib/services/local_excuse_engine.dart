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
    this.toneDirections = const {},
    this.selectedTone = ExcuseTone.lowKey,
  });

  final String kernelId;
  final String playfulName;
  final ExcuseFamily family;
  final String idea;
  final bool isPlaceholder;
  final Map<ExcuseTone, String> toneDirections;
  final ExcuseTone selectedTone;

  String ideaForTone(ExcuseTone tone) {
    return toneDirections[tone] ?? idea;
  }

  ExcuseResult withTone(ExcuseTone tone) {
    return ExcuseResult(
      kernelId: kernelId,
      playfulName: playfulName,
      family: family,
      idea: ideaForTone(tone),
      isPlaceholder: isPlaceholder,
      toneDirections: toneDirections,
      selectedTone: tone,
    );
  }
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

  /// Selects the internal family/kernel from the six semantic beats. Tone is
  /// intentionally not part of this lookup; it is a presentation transform.
  ExcuseResult generateSemantic(
    ExcuseRequest request, {
    String? previousKernelId,
  }) {
    if (request.risk != RequestRisk.none ||
        request.clarity == RequestClarity.ambiguous) {
      return _fallbackResult(previousKernelId);
    }
    final compatible = repository.kernels
        .where(
          (kernel) => !kernel.isFallback && kernel.supportsSemantic(request),
        )
        .toList(growable: true);
    if (previousKernelId != null) {
      compatible.removeWhere((kernel) => kernel.id == previousKernelId);
    }
    if (compatible.isEmpty) {
      return _fallbackResult(previousKernelId);
    }
    final kernel =
        compatible[_stableHash(request.semanticSelectionKey) %
            compatible.length];
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
    for (final direction in kernel.toneDirections.values) {
      if (!IdeaSafetyPolicy.isSafeIdea(direction)) {
        throw StateError('Tone variant failed safety checks.');
      }
      if (!kernel.isPlaceholder && IdeaQualityPolicy.isGeneric(direction)) {
        throw StateError('Tone variant failed quality checks.');
      }
    }
    final idea = kernel.isPlaceholder
        ? 'Placeholder: Add the curated idea for ${kernel.playfulName}.'
        : kernel.ideaDirection;
    final directions = kernel.isPlaceholder
        ? <ExcuseTone, String>{}
        : kernel.toneDirections.map(
            (tone, direction) => MapEntry(tone, direction),
          );
    return ExcuseResult(
      kernelId: kernel.id,
      playfulName: kernel.playfulName,
      family: kernel.family,
      idea: idea,
      isPlaceholder: kernel.isPlaceholder,
      toneDirections: directions,
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
