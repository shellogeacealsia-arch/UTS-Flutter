import 'dart:convert';
import 'dart:typed_data';

/// Customer profile. The photo is stored as base64 so it also works on
/// Flutter Web (where device file paths cannot be reused after a reload).
class UserProfile {
  UserProfile({
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.photoBase64,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final String? photoBase64;

  /// Decoded photo bytes (decoded once, lazily).
  late final Uint8List? photoBytes = _decode(photoBase64);

  static Uint8List? _decode(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }

  bool get hasPhoto => photoBytes != null;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'B';
    final first = parts.first[0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? photoBase64,
    bool clearPhoto = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photoBase64: clearPhoto ? null : (photoBase64 ?? this.photoBase64),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'photoBase64': photoBase64,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      photoBase64: json['photoBase64'] as String?,
    );
  }
}
