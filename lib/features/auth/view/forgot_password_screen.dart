import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/loading_button.dart';
import '../view_model/forgot_password_view_model.dart';
import 'package:go_router/go_router.dart';      
import '../../../core/router/app_routes.dart';  

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(forgotPasswordViewModelProvider.notifier).sendReset(_email.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordViewModelProvider);
    final p = context.palette;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: state.done
              ? _EmailSent(
                  email: _email.text.trim(),
                  onBack: () => context.go(AppRoutes.login),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 16.h),
                      Text(
                        'Forgot your password?',
                        style: text.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Enter your email and we will send you a link '
                        'to reset it.',
                        style: text.bodyMedium?.copyWith(color: p.muted),
                      ),
                      SizedBox(height: 28.h),
                      AppTextField(
                        label: 'Email',
                        controller: _email,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.email],
                        onSubmitted: (_) => _submit(),
                        enabled: !state.isLoading,
                      ),
                      SizedBox(height: 24.h),
                      if (state.error != null) ...[
                        ErrorBanner(state.error!),
                        SizedBox(height: 16.h),
                      ],
                      LoadingButton(
                        label: 'Send reset link',
                        isLoading: state.isLoading,
                        onPressed: _submit,
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text('Back to log in'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Shown after the reset email was requested.
class _EmailSent extends StatelessWidget {
  const _EmailSent({required this.email, required this.onBack});

  final String email;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 48.h),
        Center(
          child: Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: p.accent,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              size: 36.w,
              color: p.onAccent,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8.h),
        // We do not say whether the email has an account (privacy).
        Text(
          'If an account exists for $email, we sent a link to reset your '
          'password. Check your spam folder if you do not see it.',
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: p.muted),
        ),
        SizedBox(height: 32.h),
        FilledButton(onPressed: onBack, child: const Text('Back to log in')),
      ],
    );
  }
}