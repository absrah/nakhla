import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_palette.dart';

/// [-] 2 [+] control, used on the product page and in the cart.
/// With [decreaseIsDelete] the minus button becomes a trash can
/// (used when the quantity is 1 and minus would remove the item).
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    this.canIncrease = true,
    this.canDecrease = true,
    this.decreaseIsDelete = false,
    this.buttonSize = 40,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final bool canIncrease;
  final bool canDecrease;
  final bool decreaseIsDelete;
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundButton(
          icon: decreaseIsDelete ? Icons.delete_outline : Icons.remove,
          tooltip: decreaseIsDelete ? 'Remove' : 'Decrease quantity',
          size: buttonSize,
          filled: false,
          onPressed: canDecrease ? onDecrease : null,
        ),
        SizedBox(
          width: 32.w,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
        ),
        _RoundButton(
          icon: Icons.add,
          tooltip: 'Increase quantity',
          size: buttonSize,
          filled: true,
          onPressed: canIncrease ? onIncrease : null,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.size,
    required this.filled,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final double size;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = context.palette;

    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onPressed == null ? 0.4 : 1,
        child: Material(
          color: filled ? scheme.primary : scheme.surface,
          shape: CircleBorder(
            side: filled ? BorderSide.none : BorderSide(color: p.border),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: size.w,
              height: size.w,
              child: Icon(
                icon,
                size: 20.w,
                color: filled ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}