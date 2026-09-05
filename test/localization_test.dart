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
  Future<void> choose(String label) async {
    final option = find.text(label);
    await tester.ensureVisible(option);
    await tester.pumpAndSettle();
    await tester.tap(option);
    await tester.pumpAndSettle();
  }

  await choose("A dinner I can't face");
  await choose('Today');
  await choose('Someone close');
  await choose('Nice text');
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
      expect(find.text("What's the damage?"), findsOneWidget);
      expect(find.text("A dinner I can't face"), findsOneWidget);
      expect(find.text('A group work call'), findsOneWidget);
      expect(find.textContaining('shopkeeper'), findsWidgets);
    });

    testWidgets('English flows through all four beats and the result', (
      tester,
    ) async {
      await tester.pumpWidget(
        _localizedApp(
          FakeLocalizationIdeaClient('Idea: Use a simple capacity limit.'),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("What's the damage?"), findsOneWidget);
      await tester.ensureVisible(find.text("A dinner I can't face"));
      await tester.tap(find.text("A dinner I can't face"));
      await tester.pumpAndSettle();
      expect(find.text("When's the reckoning?"), findsOneWidget);
      expect(find.text('Already missed'), findsOneWidget);

      await tester.ensureVisible(find.text('Today'));
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      expect(find.text("Who's on the other end?"), findsOneWidget);
      expect(find.text('Someone close'), findsOneWidget);

      await tester.ensureVisible(find.text('Someone close'));
      await tester.tap(find.text('Someone close'));
      await tester.pumpAndSettle();
      expect(find.text('How loud do you want this?'), findsOneWidget);
      expect(find.text('Nice text'), findsOneWidget);

      await tester.ensureVisible(find.text('Nice text'));
      await tester.tap(find.text('Nice text'));
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
        find.bySemanticsLabel("Choose damage: A dinner I can't face"),
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
      expect(l10n.dialogueDamage, "What's the damage?");
      expect(l10n.damageDinner, "A dinner I can't face");
      expect(l10n.dialogueTiming, "When's the reckoning?");
      expect(l10n.timingToday, 'Today');
      expect(l10n.dialogueAudience, "Who's on the other end?");
      expect(l10n.audienceSomeoneClose, 'Someone close');
      expect(l10n.dialogueDelivery, 'How loud do you want this?');
      expect(l10n.deliveryNiceText, 'Nice text');
      expect(l10n.brewingYourExcuse, 'Brewing your excuse...');
      expect(l10n.resultTitle, 'Your excuse');
      expect(l10n.repairDirectionLabel, 'Repair direction');
      expect(l10n.stepIndicator(1, 4), 'Step 1 of 4');
      expect(l10n.chooseDamage('X'), 'Choose damage: X');
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

      expect(find.text("What's the damage?"), findsOneWidget);
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
        expect(find.text("What's the damage?"), findsOneWidget);

        await _completeFlow(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('Your excuse'), findsOneWidget);
      });
    }
  });
}
