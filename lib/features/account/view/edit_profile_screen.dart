import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/model/app_user.dart';
import '../view_model/profile_providers.dart';
import '../view_model/profile_view_model.dart';

/// Change your name and phone. The email is shown but cannot be changed.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallback: AppRoutes.account),
        title: const Text('Edit profile'),
      ),
      body: profile.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (user) => user == null
            ? const EmptyView(
                icon: Icons.person_off_outlined,
                message: 'We could not find your profile.',
              )
            : _ProfileForm(profile: user),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.profile});

  final AppUser profile;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _phone = TextEditingController(text: widget.profile.phone);
  bool _saving = false;
  String? _error;
  late final String _startName;
  late final String _startPhone;

  @override
  void initState() {
    super.initState();
    _startName = _name.text;
    _startPhone = _phone.text;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(profileViewModelProvider)
          .save(name: _name.text, phone: _phone.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Profile updated')));
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.account);
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 32.w),
        children: [
          if (_error != null) ...[ErrorBanner(_error!), SizedBox(height: 16.w)],
          AppTextField(
            label: 'Name',
            controller: _name,
            validator: Validators.name,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
          ),
          SizedBox(height: 16.w),
          AppTextField(
            label: 'Phone (optional)',
            controller: _phone,
            validator: Validators.phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          SizedBox(height: 16.w),
          // Shown, not editable: the login email is the account's identity.
          TextFormField(
            initialValue: widget.profile.email,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Email',
              helperText: 'Your email cannot be changed here.',
            ),
          ),
          SizedBox(height: 24.w),
          ListenableBuilder(
            listenable: Listenable.merge([_name, _phone]),
            builder: (context, _) {
              final valid =
                  Validators.name(_name.text) == null &&
                  Validators.phone(_phone.text) == null;
              final changed =
                  _name.text.trim() != _startName.trim() ||
                  _phone.text.trim() != _startPhone.trim();
              return LoadingButton(
                label: 'Save changes',
                isLoading: _saving,
                onPressed: valid && changed ? _save : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
