import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../view_model/onboarding_view_model.dart';

class _Slide {
  const _Slide(this.title, this.body, this.labels);

  final String title;
  final String body;

  /// Tile labels: left tall, left short, right short, right tall.
  final List<String> labels;
}

const _slides = [
  _Slide(
    'Everything you need, in one place.',
    'Shop thousands of products across every category, '
        'with fast delivery to your door.',
    ['ELECTRONICS', 'BEAUTY', 'FASHION', 'HOME'],
  ),
  _Slide(
    'Fast delivery to your door.',
    'Order today and follow your package every step of the way.',
    ['PLACED', 'PACKED', 'SHIPPED', 'DELIVERED'],
  ),
  _Slide(
    'Save what you love.',
    'Build a wishlist, fill your cart and check out '
        'whenever you are ready.',
    ['WISHLIST', 'CART', 'ORDERS', 'ACCOUNT'],
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Remember that the intro was seen, then go to [route].
  Future<void> _finish(String route) async {
    await ref.read(onboardingSeenProvider.notifier).complete();
    if (!mounted) return;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            children: [
              Row(
                children: [
                  // Placeholder mark until the real logo file is added.
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: p.accent,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 18.w,
                      color: p.onAccent,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'nakhla',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: p.muted),
                    onPressed: () => _finish(AppRoutes.home),
                    child: const Text('Skip'),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < _slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: 6.w),
                      width: i == _page ? 24.w : 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: i == _page ? scheme.onSurface : p.border,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20.h),
              FilledButton(
                onPressed: () => _finish(AppRoutes.signUp),
                child: const Text('Sign up'),
              ),
              SizedBox(height: 12.h),
              OutlinedButton(
                onPressed: () => _finish(AppRoutes.login),
                child: const Text('Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final l = slide.labels;

    // Which tint each tile uses (the order used in the design).
    Color tint(int i) => p.tiles[i];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _CollageTile(label: l[0], color: tint(0), height: 220),
                    SizedBox(height: 12.h),
                    _CollageTile(label: l[1], color: tint(3), height: 108),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  children: [
                    _CollageTile(label: l[2], color: tint(2), height: 108),
                    SizedBox(height: 12.h),
                    _CollageTile(label: l[3], color: tint(1), height: 220),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 28.h),
          Text(
            slide.title,
            style: text.headlineMedium?.copyWith(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            slide.body,
            style: text.bodyLarge?.copyWith(color: p.muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _CollageTile extends StatelessWidget {
  const _CollageTile({
    required this.label,
    required this.color,
    required this.height,
  });

  final String label;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dot = height > 150 ? 64.0 : 52.0;

    return Container(
      height: height.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        children: [
          Center(
            // Stands in for a product photo.
            child: Container(
              width: dot.w,
              height: dot.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.6),
              ),
            ),
          ),
          Positioned(
            left: 14.w,
            bottom: 12.h,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w500,
                color: p.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}