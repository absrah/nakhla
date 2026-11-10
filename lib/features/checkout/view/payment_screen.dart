import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/state_views.dart';
import '../../address/model/address.dart';
import '../../address/view_model/address_providers.dart';
import '../../cart/view_model/cart_providers.dart';
import '../../order/view_model/order_providers.dart';
import '../../order/view_model/order_view_model.dart';
import '../model/delivery_option.dart';
import '../view_model/checkout_providers.dart';
import 'widgets/checkout_steps.dart';
import 'widgets/totals_card.dart';
import '../../cart/model/cart_line.dart';

/// Step 2 of checkout: pick how to pay and place the order.
/// Only cash on delivery works for now; the others say "Coming soon".
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _placing = false;
  String? _error;

  Future<void> _place() async {
    if (_placing) return;
    setState(() {
      _placing = true;
      _error = null;
    });

    try {
      final orderId = await ref
          .read(orderViewModelProvider)
          .placeOrder(option: ref.read(deliveryOptionProvider));
      if (!mounted) return;
      // go, not push: the checkout pages must not stay in the back stack.
      context.go(AppRoutes.orderPlacedPath(orderId));
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _placing = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(cartLinesProvider);
    final summary = ref.watch(cartSummaryProvider);
    final address = ref.watch(selectedAddressProvider);
    final option = ref.watch(deliveryOptionProvider);
    final totals = ref.watch(checkoutTotalsProvider);
    // Start listening to the orders now, so the new order is already there
    // when the "Order placed" screen opens.
    ref.watch(ordersProvider);

    final canPlace =
        address != null && !summary.isEmpty && !summary.hasUnavailable;

        // Say exactly what is wrong with the cart, if anything.
    String? stockMessage;
    for (final line in lines.value ?? const <CartLine>[]) {
      if (line.available) continue;
      final stock = line.product.stock;
      stockMessage = stock == 0
          ? '"${line.product.name}" is out of stock. Remove it from your cart.'
          : 'Only $stock of "${line.product.name}" left. Lower the quantity.';
      break;
    }

    final Widget body;
    if (_placing) {
      body = const _Placing();
    } else {
      body = lines.when(
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
            : ListView(
                padding: EdgeInsets.fromLTRB(20.w, 4.w, 20.w, 24.w),
                children: [
                  const CheckoutSteps(step: 3),
                  SizedBox(height: 24.w),
                  const _SectionTitle('Payment method'),
                  SizedBox(height: 12.w),
                  const _MethodTile(
                    icon: Icons.credit_card,
                    title: 'Card',
                    subtitle: 'Credit or debit card',
                    comingSoon: true,
                  ),
                  SizedBox(height: 10.w),
                  const _MethodTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Digital wallet',
                    subtitle: 'Apple Pay and Nakhla wallet',
                    comingSoon: true,
                  ),
                  SizedBox(height: 10.w),
                  const _MethodTile(
                    icon: Icons.payments_outlined,
                    title: 'Cash on delivery',
                    subtitle: 'Pay when your order arrives',
                    selected: true,
                  ),
                  SizedBox(height: 24.w),
                  const _SectionTitle('Order summary'),
                  SizedBox(height: 12.w),
                  _Recap(address: address, option: option),
                  SizedBox(height: 12.w),
                  TotalsCard(totals: totals),
                ],
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallback: AppRoutes.checkout),
        title: const Text('Payment'),
      ),
      body: body,
      bottomNavigationBar: (!_placing && lines.hasValue && !summary.isEmpty)
          ? _PlaceBar(
              enabled: canPlace,
              hasAddress: address != null,
              stockMessage: stockMessage,
              error: _error,
              label: 'Place order · ${formatSar(totals.total)}',
              onPressed: _place,
            )
          : null,
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

class _Placing extends StatelessWidget {
  const _Placing();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 16.w),
          Text(
            'Placing your order…',
            style: TextStyle(fontSize: 15.sp, color: p.muted),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.selected = false,
    this.comingSoon = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final scheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: comingSoon ? 0.55 : 1,
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
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: p.tileFor(title),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, size: 24.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13.sp, color: p.muted),
                  ),
                ],
              ),
            ),
            if (comingSoon)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: p.border),
                ),
                child: Text(
                  'Coming soon',
                  style: TextStyle(fontSize: 12.sp, color: p.muted),
                ),
              )
            else
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 22.w,
                color: selected ? scheme.primary : p.muted,
              ),
          ],
        ),
      ),
    );
  }
}

/// Where the order goes and how fast, as a reminder before paying.
class _Recap extends StatelessWidget {
  const _Recap({required this.address, required this.option});

  final Address? address;
  final DeliveryOption option;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget row(IconData icon, String text) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.w, color: p.muted),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14.sp, height: 1.3)),
          ),
        ],
      );
    }

    final where = address == null
        ? 'No delivery address chosen'
        : '${address!.label}: ${address!.streetLine}, ${address!.cityLine}';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          row(Icons.location_on_outlined, where),
          SizedBox(height: 10.w),
          row(
            Icons.local_shipping_outlined,
            '${option.title} · ${option.eta}',
          ),
        ],
      ),
    );
  }
}

class _PlaceBar extends StatelessWidget {
  const _PlaceBar({
    required this.enabled,
    required this.hasAddress,
    required this.stockMessage,
    required this.error,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final bool hasAddress;
  final String? stockMessage;
  final String? error;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    String? hint;
    if (stockMessage != null) {
      hint = stockMessage;
    } else if (!hasAddress) {
      hint = 'Go back and choose a delivery address.';
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
            if (error != null) ...[
              ErrorBanner(error!),
              SizedBox(height: 10.w),
            ],
            if (hint != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8.w),
                child: Text(
                  hint,
                  style: TextStyle(fontSize: 13.sp, color: p.link),
                ),
              ),
            FilledButton(
              onPressed: enabled ? onPressed : null,
              style: FilledButton.styleFrom(minimumSize: Size.fromHeight(56.w)),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}