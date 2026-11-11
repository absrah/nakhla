import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/auth_repository.dart';

/// Who is signed in right now: a user, or null for a guest.
/// The router watches this to decide which screens are allowed.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
