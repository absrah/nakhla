import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import 'seed_data.dart';

/// DEV TOOL: writes the sample categories and products to Firestore.
/// Only an admin can do this (see the security rules). Running it again is
/// safe: the same ids are overwritten, nothing is duplicated.
class CatalogSeeder {
  CatalogSeeder({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Returns how many documents were written.
  Future<int> seed() async {
    try {
      final batch = _db.batch();
      for (final category in seedCategories) {
        batch.set(_db.collection('categories').doc(category.id), category.toMap());
      }
      for (final product in seedProducts) {
        batch.set(_db.collection('products').doc(product.id), product.toMap());
      }
      await batch.commit();
      return seedCategories.length + seedProducts.length;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AppException(
          'Only an admin can write the catalog. Add your uid to admins in the console.',
        );
      }
      throw const AppException('Could not write the catalog.');
    }
  }
}

final catalogSeederProvider = Provider<CatalogSeeder>((ref) => CatalogSeeder());