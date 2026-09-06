import 'dart:convert';

import 'package:excuse_me/app.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/domain/user_profile.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:excuse_me/services/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ProfileAwareClient implements IdeaClient {
  IdeaRequest? request;

  @override
  Future<String> generate(IdeaRequest request) async {
    this.request = request;
    return 'Idea: keep this brief.';
  }
}

Future<void> _choose(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      UserProfileRepository.storageKey: jsonEncode(
        const UserProfile(hasChildren: ProfileYesNo.yes).toJson(),
      ),
    });
  });

  testWidgets('children profile requires current childcare confirmation', (
    tester,
  ) async {
    final client = _ProfileAwareClient();
    await tester.pumpWidget(
      ExcuseMeApp(
        client: client,
        profileRepository: UserProfileRepository(),
        disableAnimations: true,
      ),
    );
    await tester.pumpAndSettle();

    for (final key in [
      'v6-entry-cta',
      'v6-intent-getOutOfPlans',
      'v6-action-cancel',
      'v6-context-social',
      'v6-timing-today',
      'v6-relationship-casual',
      'v6-obligation-low',
    ]) {
      await _choose(tester, key);
    }

    expect(find.byKey(const ValueKey('v6-step-visit-context')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('v6-visit-context-childcare')),
      findsOneWidget,
    );
    expect(client.request, isNull);

    await tester.tap(find.byKey(const ValueKey('v6-visit-context-childcare')));
    await tester.pumpAndSettle();
    expect(client.request?.structuredRequest, isNotNull);
    expect(
      client.request?.structuredRequest?.currentVisitContext.responsibility,
      CurrentVisitResponsibility.childcare,
    );
  });
}
