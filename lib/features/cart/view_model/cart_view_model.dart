import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/view_model/session_provider.dart';
import '../../catalog/model/product.dart';
import '../model/cart_repository.dart';

/// The cart commands the screens can call. The cart itself (the data) comes
/// from the providers in cart_providers.dart; Firestore sends changes back
/// through them, so nothing needs to be refreshed by hand.
class CartViewModel {
  CartViewModel(this._ref);

  final Ref _ref;

  String _uid() {
    final user = _ref.read(authStateProvider).value;
    if (user == null) throw const AppException('Log in to use your cart.');
    return user.uid;
  }

  /// Returns false when the cart already held the maximum quantity.
  Future<bool> add(Product product, {int quantity = 1}) async {
    if (!product.inStock) {
      throw const AppException('This product is out of stock.');
    }
    return _ref.read(cartRepositoryProvider).addItem(
          _uid(),
          product.id,
          quantity: quantity,
          maxQuantity: product.maxOrderQuantity,
        );
  }

  Future<void> setQuantity(Product product, int quantity) async {
    final safe = quantity < 1
        ? 1
        : (quantity > product.maxOrderQuantity
            ? product.maxOrderQuantity
            : quantity);
    await _ref.read(cartRepositoryProvider).setQuantity(_uid(), product.id, safe);
  }

  Future<void> remove(String productId) async {
    await _ref.read(cartRepositoryProvider).remove(_uid(), productId);
  }
}

final cartViewModelProvider =
    Provider<CartViewModel>((ref) => CartViewModel(ref));