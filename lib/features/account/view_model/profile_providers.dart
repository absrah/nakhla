import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/model/app_user.dart';
import '../../auth/view_model/session_provider.dart';
import '../model/profile_repository.dart';

/// The logged-in shopper's profile (null for a guest or if it is missing).
final profileProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchProfile(user);
});
