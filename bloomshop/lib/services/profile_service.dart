import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloomshop/models/user_profile.dart';

class ProfileService {
  ProfileService(this._prefs);

  final SharedPreferences _prefs;

  String _key(String email) => 'profile_${email.trim().toLowerCase()}';

  UserProfile? load(String email) {
    final raw = _prefs.getString(_key(email));
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(UserProfile profile) async {
    await _prefs.setString(_key(profile.email), jsonEncode(profile.toJson()));
  }
}
