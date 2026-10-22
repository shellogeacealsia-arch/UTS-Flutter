import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloomshop/models/order.dart';

class OrderService {
  OrderService(this._prefs);

  final SharedPreferences _prefs;
  static const String _key = 'orders';

  List<Order> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Order> orders) async {
    await _prefs.setString(
      _key,
      jsonEncode(orders.map((o) => o.toJson()).toList()),
    );
  }
}
