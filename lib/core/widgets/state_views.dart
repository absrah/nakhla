import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../errors/app_exception.dart';
import '../theme/app_palette.dart';

/// Centered spinner while data loads.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Friendly error with an optional "Try again" button.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is AppException
        ? (error as AppException).message
        : 'Something went wrong. Please try again.';
    return _Message(
      icon: Icons.cloud_off_outlined,
      message: message,
      action: onRetry == null
          ? null
          : TextButton(onPressed: onRetry, child: const Text('Try again')),
    );
  }
}

/// Nothing to show (empty list, no results).
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _Message(icon: icon, message: message);
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40.w, color: p.muted),
            SizedBox(height: 12.w),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.muted, fontSize: 15.sp),
            ),
            if (action != null) ...[SizedBox(height: 8.w), action!],
          ],
        ),
      ),
    );
  }
}