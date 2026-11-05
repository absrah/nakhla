import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Back arrow for screens opened on top of the tabs. Normally it goes back.
/// When there is nothing to go back to (the page was opened directly, for
/// example after a reload), it goes to [fallback] instead.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.fallback});

  final String fallback;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(fallback);
        }
      },
    );
  }
}