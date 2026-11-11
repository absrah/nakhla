import 'package:cloud_firestore/cloud_firestore.dart';

/// One line in a shopper's cart, stored at users/{uid}/cart/{productId}.
/// It holds only the product id and how many. The name and price are read
/// live from the product, so a price change shows up in the cart at once.
class CartItem {
  const CartItem({
    required this.productId,
    required this.quantity,
    this.addedAt,
  });

  final String productId; // also the document id
  final int quantity;
  final DateTime? addedAt; // null for a moment right after adding

  factory CartItem.fromMap(String productId, Map<String, dynamic> map) {
    final added = map['addedAt'];
    return CartItem(
      productId: productId,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      addedAt: added is Timestamp ? added.toDate() : null,
    );
  }
}
