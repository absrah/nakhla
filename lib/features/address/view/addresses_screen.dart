import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/state_views.dart';
import '../model/address.dart';
import '../view_model/address_providers.dart';
import '../view_model/address_view_model.dart';
import 'widgets/address_card.dart';
import '../../../core/widgets/app_back_button.dart';

/// The shopper's saved addresses. With [pick] (opened from checkout) tapping
/// an address chooses it and goes back; otherwise it is a plain manager.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key, this.pick = false});

  final bool pick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    final selectedId = ref.watch(selectedAddressProvider)?.id;
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallback: AppRoutes.account),
        title: Text(pick ? 'Choose address' : 'My addresses'),
      ),
      body: addresses.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(addressesProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyView(
              icon: Icons.location_off_outlined,
              message: 'You have no saved addresses yet.',
            );
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
            itemCount: list.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.w),
            itemBuilder: (context, i) {
              final address = list[i];
              return AddressCard(
                address: address,
                selected: pick && address.id == selectedId,
                onTap: pick
                    ? () {
                        ref
                            .read(selectedAddressIdProvider.notifier)
                            .select(address.id);
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.checkout);
                        }
                      }
                    : null,
                trailing: Column(
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => context.push(
                        AppRoutes.addressFormPath(id: address.id),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, ref, address),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 12.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: SafeArea(
          top: false,
          child: FilledButton.icon(
            onPressed: () => context.push(AppRoutes.addressForm),
            icon: const Icon(Icons.add),
            label: const Text('Add new address'),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Address address,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this address?'),
        content: Text('${address.label}: ${address.streetLine}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(addressViewModelProvider).delete(address.id);
    } on AppException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
