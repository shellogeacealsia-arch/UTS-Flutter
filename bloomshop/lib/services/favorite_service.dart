import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  FavoriteService(this._prefs);

  final SharedPreferences _prefs;
  static const String _key = 'favorite_ids';

  Set<String> load() => (_prefs.getStringList(_key) ?? <String>[]).toSet();

  Future<void> save(Set<String> ids) async {
    await _prefs.setStringList(_key, ids.toList());
  }
}
