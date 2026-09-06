import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/user_profile.dart';

abstract interface class ProfileStorage {
  Future<String?> read();
  Future<bool> write(String value);
  Future<bool> remove();
}

class SharedPreferencesProfileStorage implements ProfileStorage {
  SharedPreferencesProfileStorage(this.preferences);

  final SharedPreferences preferences;

  @override
  Future<String?> read() async =>
      preferences.getString(UserProfileRepository.storageKey);

  @override
  Future<bool> write(String value) async =>
      preferences.setString(UserProfileRepository.storageKey, value);

  @override
  Future<bool> remove() async =>
      preferences.remove(UserProfileRepository.storageKey);
}

class _LazySharedPreferencesProfileStorage implements ProfileStorage {
  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  @override
  Future<String?> read() async =>
      (await _preferences).getString(UserProfileRepository.storageKey);

  @override
  Future<bool> write(String value) async =>
      (await _preferences).setString(UserProfileRepository.storageKey, value);

  @override
  Future<bool> remove() async =>
      (await _preferences).remove(UserProfileRepository.storageKey);
}

class UserProfileRepository {
  UserProfileRepository({ProfileStorage? storage})
    : storage = storage ?? _LazySharedPreferencesProfileStorage();

  static const storageKey = 'excuse_me.profile.v1';

  final ProfileStorage storage;
  UserProfile _current = const UserProfile.empty();
  bool _loaded = false;
  Future<UserProfile>? _loading;

  UserProfile get current => _current;

  Future<UserProfile> load() {
    if (_loaded) return Future.value(_current);
    return _loading ??= _readAndCache();
  }

  Future<UserProfile> _readAndCache() async {
    try {
      final raw = await storage.read();
      final loaded = raw == null
          ? const UserProfile.empty()
          : UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _current = loaded;
      _loaded = true;
      return loaded;
    } finally {
      _loading = null;
    }
  }

  Future<void> save(UserProfile profile) async {
    await load();
    final success = await storage.write(jsonEncode(profile.toJson()));
    if (!success) throw StateError('Could not save profile');
    _current = profile;
  }

  Future<void> clear() async {
    await load();
    final success = await storage.remove();
    if (!success) throw StateError('Could not clear profile');
    _current = const UserProfile.empty();
  }
}
