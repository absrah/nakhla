import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/view_model/session_provider.dart';
import '../model/address.dart';
import '../view_model/address_providers.dart';
import '../view_model/address_view_model.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_back_button.dart';

/// Add a new address, or edit one when [addressId] is given.
class AddressFormScreen extends ConsumerWidget {
  const AddressFormScreen({super.key, this.addressId});

  final String? addressId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget body;
    if (addressId == null) {
      body = const _AddressForm();
    } else {
      body = ref.watch(addressesProvider).when(
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(addressesProvider),
            ),
            data: (list) {
              for (final address in list) {
                if (address.id == addressId) return _AddressForm(existing: address);
              }
              return const EmptyView(
                icon: Icons.location_off_outlined,
                message: 'This address was not found.',
              );
            },
          );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallback: AppRoutes.addresses),
        title: Text(addressId == null ? 'Add address' : 'Edit address'),
      ),
      body: body,
    );
  }
}

class _AddressForm extends ConsumerStatefulWidget {
  const _AddressForm({this.existing});

  final Address? existing;

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _district;
  late final TextEditingController _street;
  late final TextEditingController _postal;
  late String _label;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    // A new address starts with the name from the account.
    final accountName = ref.read(authStateProvider).value?.displayName ?? '';
    _name = TextEditingController(text: a?.name ?? accountName);
    _phone = TextEditingController(text: a?.phone ?? '');
    _city = TextEditingController(text: a?.city ?? '');
    _district = TextEditingController(text: a?.district ?? '');
    _street = TextEditingController(text: a?.street ?? '');
    _postal = TextEditingController(text: a?.postalCode ?? '');
    _label = a?.label ?? Address.labels.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _district.dispose();
    _street.dispose();
    _postal.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });

    final existing = widget.existing;
    final draft = Address(
      id: existing?.id ?? '',
      label: _label,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      city: _city.text.trim(),
      district: _district.text.trim(),
      street: _street.text.trim(),
      postalCode: _postal.text.trim(),
    );
    final viewModel = ref.read(addressViewModelProvider);

    try {
      final String? newId;
      if (existing == null) {
        newId = await viewModel.add(draft);
      } else {
        await viewModel.update(draft);
        newId = null;
      }
      if (!mounted) return;
      // A brand new address becomes the one used for this order.
      if (newId != null) {
        ref.read(selectedAddressIdProvider.notifier).select(newId);
      }
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.addresses);
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.w, 8.w, 24.w, 24.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Label', style: TextStyle(fontSize: 14.sp, color: p.muted)),
            SizedBox(height: 8.w),
            Wrap(
              spacing: 8.w,
              children: [
                for (final label in Address.labels)
                  ChoiceChip(
                    label: Text(label),
                    selected: _label == label,
                    showCheckmark: false,
                    selectedColor: p.accent,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _label == label ? p.onAccent : null,
                    ),
                    onSelected:
                        _saving ? null : (_) => setState(() => _label = label),
                  ),
              ],
            ),
            SizedBox(height: 16.w),
            AppTextField(
              label: 'Full name',
              controller: _name,
              validator: Validators.name,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              enabled: !_saving,
            ),
            SizedBox(height: 12.w),
            AppTextField(
              label: 'Phone number',
              controller: _phone,
              validator: Validators.requiredPhone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              enabled: !_saving,
            ),
            SizedBox(height: 12.w),
            AppTextField(
              label: 'City',
              controller: _city,
              validator: (v) => Validators.required(v, 'Enter the city'),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.addressCity],
              enabled: !_saving,
            ),
            SizedBox(height: 12.w),
            AppTextField(
              label: 'District',
              controller: _district,
              validator: (v) => Validators.required(v, 'Enter the district'),
              textInputAction: TextInputAction.next,
              enabled: !_saving,
            ),
            SizedBox(height: 12.w),
            AppTextField(
              label: 'Street and building',
              controller: _street,
              validator: (v) => Validators.required(v, 'Enter the street and building'),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.streetAddressLine1],
              enabled: !_saving,
            ),
            SizedBox(height: 12.w),
            AppTextField(
              label: 'Postal code (optional)',
              controller: _postal,
              validator: Validators.postalCode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.postalCode],
              onSubmitted: (_) => _save(),
              enabled: !_saving,
            ),
            SizedBox(height: 24.w),
            if (_error != null) ...[
              ErrorBanner(_error!),
              SizedBox(height: 16.w),
            ],
            LoadingButton(
              label: 'Save address',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}