import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:excuse_me/domain/user_profile.dart';
import 'package:excuse_me/services/user_profile_repository.dart';
import 'package:excuse_me/ui/profile_page.dart';

class MemoryProfileStorage implements ProfileStorage {
  MemoryProfileStorage({Map<String, String>? initial, this.failWrites = false})
    : values = {...?initial};

  final Map<String, String> values;
  bool failWrites;

  @override
  Future<String?> read() async => values[UserProfileRepository.storageKey];

  @override
  Future<bool> write(String value) async {
    if (failWrites) return false;
    values[UserProfileRepository.storageKey] = value;
    return true;
  }

  @override
  Future<bool> remove() async {
    values.remove(UserProfileRepository.storageKey);
    return true;
  }
}

void main() {
  testWidgets('profile saves one field and reopens with the value', (
    tester,
  ) async {
    final storage = MemoryProfileStorage();
    final repository = UserProfileRepository(storage: storage);

    await tester.pumpWidget(
      MaterialApp(home: ProfilePage(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('profile-age-age25To34')));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('profile-save')),
      500,
    );
    await tester.tap(find.byKey(const ValueKey('profile-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-saved')), findsOneWidget);
    expect(
      (await UserProfileRepository(storage: storage).load()).ageRange,
      ProfileAgeRange.age25To34,
    );
  });

  testWidgets('clear profile leaves collection storage untouched', (
    tester,
  ) async {
    final storage = MemoryProfileStorage(
      initial: {
        UserProfileRepository.storageKey:
            '{"version":1,"ageRange":"age55Plus"}',
        'excuse_me.collection.v1': 'kept-card',
      },
    );
    final repository = UserProfileRepository(storage: storage);

    await tester.pumpWidget(
      MaterialApp(home: ProfilePage(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('profile-clear')),
      500,
    );
    await tester.tap(find.byKey(const ValueKey('profile-clear')));
    await tester.pumpAndSettle();

    expect(await repository.load(), const UserProfile.empty());
    expect(storage.values['excuse_me.collection.v1'], 'kept-card');
  });

  testWidgets('failed save shows retry and does not report saved', (
    tester,
  ) async {
    final storage = MemoryProfileStorage(failWrites: true);
    final repository = UserProfileRepository(storage: storage);

    await tester.pumpWidget(
      MaterialApp(home: ProfilePage(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('profile-work-study-working')),
      350,
    );
    await tester.tap(find.byKey(const ValueKey('profile-work-study-working')));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('profile-save')),
      500,
    );
    await tester.tap(find.byKey(const ValueKey('profile-save')));
    await tester.pumpAndSettle();

    expect(find.text('Profile was not saved. Try again.'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-saved')), findsNothing);
  });
}
