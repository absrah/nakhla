import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import 'address.dart';

/// The only place that reads and writes addresses in Firestore:
/// users/{uid}/addresses/{addressId}.
class AddressRepository {
  AddressRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// A write waits for the server. Without a connection it would wait
  /// forever, so we give up after this long and tell the user.
  static const _writeTimeout = Duration(seconds: 15);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('addresses');

  /// Live list, oldest address first.
  Stream<List<Address>> watchAddresses(String uid) {
    return _col(uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => Address.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) {
            final x = a.createdAt;
            final y = b.createdAt;
            if (x == null && y == null) return 0;
            if (x == null) return 1; // just added: show last
            if (y == null) return -1;
            return x.compareTo(y);
          });
          return list;
        })
        .handleError(_rethrowAsAppException);
  }

  /// Saves a new address and returns its id.
  Future<String> add(String uid, Address address) async {
    try {
      final ref = await _col(uid)
          .add({...address.toMap(), 'createdAt': FieldValue.serverTimestamp()})
          .timeout(_writeTimeout);
      return ref.id;
    } on FirebaseException catch (e) {
      throw _toAppException(e);
    } on TimeoutException {
      throw _toAppException(null);
    }
  }

  Future<void> update(String uid, Address address) async {
    try {
      await _col(
        uid,
      ).doc(address.id).update(address.toMap()).timeout(_writeTimeout);
    } on FirebaseException catch (e) {
      throw _toAppException(e);
    } on TimeoutException {
      throw _toAppException(null);
    }
  }

  Future<void> delete(String uid, String addressId) async {
    try {
      await _col(uid).doc(addressId).delete().timeout(_writeTimeout);
    } on FirebaseException catch (e) {
      throw _toAppException(e);
    } on TimeoutException {
      throw _toAppException(null);
    }
  }

  void _rethrowAsAppException(Object error) => throw _toAppException(error);

  AppException _toAppException(Object? error) {
    if (error == null) {
      return const AppException(
        'This is taking too long. Check your internet and try again.',
      );
    }
    if (error is FirebaseException && error.code == 'unavailable') {
      return const AppException(
        'No connection. Check your internet and try again.',
      );
    }
    return const AppException(
      'We could not save your address. Please try again.',
    );
  }
}

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => AddressRepository(),
);
