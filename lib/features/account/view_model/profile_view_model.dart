import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/view_model/session_provider.dart';
import '../model/profile_repository.dart';

/// The profile commands the screens can call.
class ProfileViewModel {
  ProfileViewModel(this._ref);

  final Ref _ref;

  Future<void> save({required String name, required String phone}) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) throw const AppException('Log in to edit your profile.');
    await _ref
        .read(profileRepositoryProvider)
        .updateProfile(uid: user.uid, name: name, phone: phone);
  }
}

final profileViewModelProvider = Provider<ProfileViewModel>(
  (ref) => ProfileViewModel(ref),
);
