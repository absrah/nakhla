import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// The main lime button. While [isLoading] it shows a spinner and
/// ignores taps, but keeps its lime color (a greyed button looks broken).
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? () {} : onPressed,
      child: isLoading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: context.palette.onAccent,
              ),
            )
          : Text(label),
    );
  }
}