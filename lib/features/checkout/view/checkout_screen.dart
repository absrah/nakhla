import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../address/view/widgets/address_card.dart';
import '../../address/view_model/address_providers.dart';
import '../../cart/model/cart_line.dart';
import '../../cart/view_model/cart_providers.dart';
import '../model/checkout_totals.dart';
import '../model/delivery_option.dart';
import '../view_model/checkout_providers.dart';
import '../../../core/widgets/app_back_button.dart';

/// Step 1 of checkout: where to deliver and how fast.
/// Payment (step 2) comes next.
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartLinesProvider);
    final summary = ref.watch(cartSummaryProvider);
    final address = ref.watch(selectedAddressProvider);
    final canContinue =
        address != null && !summary.isEmpty && !summary.hasUnavailable;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallback: AppRoutes.cart),
        title: const Text('Checkout'),
      ),
      body: lines.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(cartItemsProvider),
        ),
        data: (list) => list.isEmpty
            ? const EmptyView(
                icon: Icons.shopping_cart_outlined,
                message: 'Your cart is empty.',
              )
            : _Content(hasAddress: address != null),
      ),
      bottomNavigationBar: lines.hasValue && !summary.isEmpty
          ? _ContinueBar(summary: summary, enabled: canContinue, hasAddress: address != null)
          : null,
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.hasAddress});

  final bool hasAddress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(checkoutTotalsProvider);
    final selected = ref.watch(deliveryOptionProvider);

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 4.w, 20.w, 24.w),
      children: [
        _Steps(hasAddress: hasAddress),
        SizedBox(height: 24.w),
        const _SectionTitle('Shipping address'),
        SizedBox(height: 12.w),
        const _AddressSection(),
        SizedBox(height: 24.w),
        const _SectionTitle('Delivery option'),
        SizedBox(height: 12.w),
        for (final option in DeliveryOption.values) ...[
          _DeliveryTile(
            option: option,
            selected: option == selected,
            onTap: () => ref.read(deliveryOptionProvider.notifier).select(option),
          ),
          SizedBox(height: 10.w),
        ],
        SizedBox(height: 14.w),
        _TotalsCard(totals: totals),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
    );
  }
}

/// Address ✓ · Delivery 2 · Payment 3
class _Steps extends StatelessWidget {
  const _Steps({required this.hasAddress});

  final bool hasAddress;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget step(String label, Widget mark, {bool active = false}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? p.accent : null,
              border: active ? null : Border.all(color: p.border),
            ),
            child: mark,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? null : p.muted,
            ),
          ),
        ],
      );
    }

    Text number(String n, {Color? color}) => Text(
          n,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: color),
        );

    Widget line() => Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Divider(color: p.border),
          ),
        );

    return Row(
      children: [
        step(
          'Address',
          hasAddress
              ? Icon(Icons.check, size: 15.w, color: p.onAccent)
              : number('1', color: p.muted),
          active: hasAddress,
        ),
        line(),
        step('Delivery', number('2', color: p.onAccent), active: true),
        line(),
        step('Payment', number('3', color: p.muted)),
      ],
    );
  }
}

class _AddressSection extends ConsumerWidget {
  const _AddressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final addresses = ref.watch(addressesProvider);
    final address = ref.watch(selectedAddressProvider);

    if (address == null) {
      if (addresses.isLoading) {
        return SizedBox(height: 80.w, child: const LoadingView());
      }
      if (addresses.hasError) {
        return ErrorView(
          error: addresses.error!,
          onRetry: () => ref.invalidate(addressesProvider),
        );
      }
      // Logged in but no address yet.
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push(AppRoutes.addressForm),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              Icon(Icons.add_location_alt_outlined, size: 24.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Add a delivery address',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right, color: p.muted),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        AddressCard(
          address: address,
          selected: true,
          trailing: TextButton(
            onPressed: () => context.push(AppRoutes.addressesPick),
            child: const Text('Change'),
          ),
        ),
        SizedBox(height: 10.w),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.addressForm),
          icon: const Icon(Icons.add),
          label: const Text('Add new address'),
          style: OutlinedButton.styleFrom(minimumSize: Size.fromHeight(48.w)),
        ),
      ],
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  const _DeliveryTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final DeliveryOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? scheme.primary : p.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 22.w,
              color: selected ? scheme.primary : p.muted,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    option.eta,
                    style: TextStyle(fontSize: 13.sp, color: p.muted),
                  ),
                ],
              ),
            ),
            Text(
              option.fee == 0 ? 'Free' : formatSar(option.fee),
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.totals});

  final CheckoutTotals totals;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    Widget row(String label, String value, {bool bold = false}) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: bold ? 18.sp : 15.sp,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: bold ? null : p.muted,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: bold ? 18.sp : 15.sp,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: bold ? null : onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          row(
            'Subtotal (${totals.itemCount} ${totals.itemCount == 1 ? 'item' : 'items'})',
            formatSar(totals.subtotalExVat),
          ),
          row(
            'Delivery',
            totals.deliveryFee == 0 ? 'Free' : formatSar(totals.deliveryExVat),
          ),
          row('VAT (15%)', formatSar(totals.vat)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.w),
            child: const Divider(),
          ),
          row('Total', formatSar(totals.total), bold: true),
          Padding(
            padding: EdgeInsets.only(top: 2.w),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                'Prices include VAT',
                style: TextStyle(fontSize: 12.sp, color: p.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueBar extends ConsumerWidget {
  const _ContinueBar({
    required this.summary,
    required this.enabled,
    required this.hasAddress,
  });

  final CartSummary summary;
  final bool enabled;
  final bool hasAddress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final totals = ref.watch(checkoutTotalsProvider);

    String? hint;
    if (summary.hasUnavailable) {
      hint = 'Some items are no longer available. Fix your cart first.';
    } else if (!hasAddress) {
      hint = 'Add a delivery address to continue.';
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hint != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8.w),
                child: Text(
                  hint,
                  style: TextStyle(fontSize: 13.sp, color: p.link),
                ),
              ),
            FilledButton(
              onPressed: enabled
                  ? () {
                      // TEMPORARY until the payment screen (next batch).
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('Payment comes in the next step')),
                        );
                    }
                  : null,
              style: FilledButton.styleFrom(minimumSize: Size.fromHeight(56.w)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Continue to payment'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatSar(totals.total)),
                      SizedBox(width: 4.w),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}