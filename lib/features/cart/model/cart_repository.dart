import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import 'cart_item.dart';

/// The only place that reads and writes the cart in Firestore:
/// users/{uid}/cart/{productId}, with `quantity` and `addedAt`.
class CartRepository {
  CartRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _cart(String uid) =>
      _db.collection('users').doc(uid).collection('cart');

  /// Live cart, oldest item first.
  Stream<List<CartItem>> watchCart(String uid) {
    return _cart(uid)
        .snapshots()
        .map((snap) {
          final items =
              snap.docs.map((d) => CartItem.fromMap(d.id, d.data())).toList();
          items.sort((a, b) {
            final x = a.addedAt;
            final y = b.addedAt;
            if (x == null && y == null) return 0;
            if (x == null) return 1; // just added: show last
            if (y == null) return -1;
            return x.compareTo(y);
          });
          return items;
        })
        .handleError(_rethrowAsAppException);
  }

  /// Adds [quantity] of a product, never going above [maxQuantity].
  /// Returns false when the cart already held the maximum.
  Future<bool> addItem(
    String uid,
    String productId, {
    required int quantity,
    required int maxQuantity,
  }) async {
    final ref = _cart(uid).doc(productId);
    try {
      return await _db.runTransaction<bool>((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) {
          tx.set(ref, {
            'quantity': quantity > maxQuantity ? maxQuantity : quantity,
            'addedAt': FieldValue.serverTimestamp(),
          });
          return true;
        }
        final current = (snap.data()?['quantity'] as num?)?.toInt() ?? 0;
        if (current >= maxQuantity) return false;
        final next = current + quantity;
        tx.update(ref, {'quantity': next > maxQuantity ? maxQuantity : next});
        return true;
      });
    } on FirebaseException catch (e) {
      throw _toAppException(e);
    }
  }

  Future<void> setQuantity(String uid, String productId, int quantity) async {
    try {
      await _cart(uid).doc(productId).update({'quantity': quantity});
    } on FirebaseException catch (e) {
      throw _toAppException(e);
    }
  }

  Future<void> remove(String uid, String productId) async {
    try {
      await _cart(uid).doc(productId).delete();
    } on FirebaseException catch (e) {
      throw _toAppException(e);
    }
  }

  void _rethrowAsAppException(Object error) => throw _toAppException(error);

  AppException _toAppException(Object error) {
    if (error is FirebaseException) {
      if (error.code == 'unavailable') {
        return const AppException('No connection. Check your internet and try again.');
      }
      if (error.code == 'permission-denied') {
        return const AppException('We could not update your cart. Please try again.');
      }
    }
    return const AppException('We could not update your cart.');
  }
}

final cartRepositoryProvider =
    Provider<CartRepository>((ref) => CartRepository());