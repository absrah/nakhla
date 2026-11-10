import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../address/view_model/address_providers.dart';
import '../../auth/view_model/session_provider.dart';
import '../../cart/model/cart_line.dart';
import '../../cart/view_model/cart_providers.dart';
import '../../checkout/model/delivery_option.dart';
import '../model/order_repository.dart';

/// The order commands the screens can call.
class OrderViewModel {
  OrderViewModel(this._ref);

  final Ref _ref;

  /// The security rules accept at most this many different products.
  static const maxLines = 20;

  /// Checks everything the shopper can still fix, then places the order from
  /// the current cart and the picked address. Returns the new order id.
  Future<String> placeOrder({required DeliveryOption option}) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) throw const AppException('Log in to place an order.');

    final lines = _ref.read(cartLinesProvider).value ?? const <CartLine>[];
    final address = _ref.read(selectedAddressProvider);

    if (lines.isEmpty) throw const AppException('Your cart is empty.');
    if (lines.length > maxLines) {
      throw AppException('You can order up to $maxLines different products at once.');
    }
    if (lines.any((line) => !line.available)) {
      throw const AppException('Some items are no longer available. Fix your cart first.');
    }
    if (address == null) {
      throw const AppException('Choose a delivery address first.');
    }

    return _ref.read(orderRepositoryProvider).placeOrder(
          uid: user.uid,
          lines: lines,
          address: address,
          option: option,
          expectedSubtotal: CartSummary(lines).subtotal,
        );
  }

        Future<void> cancelOrder(String orderId) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) throw const AppException('Log in to manage your orders.');
    await _ref.read(orderRepositoryProvider).cancelOrder(orderId);
  }
}

final orderViewModelProvider =
    Provider<OrderViewModel>((ref) => OrderViewModel(ref));
