import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/loading_button.dart';
import '../view_model/sign_up_view_model.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(signUpViewModelProvider.notifier).signUp(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          phone: _phone.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpViewModelProvider);
    final p = context.palette;
    final text = Theme.of(context).textTheme;

    // TEMPORARY: close this screen once the account exists, so the gate
    // underneath (now signed in) shows. The router will do this later.
    ref.listen(signUpViewModelProvider, (previous, next) {
      if (next.done) Navigator.of(context).pop();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    'Join Nakhla',
                    style: text.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Create an account to save your cart and orders',
                    style: text.bodyMedium?.copyWith(color: p.muted),
                  ),
                  SizedBox(height: 28.h),
                  AppTextField(
                    label: 'Full name',
                    controller: _name,
                    validator: Validators.name,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    enabled: !state.isLoading,
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    label: 'Email',
                    controller: _email,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    enabled: !state.isLoading,
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    label: 'Phone (optional)',
                    controller: _phone,
                    validator: Validators.phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    enabled: !state.isLoading,
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    label: 'Password',
                    controller: _password,
                    validator: Validators.password,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    enabled: !state.isLoading,
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    label: 'Confirm password',
                    controller: _confirm,
                    validator: (v) =>
                        Validators.confirmPassword(v, _password.text),
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    enabled: !state.isLoading,
                  ),
                  SizedBox(height: 24.h),
                  if (state.error != null) ...[
                    ErrorBanner(state.error!),
                    SizedBox(height: 16.h),
                  ],
                  LoadingButton(
                    label: 'Create account',
                    isLoading: state.isLoading,
                    onPressed: _submit,
                  ),
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Already have an account? Log in'),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}