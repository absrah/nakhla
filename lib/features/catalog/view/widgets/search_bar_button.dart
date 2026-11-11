import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';

/// Looks like a search field but is a button: tapping it opens the Search
/// screen, where the real text field lives.
class SearchBarButton extends StatelessWidget {
  const SearchBarButton({super.key, this.hint = 'Search products, brands…'});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: p.border),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        onTap: () => context.push(AppRoutes.search),
        child: SizedBox(
          height: 52.w,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(Icons.search, size: 22.w, color: p.muted),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15.sp, color: p.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
