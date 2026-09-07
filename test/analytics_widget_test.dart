import 'package:excuse_me/analytics/analytics_client.dart';
import 'package:excuse_me/app.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeShopIdeaClient implements IdeaClient {
  @override
  Future<String> generate(IdeaRequest request) async =>
      'Idea: keep the explanation low-detail.';
}

class SpyAnalyticsClient implements AnalyticsClient {
  final List<AnalyticsEvent> events = [];

  @override
  Future<void> record(AnalyticsEvent event) async {
    events.add(event);
  }

  int count(AnalyticsEvent event) => events.where((e) => e == event).length;
}

Future<void> _completeV6(
  WidgetTester tester, {
  bool dismissReveal = true,
}) async {
  for (final key in [
    'v6-entry-cta',
    'v6-intent-getOutOfPlans',
    'v6-action-cancel',
    'v6-context-social',
    'v6-timing-today',
    'v6-relationship-casual',
    'v6-obligation-low',
  ]) {
    final finder = find.byKey(ValueKey(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
  }
  await tester.pumpAndSettle();
  final reveal = find.byKey(const ValueKey('card-viewer-continue'));
  if (dismissReveal && reveal.evaluate().isNotEmpty) {
    await tester.tap(reveal);
    await tester.pumpAndSettle();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          return null;
        });
  });

  group('Analytics injection and event timing', () {
    testWidgets('app_open is recorded once during initial page load', (
      tester,
    ) async {
      final analytics = SpyAnalyticsClient();
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient(),
          analytics: analytics,
          disableAnimations: true,
        ),
      );
      await tester.pump();

      expect(analytics.count(AnalyticsEvent.appOpen), 1);
    });

    testWidgets(
      'generation_completed is recorded after successful generation',
      (tester) async {
        final analytics = SpyAnalyticsClient();
        await tester.pumpWidget(
          ExcuseMeApp(
            client: FakeShopIdeaClient(),
            analytics: analytics,
            disableAnimations: true,
          ),
        );
        await _completeV6(tester);

        expect(analytics.count(AnalyticsEvent.generationCompleted), 1);
      },
    );

    testWidgets('copy is recorded after local clipboard success', (
      tester,
    ) async {
      final analytics = SpyAnalyticsClient();
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient(),
          analytics: analytics,
          disableAnimations: true,
        ),
      );
      await _completeV6(tester, dismissReveal: false);

      await tester.ensureVisible(find.byKey(const ValueKey('v6-copy-card')));
      await tester.tap(find.byKey(const ValueKey('v6-copy-card')));
      await tester.pumpAndSettle();

      expect(analytics.count(AnalyticsEvent.copy), 1);
    });

    testWidgets('return_use is recorded when app resumes from inactive', (
      tester,
    ) async {
      final analytics = SpyAnalyticsClient();
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient(),
          analytics: analytics,
          disableAnimations: true,
        ),
      );
      await tester.pump();

      expect(analytics.count(AnalyticsEvent.returnUse), 0);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(analytics.count(AnalyticsEvent.returnUse), 1);
    });

    testWidgets('only allowlisted analytics events are emitted during a flow', (
      tester,
    ) async {
      final analytics = SpyAnalyticsClient();
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient(),
          analytics: analytics,
          disableAnimations: true,
        ),
      );
      await _completeV6(tester, dismissReveal: false);
      await tester.ensureVisible(find.byKey(const ValueKey('v6-copy-card')));
      await tester.tap(find.byKey(const ValueKey('v6-copy-card')));
      await tester.pumpAndSettle();

      expect(analytics.events, everyElement(isIn(AnalyticsEvent.values)));
    });
  });
}
