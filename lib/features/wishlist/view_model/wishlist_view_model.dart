import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/view_model/session_provider.dart';
import '../../catalog/model/product.dart';
import '../model/wishlist_repository.dart';
import 'wishlist_providers.dart';

/// The wishlist commands the screens can call. The data itself comes from
/// wishlist_providers.dart and updates by itself when Firestore changes.
class WishlistViewModel {
  WishlistViewModel(this._ref);

  final Ref _ref;

  /// Saves the product, or removes it if it is already saved.
  Future<void> toggle(Product product) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) throw const AppException('Log in to use your wishlist.');

    final repository = _ref.read(wishlistRepositoryProvider);
    final saved = _ref.read(isWishlistedProvider(product.id));
    if (saved) {
      await repository.remove(user.uid, product.id);
    } else {
      await repository.add(user.uid, product.id);
    }
  }
}

final wishlistViewModelProvider = Provider<WishlistViewModel>(
  (ref) => WishlistViewModel(ref),
);
