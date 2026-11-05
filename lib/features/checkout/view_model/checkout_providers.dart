import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/view_model/cart_providers.dart';
import '../model/checkout_totals.dart';
import '../model/delivery_option.dart';

/// Which delivery option the shopper picked. Starts at Standard each time
/// the checkout is opened (autoDispose).
class DeliveryOptionViewModel extends Notifier<DeliveryOption> {
  @override
  DeliveryOption build() => DeliveryOption.standard;

  void select(DeliveryOption option) => state = option;
}

final deliveryOptionProvider =
    NotifierProvider.autoDispose<DeliveryOptionViewModel, DeliveryOption>(
  DeliveryOptionViewModel.new,
);

/// Cart subtotal + the delivery fee of the picked option.
final checkoutTotalsProvider = Provider.autoDispose<CheckoutTotals>((ref) {
  final cart = ref.watch(cartSummaryProvider);
  final option = ref.watch(deliveryOptionProvider);
  return CheckoutTotals(
    itemCount: cart.itemCount,
    subtotal: cart.subtotal,
    deliveryFee: option.fee,
  );
});