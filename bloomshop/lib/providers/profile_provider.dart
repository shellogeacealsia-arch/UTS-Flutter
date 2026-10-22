import 'package:flutter/foundation.dart';

import 'package:bloomshop/models/user_profile.dart';
import 'package:bloomshop/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._service);

  final ProfileService _service;

  UserProfile? _profile;

  UserProfile? get profile => _profile;
  String get displayName => _profile?.name ?? 'Beauty Lover';

  /// Loads the saved profile for [email], or creates a default one.
  Future<void> loadFor(String email, {required String fallbackName}) async {
    var loaded = _service.load(email);
    if (loaded == null) {
      loaded = UserProfile(name: fallbackName, email: email);
      await _service.save(loaded);
    }
    _profile = loaded;
    notifyListeners();
  }

  Future<void> update({
    required String name,
    required String phone,
    required String address,
    String? photoBase64,
    bool clearPhoto = false,
  }) async {
    final current = _profile;
    if (current == null) return;
    final updated = current.copyWith(
      name: name.trim(),
      phone: phone.trim(),
      address: address.trim(),
      photoBase64: photoBase64,
      clearPhoto: clearPhoto,
    );
    _profile = updated;
    notifyListeners();
    await _service.save(updated);
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
