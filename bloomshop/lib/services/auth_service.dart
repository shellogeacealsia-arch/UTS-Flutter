import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  const AuthResult.success({required this.email, required this.name})
      : success = true,
        error = null;

  const AuthResult.failure(String message)
      : success = false,
        error = message,
        email = null,
        name = null;

  final bool success;
  final String? error;
  final String? email;
  final String? name;
}

/// Authentication contract. The UI/providers depend only on this interface,
/// so a Firebase implementation (FirebaseAuthService) can replace
/// [LocalAuthService] later without touching any page.
abstract class AuthService {
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  });
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> restoreSession();
  Future<void> logout();
}

/// DEMO ONLY: stores accounts in SharedPreferences. Passwords are salted and
/// hashed (SHA-256) so they are never persisted as plain text, but this is
/// still NOT secure enough for production (no server, no rate limiting,
/// data is readable on the device). Use a real backend for production.
class LocalAuthService implements AuthService {
  LocalAuthService(this._prefs);

  final SharedPreferences _prefs;

  static const String _accountsKey = 'auth_accounts';
  static const String _sessionKey = 'auth_session_email';

  Map<String, dynamic> _readAccounts() {
    final raw = _prefs.getString(_accountsKey);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _normalize(String email) => email.trim().toLowerCase();

  String _hash(String salt, String password) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  String _newSalt() {
    final random = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final key = _normalize(email);
    final accounts = _readAccounts();
    if (accounts.containsKey(key)) {
      return const AuthResult.failure('This email is already registered.');
    }
    final salt = _newSalt();
    accounts[key] = {
      'name': name.trim(),
      'salt': salt,
      'hash': _hash(salt, password),
    };
    await _prefs.setString(_accountsKey, jsonEncode(accounts));
    await _prefs.setString(_sessionKey, key);
    return AuthResult.success(email: key, name: name.trim());
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final key = _normalize(email);
    final accounts = _readAccounts();
    final account = accounts[key];
    if (account == null) {
      return const AuthResult.failure('Incorrect email or password.');
    }
    final data = Map<String, dynamic>.from(account as Map);
    final expected = data['hash'] as String? ?? '';
    final actual = _hash(data['salt'] as String? ?? '', password);
    if (expected != actual) {
      return const AuthResult.failure('Incorrect email or password.');
    }
    await _prefs.setString(_sessionKey, key);
    return AuthResult.success(email: key, name: data['name'] as String? ?? '');
  }

  @override
  Future<AuthResult> restoreSession() async {
    final key = _prefs.getString(_sessionKey);
    if (key == null) return const AuthResult.failure('No active session.');
    final account = _readAccounts()[key];
    if (account == null) {
      await _prefs.remove(_sessionKey);
      return const AuthResult.failure('No active session.');
    }
    final data = Map<String, dynamic>.from(account as Map);
    return AuthResult.success(email: key, name: data['name'] as String? ?? '');
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(_sessionKey);
  }
}
