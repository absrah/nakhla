import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import 'category.dart';
import 'product.dart';

/// The only place that reads the catalog from Firestore.
/// Both methods return live streams: if an admin changes a price in the
/// console, the app updates by itself.
class CatalogRepository {
  CatalogRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// All categories, lowest `order` first.
  Stream<List<Category>> watchCategories() {
    return _db
        .collection('categories')
        .orderBy('order')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Category.fromMap(d.id, d.data())).toList(),
        )
        .handleError(_rethrowAsAppException);
  }

  /// All products, sorted by name.
  /// The catalog is small, so the app loads it once and filters it in memory.
  /// For a big catalog this would change to queries with paging.
  Stream<List<Product>> watchProducts() {
    return _db
        .collection('products')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => Product.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) => a.name.compareTo(b.name));
          return list;
        })
        .handleError(_rethrowAsAppException);
  }

  void _rethrowAsAppException(Object error) {
    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        throw const AppException(
          'You do not have permission to see the catalog.',
        );
      }
      if (error.code == 'unavailable') {
        throw const AppException(
          'No connection. Check your internet and try again.',
        );
      }
    }
    throw const AppException('Could not load the catalog.');
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(),
);
