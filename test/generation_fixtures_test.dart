import 'dart:convert';
import 'dart:io';

import 'package:excuse_me/data/curated_kernel_repository.dart';
import 'package:excuse_me/domain/excuse_kernel.dart';
import 'package:excuse_me/domain/excuse_request.dart';
import 'package:excuse_me/services/idea_quality_policy.dart';
import 'package:excuse_me/services/idea_safety_policy.dart';
import 'package:excuse_me/services/local_excuse_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'versioned fixtures cover taxonomy, safety, compatibility, and diversity',
    () {
      final fixtureFile = File('test/fixtures/generation_cases.v1.json');
      final document =
          jsonDecode(fixtureFile.readAsStringSync()) as Map<String, dynamic>;
      final cases = (document['cases'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final repository = CuratedKernelRepository.englishAlpha();
      final engine = LocalExcuseEngine(repository);
      final intents = <ExcuseIntent>{};
      final actions = <ExcuseAction>{};
      final timings = <ExcuseTiming>{};
      final relationships = <RelationshipKind>{};
      final obligations = <ObligationLevel>{};
      final contexts = <ExcuseContext>{};
      final tones = <ExcuseTone>{};
      final selectedKernelIds = <String>{};
      final coverage = <String>{};

      expect(document['schemaVersion'], 1);
      expect(document['libraryVersion'], repository.version);
      expect(cases.length, greaterThanOrEqualTo(12));

      for (final fixture in cases) {
        final request = ExcuseRequest(
          intent: _byName(ExcuseIntent.values, fixture['intent'] as String),
          action: _byName(ExcuseAction.values, fixture['action'] as String),
          timing: _byName(ExcuseTiming.values, fixture['timing'] as String),
          relationship: _byName(
            RelationshipKind.values,
            fixture['relationship'] as String,
          ),
          obligation: _byName(
            ObligationLevel.values,
            fixture['obligation'] as String,
          ),
          context: _byName(ExcuseContext.values, fixture['context'] as String),
          tone: _byName(ExcuseTone.values, fixture['tone'] as String),
          risk: RequestRisk.values.byName(
            (fixture['risk'] as String?) ?? RequestRisk.none.name,
          ),
          clarity: RequestClarity.values.byName(
            (fixture['clarity'] as String?) ?? RequestClarity.structured.name,
          ),
        );
        final result = engine.generate(request);
        final kernel = repository.kernels.singleWhere(
          (candidate) => candidate.id == result.kernelId,
        );

        expect(
          result.kernelId,
          fixture['expectedKernelId'],
          reason: fixture['id'] as String,
        );
        expect(
          result.idea,
          fixture['expectedIdea'],
          reason: fixture['id'] as String,
        );

        intents.add(request.intent);
        actions.add(request.action);
        timings.add(request.timing);
        relationships.add(request.relationship);
        obligations.add(request.obligation);
        contexts.add(request.context);
        tones.add(request.tone);
        selectedKernelIds.add(result.kernelId);
        final caseCoverage =
            ((fixture['coverage'] as List<dynamic>?) ?? const <dynamic>[])
                .cast<String>()
                .toSet();
        coverage.addAll(caseCoverage);
        expect(
          IdeaSafetyPolicy.isSafeIdea(result.idea),
          isTrue,
          reason: fixture['id'] as String,
        );
        expect(result.isPlaceholder, kernel.isPlaceholder);
        if (!kernel.isPlaceholder) {
          expect(
            IdeaQualityPolicy.isGeneric(result.idea),
            isFalse,
            reason: fixture['id'] as String,
          );
        }
        if (fixture['expectFallback'] == true) {
          expect(kernel.isFallback, isTrue, reason: fixture['id'] as String);
        } else {
          expect(
            kernel.supports(request),
            isTrue,
            reason: fixture['id'] as String,
          );
        }
        if (caseCoverage.contains('unsafeRequest')) {
          expect(
            request.risk,
            RequestRisk.highRiskFabrication,
            reason: fixture['id'] as String,
          );
          expect(fixture['expectFallback'], isTrue);
        }
        if (caseCoverage.contains('ambiguity')) {
          expect(
            request.clarity,
            RequestClarity.ambiguous,
            reason: fixture['id'] as String,
          );
          expect(fixture['expectFallback'], isTrue);
        }
        if (caseCoverage.contains('noReadyMessage')) {
          expect(result.idea, startsWith('Placeholder:'));
          expect(result.idea, isNot(contains('\n')));
          expect(IdeaSafetyPolicy.isSafeIdea(result.idea), isTrue);
          expect(
            RegExp(
              r"\b(i|i'm|i am|my|me|hi|hello|dear)\b",
              caseSensitive: false,
            ).hasMatch(result.idea),
            isFalse,
            reason: fixture['id'] as String,
          );
        }
        if (caseCoverage.contains('repairOrientation')) {
          if (kernel.isPlaceholder) {
            expect(result.idea, startsWith('Placeholder:'));
          } else {
            expect(
              result.idea,
              anyOf(
                contains('boundary'),
                contains('repair'),
                contains('alternative'),
                contains('next step'),
              ),
              reason: fixture['id'] as String,
            );
          }
        }
      }

      expect(intents, containsAll(ExcuseIntent.values));
      expect(actions, containsAll(ExcuseAction.values));
      expect(timings, containsAll(ExcuseTiming.values));
      expect(relationships, containsAll(RelationshipKind.values));
      expect(obligations, containsAll(ObligationLevel.values));
      expect(contexts, containsAll(ExcuseContext.values));
      expect(tones, containsAll(ExcuseTone.values));
      expect(selectedKernelIds.length, greaterThanOrEqualTo(6));
      expect(
        coverage,
        containsAll(const ['unsafeRequest', 'ambiguity', 'noReadyMessage']),
      );
    },
  );
}

T _byName<T extends Enum>(List<T> values, String name) {
  return values.singleWhere((value) => value.name == name);
}
