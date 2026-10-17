
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/loading_button.dart';
import '../view_model/log_in_view_model.dart';
import 'package:go_router/go_router.dart';      // with the other package: imports
import '../../../core/router/app_routes.dart';  // with the other relative imports

class LogInScreen extends ConsumerStatefulWidget {
  const LogInScreen({super.key});

  @override
  ConsumerState<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends ConsumerState<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(logInViewModelProvider.notifier).logIn(
          email: _email.text,
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logInViewModelProvider);
    final p = context.palette;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 56.h),
                  // Placeholder mark until the real logo file is added.
                  Center(
                    child: Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        color: p.accent,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 36.w,
                        color: p.onAccent,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: text.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Log in to continue shopping',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: p.muted),
                  ),
                  SizedBox(height: 32.h),
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
                    label: 'Password',
                    controller: _password,
                    validator: Validators.password,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _submit(),
                    enabled: !state.isLoading,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      // TEMPORARY navigation until the router is added.
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (state.error != null) ...[
                    ErrorBanner(state.error!),
                    SizedBox(height: 16.h),
                  ],
                  LoadingButton(
                    label: 'Log in',
                    isLoading: state.isLoading,
                    onPressed: _submit,
                  ),
                  SizedBox(height: 12.h),
                  OutlinedButton(
                    // TEMPORARY navigation until the router is added.
                  onPressed: () => context.push(AppRoutes.signUp),
                    child: const Text('Sign up'),
                  ),
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: const Text('Continue as guest'),
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