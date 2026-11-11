import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../model/auth_repository.dart';
import 'auth_action_state.dart';

class SignUpViewModel extends Notifier<AuthActionState> {
  @override
  AuthActionState build() => const AuthActionState();

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    if (state.isLoading) return;
    state = const AuthActionState(isLoading: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(name: name, email: email, password: password, phone: phone);
      if (!ref.mounted) return;
      state = const AuthActionState(done: true);
    } on AppException catch (e) {
      if (!ref.mounted) return;
      state = AuthActionState(error: e.message);
    } catch (_) {
      if (!ref.mounted) return;
      state = const AuthActionState(
        error: 'Something went wrong. Please try again.',
      );
    }
  }
}

final signUpViewModelProvider =
    NotifierProvider.autoDispose<SignUpViewModel, AuthActionState>(
      SignUpViewModel.new,
    );
