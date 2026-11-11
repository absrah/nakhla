import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import 'app_user.dart';
import 'auth_error_mapper.dart';
import 'dart:async';

/// The only place in the app that talks to Firebase Auth for accounts.
/// Every method either works or throws an [AppException] with a message
/// that is safe to show to the user.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  /// Emits the signed-in user, or null when signed out. Firebase also
  /// restores the previous session on app start, so this covers "stay
  /// logged in" for free.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> logIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw authExceptionFrom(e);
    }
  }

  /// Creates the account, then saves the profile at users/{uid}.
  /// Creates the account, then saves the profile at users/{uid}.
  ///
  /// Once the account exists the shopper is logged in, so a failed profile
  /// save is NOT shown as an error: the profile repository notices the
  /// missing document later and creates it again (see watchProfile).
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      try {
        await user.updateDisplayName(name.trim());
      } catch (_) {
        // Only a copy of the name; the profile document is what counts.
      }

      final profile = AppUser(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
      );
      try {
        await _userDoc(user.uid)
            .set({
              ...profile.toMap(),
              'createdAt': FieldValue.serverTimestamp(),
            })
            .timeout(const Duration(seconds: 15));
      } on TimeoutException {
        // Offline: the write waits on the phone and is sent once online.
      } on FirebaseException {
        // Saved later by ProfileRepository.watchProfile (self-heal).
      }
    } on FirebaseAuthException catch (e) {
      throw authExceptionFrom(e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw authExceptionFrom(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// The saved profile, or null if the user has none yet.
  Future<AppUser?> getProfile(String uid) async {
    try {
      final snapshot = await _userDoc(uid).get();
      final data = snapshot.data();
      if (data == null) return null;
      return AppUser.fromMap(uid, data);
    } on FirebaseException {
      throw const AppException('Could not load your profile.');
    }
  }
}

/// How the rest of the app gets the repository. ViewModels use
/// `ref.read(authRepositoryProvider)`; tests can swap in a fake one.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
