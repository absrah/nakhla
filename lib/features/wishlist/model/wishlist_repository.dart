import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import 'wishlist_entry.dart';

/// The only place that reads and writes the wishlist in Firestore:
/// users/{uid}/wishlist/{productId}, with `addedAt`.
class WishlistRepository {
  WishlistRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _list(String uid) =>
      _db.collection('users').doc(uid).collection('wishlist');

  /// Live wishlist, most recently saved first.
  Stream<List<WishlistEntry>> watch(String uid) {
    return _list(uid)
        .snapshots()
        .map((snap) {
          final entries = snap.docs
              .map((d) => WishlistEntry.fromMap(d.id, d.data()))
              .toList();
          entries.sort((a, b) {
            final x = a.addedAt;
            final y = b.addedAt;
            if (x == null && y == null) return 0;
            if (x == null) return -1; // just saved: show first
            if (y == null) return 1;
            return y.compareTo(x);
          });
          return entries;
        })
        .handleError(_rethrowAsAppException);
  }

  Future<void> add(String uid, String productId) {
    return _write(
      () => _list(
        uid,
      ).doc(productId).set({'addedAt': FieldValue.serverTimestamp()}),
    );
  }

  Future<void> remove(String uid, String productId) {
    return _write(() => _list(uid).doc(productId).delete());
  }

  /// Runs a write. Firestore shows the change on the phone at once, so if
  /// the server does not answer in time (offline) the write simply stays
  /// queued and is sent when the connection returns; that is not an error.
  Future<void> _write(Future<void> Function() action) async {
    try {
      await action().timeout(const Duration(seconds: 8));
    } on TimeoutException {
      // Queued; nothing to tell the shopper.
    } on FirebaseException catch (e) {
      throw _toAppException(e);
    }
  }

  void _rethrowAsAppException(Object error) => throw _toAppException(error);

  AppException _toAppException(Object error) {
    if (error is FirebaseException && error.code == 'unavailable') {
      return const AppException(
        'No connection. Check your internet and try again.',
      );
    }
    return const AppException('We could not update your wishlist.');
  }
}

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => WishlistRepository(),
);
