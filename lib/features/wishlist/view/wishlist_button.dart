import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../auth/view_model/session_provider.dart';
import '../../catalog/model/product.dart';
import '../view_model/wishlist_providers.dart';
import '../view_model/wishlist_view_model.dart';

/// The round heart on a product: tap to save it, tap again to remove it.
/// A guest is sent to log in first and comes back to the same screen.
class WishlistButton extends ConsumerWidget {
  const WishlistButton({super.key, required this.product, this.size = 36});

  final Product product;
  final double size;

  Future<void> _tap(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      final here = GoRouterState.of(context).uri.toString();
      // go, not push: the router must see the log in screen.
      context.go('${AppRoutes.login}?from=${Uri.encodeComponent(here)}');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(wishlistViewModelProvider).toggle(product);
    } on AppException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(isWishlistedProvider(product.id));
    final scheme = Theme.of(context).colorScheme;
    final p = context.palette;

    return Tooltip(
      message: saved ? 'Remove from wishlist' : 'Save to wishlist',
      child: Material(
        color: scheme.surface.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _tap(context, ref),
          child: SizedBox(
            width: size.w,
            height: size.w,
            child: Icon(
              saved ? Icons.favorite : Icons.favorite_border,
              size: (size * 0.55).w,
              color: saved ? p.link : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
