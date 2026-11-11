import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../address/model/address.dart';
import '../../cart/model/cart_line.dart';
import '../../catalog/model/product.dart';
import '../../checkout/model/delivery_option.dart';
import 'order.dart';
import 'order_status.dart';
import 'dart:async';

/// The only place that reads and writes orders in Firestore: orders/{orderId}.
class OrderRepository {
  OrderRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// The shopper's orders, newest first. No orderBy in the query (that would
  /// need an index); the small list is sorted here instead.
  Stream<List<Order>> watchOrders(String uid) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => Order.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) {
            final x = a.createdAt;
            final y = b.createdAt;
            if (x == null && y == null) return 0;
            if (x == null) return -1; // just placed: newest
            if (y == null) return 1;
            return y.compareTo(x);
          });
          return list;
        })
        .handleError(_rethrowAsAppException);
  }

  /// Places an order in ONE transaction:
  /// 1. reads the current price and stock of every product,
  /// 2. stops if something changed since the shopper saw it,
  /// 3. creates the order (with the prices just read) and empties the cart.
  /// Either all of it happens or none of it. Returns the new order id.
  Future<String> placeOrder({
    required String uid,
    required List<CartLine> lines,
    required Address address,
    required DeliveryOption option,
    required double expectedSubtotal,
  }) async {
    final orderRef = _db.collection('orders').doc();
    final cart = _db.collection('users').doc(uid).collection('cart');

    try {
      await _db.runTransaction<void>((tx) async {
        // All reads first (a transaction must read before it writes).
        final items = <OrderItem>[];
        for (final line in lines) {
          final snap = await tx.get(
            _db.collection('products').doc(line.product.id),
          );
          final data = snap.data();
          if (data == null) {
            throw AppException(
              '"${line.product.name}" is no longer sold. Remove it from your cart.',
            );
          }
          final product = Product.fromMap(snap.id, data);
          if (product.stock < line.quantity) {
            throw AppException(
              product.stock == 0
                  ? '"${product.name}" is out of stock. Remove it from your cart.'
                  : 'Only ${product.stock} of "${product.name}" left. Lower the quantity.',
            );
          }
          items.add(
            OrderItem(
              productId: product.id,
              name: product.name,
              price: product.price,
              quantity: line.quantity,
            ),
          );
        }

        final subtotal = items.fold<double>(0, (acc, i) => acc + i.lineTotal);
        if ((subtotal - expectedSubtotal).abs() > 0.001) {
          throw const AppException(
            'Some prices changed. Please review your cart and try again.',
          );
        }

        // Then the writes.
        tx.set(orderRef, {
          'userId': uid,
          'status': OrderStatus.placed.value,
          'paymentMethod': 'cod',
          'deliveryOption': option.name,
          'deliveryFee': option.fee,
          'subtotal': subtotal,
          'total': subtotal + option.fee,
          'itemCount': items.fold<int>(0, (acc, i) => acc + i.quantity),
          'items': [for (final item in items) item.toMap()],
          'address': address.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        for (final line in lines) {
          tx.delete(cart.doc(line.product.id));
        }
      });
      return orderRef.id;
    } on FirebaseException catch (e) {
      throw _toAppException(e);
    }
  }

  /// Cancels an order that is still "placed". The security rules allow only
  /// that one change.
  Future<void> cancelOrder(String orderId) async {
    try {
      await _db
          .collection('orders')
          .doc(orderId)
          .update({'status': OrderStatus.cancelled.value})
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const AppException(
        'No connection. Check your internet and try again.',
      );
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        throw const AppException(
          'No connection. Check your internet and try again.',
        );
      }
      if (e.code == 'permission-denied') {
        throw const AppException('This order can no longer be cancelled.');
      }
      throw const AppException(
        'We could not cancel this order. Please try again.',
      );
    }
  }

  void _rethrowAsAppException(Object error) => throw _toAppException(error);

  AppException _toAppException(Object error) {
    if (error is FirebaseException) {
      if (error.code == 'unavailable') {
        return const AppException(
          'No connection. Check your internet and try again.',
        );
      }
      if (error.code == 'permission-denied') {
        return const AppException(
          'We could not place your order. Please try again.',
        );
      }
    }
    return const AppException(
      'We could not complete your order. Please try again.',
    );
  }
}

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(),
);
