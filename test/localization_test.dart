import 'package:excuse_me/app.dart';
import 'package:excuse_me/l10n/app_localizations.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _LocalizationClient implements IdeaClient {
  @override
  Future<String> generate(request) async => 'Idea: keep it brief.';
}

Future<void> _enter(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('v6-entry-cta')));
  await tester.pump();
}

void main() {
  testWidgets('app shell and v6 shop render localized English strings', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: _LocalizationClient(), disableAnimations: true),
    );
    await tester.pump();

    expect(find.text('Excuse Me'), findsOneWidget);
    expect(find.text('I NEED AN EXCUSE'), findsOneWidget);
    await _enter(tester);
    expect(find.text("Now then... what's the situation?"), findsOneWidget);
    expect(find.bySemanticsLabel('Choose intent: I NEED OUT'), findsOneWidget);
  });

  test('localization resource exposes v6 English values', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(l10n.entryCta, 'I NEED AN EXCUSE');
    expect(l10n.intentNeedOut, 'I NEED OUT');
    expect(l10n.dialogueObligationV6, 'How much does this one matter?');
    expect(l10n.keepCardButton, 'KEEP CARD');
  });

  testWidgets('forced RTL direction renders the entry without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: ExcuseMeApp(client: _LocalizationClient()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('I NEED AN EXCUSE'), findsOneWidget);
  });

  for (final scale in [1.3, 2.0, 3.0]) {
    testWidgets('v6 entry survives ${scale}x text scaling', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: ExcuseMeApp(client: _LocalizationClient()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('I NEED AN EXCUSE'), findsOneWidget);
    });
  }
}
