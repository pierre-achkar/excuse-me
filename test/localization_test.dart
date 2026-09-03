import 'package:excuse_me/l10n/app_localizations.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:excuse_me/ui/excuse_shop_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLocalizationIdeaClient implements IdeaClient {
  FakeLocalizationIdeaClient(this.idea);

  final String idea;

  @override
  Future<String> generate(request) async => idea;
}

Widget _localizedApp(
  IdeaClient client, {
  Locale? locale,
  TextScaler? textScaler,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return MaterialApp(
    locale: locale,
    onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Directionality(
      textDirection: textDirection,
      child: Builder(
        builder: (context) {
          Widget child = ExcuseShopPage(client: client);
          if (textScaler != null) {
            child = MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child,
            );
          }
          return child;
        },
      ),
    ),
  );
}

Future<void> _completeFlow(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Get out of plans'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Get out of plans'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Dinner'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Dinner'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Straightforward'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Straightforward'));
  await tester.pumpAndSettle();
  await tester.pumpAndSettle();
}

void main() {
  group('English localization', () {
    testWidgets('app shell and shop render English strings from l10n', (
      tester,
    ) async {
      await tester.pumpWidget(
        _localizedApp(
          FakeLocalizationIdeaClient('Idea: Use a simple capacity limit.'),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('The Excuse Shop'), findsOneWidget);
      expect(find.text('Get out of plans'), findsOneWidget);
      expect(find.text('Buy time'), findsOneWidget);
      expect(find.text('Recover from a situation'), findsOneWidget);
      expect(find.textContaining('shopkeeper'), findsWidgets);
    });

    testWidgets('English flows through mission, situation, tone, and result', (
      tester,
    ) async {
      await tester.pumpWidget(
        _localizedApp(
          FakeLocalizationIdeaClient('Idea: Use a simple capacity limit.'),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('Party'), findsOneWidget);

      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      expect(find.text('Straightforward'), findsOneWidget);
      expect(find.text('Warm'), findsOneWidget);
      expect(find.text('Funny'), findsOneWidget);

      await tester.tap(find.text('Straightforward'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.text('Your excuse'), findsOneWidget);
      expect(find.text('Regenerate'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('New excuse'), findsOneWidget);
    });

    testWidgets('English semantics and SnackBar use localized resources', (
      tester,
    ) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') return null;
          return null;
        },
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });

      await tester.pumpWidget(
        _localizedApp(
          FakeLocalizationIdeaClient('Idea: test'),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Choose mission: Get out of plans'),
        findsOneWidget,
      );

      await _completeFlow(tester);

      expect(find.bySemanticsLabel('Regenerate excuse'), findsOneWidget);
      expect(find.bySemanticsLabel('Copy excuse to clipboard'), findsOneWidget);

      await tester.ensureVisible(find.text('Copy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.text('Idea copied.'), findsOneWidget);
    });

    testWidgets('localization resource exposes expected English values', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10n.appTitle, 'Excuse Me');
      expect(l10n.shopTitle, 'The Excuse Shop');
      expect(l10n.missionGetOutOfPlans, 'Get out of plans');
      expect(l10n.situationDinner, 'Dinner');
      expect(l10n.toneWarm, 'Warm');
      expect(l10n.brewingYourExcuse, 'Brewing your excuse...');
      expect(l10n.resultTitle, 'Your excuse');
      expect(l10n.collectibleIdeaBadge, 'COLLECTIBLE IDEA');
      expect(
        l10n.generationError,
        'Unable to generate an idea. Please try again.',
      );
      expect(l10n.ideaCopied, 'Idea copied.');
      expect(l10n.stepIndicator(1, 3), 'Step 1 of 3');
      expect(l10n.chooseMission('X'), 'Choose mission: X');
    });
  });

  group('RTL safety', () {
    testWidgets('default English locale renders left-to-right', (tester) async {
      await tester.pumpWidget(
        _localizedApp(
          FakeLocalizationIdeaClient('Idea: test'),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      final dir = Directionality.of(
        tester.element(find.byType(ExcuseShopPage)),
      );
      expect(dir, TextDirection.ltr);
    });

    testWidgets('forced RTL direction renders the shop without overflow', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(700, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _localizedApp(
          FakeLocalizationIdeaClient('Idea: test'),
          locale: const Locale('en'),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Get out of plans'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _completeFlow(tester);

      expect(find.text('Your excuse'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Text scaling safety', () {
    for (final scale in [1.3, 2.0, 3.0]) {
      testWidgets('shop survives ${scale}x text scaling without overflow', (
        tester,
      ) async {
        await tester.pumpWidget(
          _localizedApp(
            FakeLocalizationIdeaClient('Idea: test'),
            locale: const Locale('en'),
            textScaler: TextScaler.linear(scale),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Get out of plans'), findsOneWidget);

        await _completeFlow(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('Your excuse'), findsOneWidget);
      });
    }
  });
}
