import 'package:cloud_firestore/cloud_firestore.dart';

/// One saved product, stored at users/{uid}/wishlist/{productId}.
/// It holds only when it was saved; the name and price are read live from
/// the product, like the cart.
class WishlistEntry {
  const WishlistEntry({required this.productId, this.addedAt});

  final String productId; // also the document id
  final DateTime? addedAt; // null for a moment right after saving

  factory WishlistEntry.fromMap(String productId, Map<String, dynamic> map) {
    final added = map['addedAt'];
    return WishlistEntry(
      productId: productId,
      addedAt: added is Timestamp ? added.toDate() : null,
    );
  }
}
