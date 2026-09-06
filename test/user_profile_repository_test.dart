import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excuse_me/domain/user_profile.dart';
import 'package:excuse_me/services/user_profile_repository.dart';

class _MemoryProfileStorage implements ProfileStorage {
  String? raw;
  bool failRead = false;
  bool failWrite = false;
  bool failRemove = false;

  @override
  Future<String?> read() async {
    if (failRead) throw StateError('read failed');
    return raw;
  }

  @override
  Future<bool> remove() async {
    if (failRemove) return false;
    raw = null;
    return true;
  }

  @override
  Future<bool> write(String value) async {
    if (failWrite) return false;
    raw = value;
    return true;
  }
}

void main() {
  test(
    'partial profile persists and reloads through a separate repository',
    () async {
      final storage = _MemoryProfileStorage();
      final repository = UserProfileRepository(storage: storage);
      const profile = UserProfile(ageRange: ProfileAgeRange.age25To34);

      await repository.save(profile);
      final reopened = UserProfileRepository(storage: storage);

      expect(await reopened.load(), profile);
    },
  );

  test('clear removes only profile data', () async {
    SharedPreferences.setMockInitialValues({
      cardCollectionStorageKey: <String>[],
    });
    final prefs = await SharedPreferences.getInstance();
    final repository = UserProfileRepository(
      storage: SharedPreferencesProfileStorage(prefs),
    );
    await repository.save(const UserProfile(hasChildren: ProfileYesNo.yes));

    await repository.clear();

    expect(await repository.load(), const UserProfile.empty());
    expect(prefs.containsKey(cardCollectionStorageKey), isTrue);
  });

  test('failed save does not report success and can be retried', () async {
    final storage = _MemoryProfileStorage()..failWrite = true;
    final repository = UserProfileRepository(storage: storage);
    const profile = UserProfile(
      workStudyStatus: ProfileWorkStudyStatus.studying,
    );

    await expectLater(repository.save(profile), throwsStateError);
    expect(repository.current, const UserProfile.empty());

    storage.failWrite = false;
    await repository.save(profile);
    expect(repository.current, profile);
  });

  test('failed load remains retryable', () async {
    final storage = _MemoryProfileStorage()..failRead = true;
    final repository = UserProfileRepository(storage: storage);

    await expectLater(repository.load(), throwsStateError);
    storage.failRead = false;
    expect(await repository.load(), const UserProfile.empty());
  });
}

const cardCollectionStorageKey = 'excuse_me.collection.v1';
