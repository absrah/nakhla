import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../model/cart_line.dart';
import '../view_model/cart_providers.dart';

/// One item whose price moved: what it was when we first noticed, and now.
class _Change {
  _Change(this.id, this.name, this.before, this.after);

  final String id;
  final String name;
  final double before;
  double after;

  String get text => '$name: ${formatSar(before)} → ${formatSar(after)}';
}

/// Watches the cart and tells the shopper when the price of an item in it
/// changes.
/// - [useDialog] false (placed once above the whole app): a snackbar.
/// - [useDialog] true (wraps the checkout and payment routes): a dialog that
///   must be answered, so the shopper cannot place the order unaware.
class PriceChangeListener extends ConsumerStatefulWidget {
  const PriceChangeListener({
    super.key,
    required this.child,
    this.useDialog = false,
  });

  final Widget child;
  final bool useDialog;

  @override
  ConsumerState<PriceChangeListener> createState() =>
      _PriceChangeListenerState();
}

class _PriceChangeListenerState extends ConsumerState<PriceChangeListener> {
  /// How many dialog watchers are on screen. While there is one, the
  /// app-wide snackbar stays quiet so the shopper is not told twice.
  static int _dialogWatchers = 0;

  /// The last price we saw for each product in the cart.
  Map<String, double> _seen = {};

  final Map<String, _Change> _pending = {};
  final ValueNotifier<List<String>> _lines = ValueNotifier(const []);
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    if (widget.useDialog) _dialogWatchers++;
    final lines = ref.read(cartLinesProvider).value;
    if (lines != null) {
      _seen = {for (final l in lines) l.product.id: l.product.price};
    }
  }

  @override
  void dispose() {
    if (widget.useDialog) _dialogWatchers--;
    super.dispose();
  }

  void _check(List<CartLine> lines) {
    final found = <_Change>[];
    final current = <String, double>{};

    for (final line in lines) {
      final id = line.product.id;
      final price = line.product.price;
      current[id] = price;

      final before = _seen[id];
      if (before != null && (before - price).abs() > 0.001) {
        found.add(_Change(id, line.product.name, before, price));
      }
    }
    _seen = current;

    if (found.isEmpty || !mounted) return;
    if (widget.useDialog) {
      _showDialog(found);
    } else if (_dialogWatchers == 0) {
      _showSnackBar(found);
    }
  }

  void _showSnackBar(List<_Change> found) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          persist: false,
          duration: const Duration(seconds: 8),
          content: Text(
            found.length == 1
                ? 'Price changed. ${found.first.text}'
                : 'Prices changed:\n${found.map((c) => c.text).join('\n')}',
          ),
        ),
      );
  }

  void _merge(List<_Change> found) {
    for (final change in found) {
      final existing = _pending[change.id];
      if (existing != null) {
        existing.after = change.after; // keep the first "before"
      } else {
        _pending[change.id] = change;
      }
    }
    _lines.value = [for (final c in _pending.values) c.text];
  }

  void _showDialog(List<_Change> found) {
    // A dialog is already open: just update what it lists.
    if (_dialogOpen) {
      _merge(found);
      return;
    }
    // Only the screen the shopper is looking at asks (checkout stays
    // mounted under payment).
    if (ModalRoute.of(context)?.isCurrent != true) return;

    _merge(found);
    _dialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Prices changed'),
          content: ValueListenableBuilder<List<String>>(
            valueListenable: _lines,
            builder: (context, items, child) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('The price of these items in your cart changed:'),
                const SizedBox(height: 12),
                for (final text in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      text,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                const SizedBox(height: 8),
                const Text('Do you still want to continue?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (mounted) context.go(AppRoutes.cart);
              },
              child: const Text('Back to cart'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    ).then((_) {
      _dialogOpen = false;
      _pending.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<CartLine>>>(cartLinesProvider, (previous, next) {
      final lines = next.value;
      if (lines != null) _check(lines);
    });
    return widget.child;
  }
}