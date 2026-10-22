import 'package:flutter/foundation.dart';

import 'package:bloomshop/services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._service)
      : _promoNotifications = _service.promoNotifications,
        _orderAlerts = _service.orderAlerts;

  final SettingsService _service;
  bool _promoNotifications;
  bool _orderAlerts;

  /// When on, the Home bell icon is shown and opens the promo inbox.
  bool get promoNotifications => _promoNotifications;

  /// When on, a snackbar confirms every order status change.
  bool get orderAlerts => _orderAlerts;

  Future<void> setPromoNotifications(bool value) async {
    _promoNotifications = value;
    notifyListeners();
    await _service.setPromoNotifications(value);
  }

  Future<void> setOrderAlerts(bool value) async {
    _orderAlerts = value;
    notifyListeners();
    await _service.setOrderAlerts(value);
  }
}
