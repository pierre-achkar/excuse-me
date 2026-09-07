import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:excuse_me/domain/excuse_request.dart';
import 'package:excuse_me/l10n/app_localizations.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:excuse_me/ui/excuse_card.dart';

Widget _host(Widget child, {double width = 320}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

void main() {
  testWidgets('card meta text is never smaller than the pixel font can carry', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const ExcuseCard(
          idea: GeneratedIdea(
            idea: 'Idea: keep it short.',
            kernelId: 'legibility-card',
            playfulName: 'Boundary Card',
            family: ExcuseFamily.careFamily,
          ),
        ),
      ),
    );
    await tester.pump();

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      final size = text.style?.fontSize;
      if (text.style?.fontFamily == 'PressStart2P' && size != null) {
        expect(
          size,
          greaterThanOrEqualTo(9),
          reason: '"${text.data}" too small',
        );
      }
    }
  });

  testWidgets('the widest labels still fit a narrow card', (tester) async {
    // Longest family label, a long name, and the full-width edition code.
    await tester.pumpWidget(
      _host(
        const ExcuseCard(
          idea: GeneratedIdea(
            idea: 'Idea: a longer body that wraps across several lines.',
            kernelId: 'a-very-long-kernel-identifier-for-the-edition',
            playfulName: 'The Exceptionally Long Card Name',
            family: ExcuseFamily.moneyLogistics,
          ),
        ),
        width: 268,
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
