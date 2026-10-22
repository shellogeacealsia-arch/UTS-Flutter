import 'package:flutter/foundation.dart';

import 'package:bloomshop/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);

  final AuthService _service;

  String? _email;
  String? _name;

  bool get isLoggedIn => _email != null;
  String? get email => _email;
  String? get name => _name;

  Future<AuthResult> restoreSession() async {
    final result = await _service.restoreSession();
    _apply(result);
    return result;
  }

  Future<AuthResult> login(String email, String password) async {
    final result = await _service.login(email: email, password: password);
    _apply(result);
    return result;
  }

  Future<AuthResult> register(String name, String email, String password) async {
    final result = await _service.register(
      name: name,
      email: email,
      password: password,
    );
    _apply(result);
    return result;
  }

  Future<void> logout() async {
    await _service.logout();
    _email = null;
    _name = null;
    notifyListeners();
  }

  void _apply(AuthResult result) {
    if (result.success) {
      _email = result.email;
      _name = result.name;
      notifyListeners();
    }
  }
}
