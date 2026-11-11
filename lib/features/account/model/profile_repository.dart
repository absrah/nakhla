import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/model/app_user.dart';

/// Reads and edits the shopper's profile at users/{uid}.
/// (Creating it happens once, at sign up, in the auth repository.)
class ProfileRepository {
  ProfileRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  /// Users whose missing profile is being created right now (no double work).
  final Set<String> _healing = {};

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  /// The live profile. If the server says the document is missing, it is
  /// created from the login account (self-heal) and then shows up here.
  Stream<AppUser?> watchProfile(User user) {
    return _doc(user.uid)
        .snapshots(includeMetadataChanges: true)
        .map((snap) {
          final data = snap.data();
          if (data == null) {
            // Only trust "missing" when the answer came from the server; the
            // phone's cache may simply not have the document yet.
            if (!snap.metadata.isFromCache) unawaited(_createMissing(user));
            return null;
          }
          return AppUser.fromMap(user.uid, data);
        })
        .handleError(
          (Object error) =>
              throw const AppException('Could not load your profile.'),
        );
  }

  /// Writes a basic profile for an account that has none. The phone number
  /// is unknown here, so it starts empty (the shopper can add it in Edit
  /// profile). Errors are ignored: it is tried again next time.
  Future<void> _createMissing(User user) async {
    if (!_healing.add(user.uid)) return;
    final email = user.email ?? '';
    var name = (user.displayName ?? '').trim();
    if (name.length < 2) name = email.split('@').first;
    if (name.length < 2) name = 'Shopper';
    if (name.length > 80) name = name.substring(0, 80);

    try {
      await _doc(user.uid).set({
        ...AppUser(uid: user.uid, name: name, email: email).toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      _healing.remove(user.uid); // allow another try later
    }
  }

  /// Changes the name and phone. Email and createdAt can never change (the
  /// security rules enforce that too).
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    try {
      await _doc(uid)
          .update({'name': name.trim(), 'phone': phone.trim()})
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
      throw const AppException(
        'We could not save your changes. Please try again.',
      );
    }

    // Keep the name stored inside the login account in step. If this part
    // fails the profile is still saved, so it is not worth an error.
    try {
      await _auth.currentUser?.updateDisplayName(name.trim());
    } catch (_) {}
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);
