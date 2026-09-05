import 'package:excuse_me/analytics/analytics_client.dart';
import 'package:excuse_me/app.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeShopIdeaClient implements IdeaClient {
  FakeShopIdeaClient(this.idea);

  final String idea;

  @override
  Future<String> generate(IdeaRequest request) async => idea;
}

Future<void> _completeShopFlow(WidgetTester tester) async {
  for (final label in [
    "A dinner I can't face",
    'Today',
    'Someone close',
    'Nice text',
  ]) {
    final option = find.text(label);
    await tester.ensureVisible(option);
    await tester.pumpAndSettle();
    await tester.tap(option);
    await tester.pumpAndSettle();
  }
}

class SpyAnalyticsClient implements AnalyticsClient {
  final List<AnalyticsEvent> events = [];

  @override
  Future<void> record(AnalyticsEvent event) async {
    events.add(event);
  }

  int count(AnalyticsEvent event) => events.where((e) => e == event).length;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/share'),
          (call) async => null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          switch (call.method) {
            case 'Clipboard.setData':
              return null;
            case 'HapticFeedback.vibrate':
              return null;
            default:
              return null;
          }
        });
  });

  group('Analytics injection and event timing', () {
    testWidgets('app_open recorded once during initial page load', (
      tester,
    ) async {
      final analytics = SpyAnalyticsClient();
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient('Idea: test'),
          analytics: analytics,
        ),
      );
      await tester.pumpAndSettle();

      expect(analytics.count(AnalyticsEvent.appOpen), 1);
    });

    testWidgets('generation_completed recorded after successful generation', (
      tester,
    ) async {
      final analytics = SpyAnalyticsClient();
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient('Idea: test'),
          analytics: analytics,
        ),
      );
      await tester.pumpAndSettle();

      await _completeShopFlow(tester);

      expect(analytics.count(AnalyticsEvent.generationCompleted), 1);
    });

    testWidgets('regenerate recorded when regeneration requested', (
      tester,
    ) async {
      final analytics = SpyAnalyticsClient();
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient('Idea: test'),
          analytics: analytics,
        ),
      );
      await tester.pumpAndSettle();

      await _completeShopFlow(tester);

      await tester.tap(find.text('Regenerate'));
      await tester.pump();

      expect(analytics.count(AnalyticsEvent.regenerate), 1);

      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(analytics.count(AnalyticsEvent.regenerate), 1);
    });

    testWidgets('copy recorded after clipboard success', (tester) async {
      final analytics = SpyAnalyticsClient();
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient('Idea: test'),
          analytics: analytics,
        ),
      );
      await tester.pumpAndSettle();

      await _completeShopFlow(tester);

      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      expect(analytics.count(AnalyticsEvent.copy), 1);
    });

    testWidgets('share recorded when share requested', (tester) async {
      final analytics = SpyAnalyticsClient();
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient('Idea: test'),
          analytics: analytics,
        ),
      );
      await tester.pumpAndSettle();

      await _completeShopFlow(tester);

      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      expect(analytics.count(AnalyticsEvent.share), 1);
    });

    testWidgets('return_use recorded when app resumes from non-active', (
      tester,
    ) async {
      final analytics = SpyAnalyticsClient();
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient('Idea: test'),
          analytics: analytics,
        ),
      );
      await tester.pumpAndSettle();

      expect(analytics.count(AnalyticsEvent.returnUse), 0);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(analytics.count(AnalyticsEvent.returnUse), 1);
    });

    testWidgets('only allowlisted events are emitted during a full flow', (
      tester,
    ) async {
      final analytics = SpyAnalyticsClient();
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient('Idea: test'),
          analytics: analytics,
        ),
      );
      await tester.pumpAndSettle();

      await _completeShopFlow(tester);
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Regenerate'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      expect(analytics.events.toSet(), isA<Set<AnalyticsEvent>>());
      for (final event in analytics.events) {
        expect(AnalyticsEvent.values, contains(event));
      }
    });
  });
}
