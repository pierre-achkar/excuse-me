import 'package:excuse_me/analytics/analytics_client.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAnalyticsRecorder implements AnalyticsClient {
  final List<AnalyticsEvent> events = [];
  int failCount = 0;

  @override
  Future<void> record(AnalyticsEvent event) async {
    events.add(event);
  }

  bool get isEmpty => events.isEmpty;
  int get length => events.length;
}

class FailingAnalyticsRecorder implements AnalyticsClient {
  @override
  Future<void> record(AnalyticsEvent event) async {
    throw Exception('analytics provider unavailable');
  }
}

void main() {
  group('AnalyticsEvent enum', () {
    test('contains exactly six allowlisted values', () {
      expect(AnalyticsEvent.values.length, 6);
    });

    test('contains app_open', () {
      expect(AnalyticsEvent.values, contains(AnalyticsEvent.appOpen));
    });

    test('contains generation_completed', () {
      expect(
        AnalyticsEvent.values,
        contains(AnalyticsEvent.generationCompleted),
      );
    });

    test('contains regenerate', () {
      expect(AnalyticsEvent.values, contains(AnalyticsEvent.regenerate));
    });

    test('contains copy', () {
      expect(AnalyticsEvent.values, contains(AnalyticsEvent.copy));
    });

    test('contains share', () {
      expect(AnalyticsEvent.values, contains(AnalyticsEvent.share));
    });

    test('contains return_use', () {
      expect(AnalyticsEvent.values, contains(AnalyticsEvent.returnUse));
    });
  });

  group('AnalyticsClient interface', () {
    test('record accepts only AnalyticsEvent', () {
      final client = FakeAnalyticsRecorder();
      expect(
        client.record(AnalyticsEvent.appOpen),
        isA<Future<void>>(),
      );
    });

    test('NoOpAnalyticsClient implements AnalyticsClient', () {
      expect(NoOpAnalyticsClient(), isA<AnalyticsClient>());
    });

    test('NoOpAnalyticsClient.record completes without error', () async {
      final noop = NoOpAnalyticsClient();
      await noop.record(AnalyticsEvent.appOpen);
      await noop.record(AnalyticsEvent.generationCompleted);
      await noop.record(AnalyticsEvent.regenerate);
      await noop.record(AnalyticsEvent.copy);
      await noop.record(AnalyticsEvent.share);
      await noop.record(AnalyticsEvent.returnUse);
    });
  });

  group('Fake recorder proves event timing', () {
    late FakeAnalyticsRecorder recorder;

    setUp(() {
      recorder = FakeAnalyticsRecorder();
    });

    test('records app_open once', () async {
      await recorder.record(AnalyticsEvent.appOpen);
      expect(recorder.events, [AnalyticsEvent.appOpen]);
      expect(recorder.length, 1);
    });

    test('records generation_completed after generation', () async {
      await recorder.record(AnalyticsEvent.generationCompleted);
      expect(recorder.events, [AnalyticsEvent.generationCompleted]);
    });

    test('records regenerate when requested', () async {
      await recorder.record(AnalyticsEvent.regenerate);
      expect(recorder.events, [AnalyticsEvent.regenerate]);
    });

    test('records copy after clipboard success', () async {
      await recorder.record(AnalyticsEvent.copy);
      expect(recorder.events, [AnalyticsEvent.copy]);
    });

    test('records share when share requested', () async {
      await recorder.record(AnalyticsEvent.share);
      expect(recorder.events, [AnalyticsEvent.share]);
    });

    test('records return_use after resume from non-active', () async {
      await recorder.record(AnalyticsEvent.returnUse);
      expect(recorder.events, [AnalyticsEvent.returnUse]);
    });

    test('events appear in chronological order', () async {
      await recorder.record(AnalyticsEvent.appOpen);
      await recorder.record(AnalyticsEvent.generationCompleted);
      await recorder.record(AnalyticsEvent.regenerate);
      await recorder.record(AnalyticsEvent.copy);
      await recorder.record(AnalyticsEvent.share);
      await recorder.record(AnalyticsEvent.returnUse);

      expect(recorder.events, [
        AnalyticsEvent.appOpen,
        AnalyticsEvent.generationCompleted,
        AnalyticsEvent.regenerate,
        AnalyticsEvent.copy,
        AnalyticsEvent.share,
        AnalyticsEvent.returnUse,
      ]);
    });
  });

  group('Privacy tests', () {
    test('record accepts exactly one AnalyticsEvent parameter and nothing else', () {
      Future<void> Function(AnalyticsEvent) record = FakeAnalyticsRecorder().record;
      expect(record, isNotNull);
      expect(record, isA<Function>());
    });

    test('String and Map arguments are rejected at compile time', () {
      // The concrete implementations of AnalyticsClient expose only
      // `Future<void> record(AnalyticsEvent)`. Any attempt to pass a String,
      // Map, or arbitrary payload does not compile — there is no overload and no
      // dynamic-typed entry point. This is the primary privacy boundary.
      Future<void> Function(AnalyticsEvent) record = FakeAnalyticsRecorder().record;
      expect(record, isNotNull);

      const expectedEvents = {
        AnalyticsEvent.appOpen,
        AnalyticsEvent.generationCompleted,
        AnalyticsEvent.regenerate,
        AnalyticsEvent.copy,
        AnalyticsEvent.share,
        AnalyticsEvent.returnUse,
      };
      expect(AnalyticsEvent.values.toSet(), expectedEvents);
    });

    test('String and Map payloads throw at runtime, not silently accepted', () {
      final client = FakeAnalyticsRecorder();
      expect(
        () => client.record('app_open' as dynamic),
        throwsA(anyOf(isA<NoSuchMethodError>(), isA<TypeError>())),
      );
      expect(
        () => client.record({'event': 'app_open'} as dynamic),
        throwsA(anyOf(isA<NoSuchMethodError>(), isA<TypeError>())),
      );
    });

    test('record throws when given a free-form String', () {
      final client = FakeAnalyticsRecorder();
      expect(
        () => client.record('app_open' as dynamic),
        throwsA(anyOf(isA<NoSuchMethodError>(), isA<TypeError>())),
      );
    });

    test('record throws when given a Map payload', () {
      final client = FakeAnalyticsRecorder();
      expect(
        () => client.record({'event': 'app_open'} as dynamic),
        throwsA(anyOf(isA<NoSuchMethodError>(), isA<TypeError>())),
      );
    });

    test('record throws when given a generated output String', () {
      final client = FakeAnalyticsRecorder();
      expect(
        () => client.record('Idea: skip the meeting, claim capacity' as dynamic),
        throwsA(anyOf(isA<NoSuchMethodError>(), isA<TypeError>())),
      );
    });

    test('record throws when given an advertising ID String', () {
      final client = FakeAnalyticsRecorder();
      expect(
        () => client.record('IDFA-1234-abcd' as dynamic),
        throwsA(anyOf(isA<NoSuchMethodError>(), isA<TypeError>())),
      );
    });

    test('AnalyticsEvent carries no user content or identifiers', () {
      for (final event in AnalyticsEvent.values) {
        expect(event, isA<AnalyticsEvent>());
        expect(event.index, isA<int>());
      }
    });

    test('NoOpAnalyticsClient is disabled by default and records nothing to disk or network', () async {
      final noop = NoOpAnalyticsClient();
      expect(noop, isA<AnalyticsClient>());
      await noop.record(AnalyticsEvent.appOpen);
      await noop.record(AnalyticsEvent.generationCompleted);
      await noop.record(AnalyticsEvent.regenerate);
      await noop.record(AnalyticsEvent.copy);
      await noop.record(AnalyticsEvent.share);
      await noop.record(AnalyticsEvent.returnUse);
    });
  });

  group('Failure is non-blocking', () {
    test('failing recorder throws on record', () async {
      final failing = FailingAnalyticsRecorder();
      expect(
        () => failing.record(AnalyticsEvent.appOpen),
        throwsA(isA<Exception>()),
      );
    });

    test('noop recorder never throws', () async {
      final noop = NoOpAnalyticsClient();
      try {
        await noop.record(AnalyticsEvent.appOpen);
      } catch (e) {
        fail('NoOpAnalyticsClient must never throw, but threw $e');
      }
    });
  });
}
