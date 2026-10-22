import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const String _promoKey = 'pref_promo_notifications';
  static const String _orderKey = 'pref_order_alerts';

  bool get promoNotifications => _prefs.getBool(_promoKey) ?? true;
  bool get orderAlerts => _prefs.getBool(_orderKey) ?? true;

  Future<void> setPromoNotifications(bool value) =>
      _prefs.setBool(_promoKey, value);

  Future<void> setOrderAlerts(bool value) => _prefs.setBool(_orderKey, value);
}
