import 'package:cloud_firestore/cloud_firestore.dart';

/// A delivery address, stored at users/{uid}/addresses/{addressId}.
class Address {
  const Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.city,
    required this.district,
    required this.street,
    this.postalCode = '',
    this.createdAt,
  });

  /// The labels a shopper can pick (the security rules accept only these).
  static const labels = ['Home', 'Work', 'Other'];

  final String id; // the document id, empty for a new address
  final String label; // Home, Work or Other
  final String name; // who receives the package
  final String phone;
  final String city;
  final String district;
  final String street; // street and building
  final String postalCode; // optional, may be empty
  final DateTime? createdAt;

  /// "King Road 12, Al Olaya"
  String get streetLine => '$street, $district';

  /// "Riyadh 12211" (or just "Riyadh" without a postal code)
  String get cityLine => postalCode.isEmpty ? city : '$city $postalCode';

  factory Address.fromMap(String id, Map<String, dynamic> map) {
    final created = map['createdAt'];
    return Address(
      id: id,
      label: map['label'] as String? ?? 'Home',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      city: map['city'] as String? ?? '',
      district: map['district'] as String? ?? '',
      street: map['street'] as String? ?? '',
      postalCode: map['postalCode'] as String? ?? '',
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  /// createdAt is left out on purpose: the repository sets it once, with the
  /// server's clock, when the address is created.
  Map<String, dynamic> toMap() => {
    'label': label,
    'name': name,
    'phone': phone,
    'city': city,
    'district': district,
    'street': street,
    'postalCode': postalCode,
  };
}
