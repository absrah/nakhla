import 'package:cloud_firestore/cloud_firestore.dart';

/// A signed-in shopper, stored at users/{uid} in Firestore.
/// Named AppUser so it does not clash with Firebase's own `User`.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.language = 'en',
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final String language; // 'en' or 'ar'
  final DateTime? createdAt;

  /// The uid is the document id, so it is not stored inside the document.
  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    final created = map['createdAt'];
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      language: map['language'] as String? ?? 'en',
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  /// createdAt is left out on purpose: the repository sets it once, with the
  /// server's clock, when the account is created.
  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'language': language,
  };

  AppUser copyWith({String? name, String? phone, String? language}) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      language: language ?? this.language,
      createdAt: createdAt,
    );
  }
}
