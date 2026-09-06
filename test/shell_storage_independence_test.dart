import 'dart:convert';

import 'package:excuse_me/app.dart';
import 'package:excuse_me/domain/user_profile.dart';
import 'package:excuse_me/services/card_collection.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:excuse_me/services/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('profile load survives a malformed collection load', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      CardCollection.storageKey: <String>['not-json'],
      UserProfileRepository.storageKey: jsonEncode(
        const UserProfile(hasChildren: ProfileYesNo.yes).toJson(),
      ),
    });

    await tester.pumpWidget(
      ExcuseMeApp(client: LocalIdeaClient(), disableAnimations: true),
    );
    await tester.pumpAndSettle();

    await _tap(tester, 'v6-entry-cta');
    await _tap(tester, 'v6-intent-getOutOfPlans');
    await _tap(tester, 'v6-action-cancel');
    await _tap(tester, 'v6-context-social');
    await _tap(tester, 'v6-timing-today');
    await _tap(tester, 'v6-relationship-casual');
    await _tap(tester, 'v6-obligation-low');

    expect(
      find.byKey(const ValueKey('v6-visit-context-childcare')),
      findsOneWidget,
    );
  });
}
