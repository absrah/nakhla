import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import 'app_user.dart';
import 'auth_error_mapper.dart';

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

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
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
      await user.updateDisplayName(name.trim());

      final profile = AppUser(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
      );
      await _userDoc(user.uid).set({
        ...profile.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw authExceptionFrom(e);
    } on FirebaseException {
      // The account exists but the profile could not be saved.
      throw const AppException(
        'Your account was created, but we could not save your profile.',
      );
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