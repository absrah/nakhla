import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../model/auth_repository.dart';
import 'auth_action_state.dart';

class ForgotPasswordViewModel extends Notifier<AuthActionState> {
  @override
  AuthActionState build() => const AuthActionState();

  Future<void> sendReset(String email) async {
    if (state.isLoading) return;
    state = const AuthActionState(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      if (!ref.mounted) return;
      state = const AuthActionState(done: true);
    } on AppException catch (e) {
      if (!ref.mounted) return;
      state = AuthActionState(error: e.message);
    }
  }
}

final forgotPasswordViewModelProvider =
    NotifierProvider.autoDispose<ForgotPasswordViewModel, AuthActionState>(
  ForgotPasswordViewModel.new,
);