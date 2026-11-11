import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/state_views.dart';
import '../model/order.dart';
import '../model/order_status.dart';
import '../view_model/order_providers.dart';
import 'widgets/order_card.dart';

/// "My orders": three tabs, newest first inside each.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(fallback: AppRoutes.account),
          title: const Text('My orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Delivered'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: orders.when(
          loading: () => const LoadingView(),
          error: (error, _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(ordersProvider),
          ),
          data: (all) => TabBarView(
            children: [
              _OrderList(
                orders: [
                  for (final o in all)
                    if (o.status.isActive) o,
                ],
                empty: 'You have no active orders.',
              ),
              _OrderList(
                orders: [
                  for (final o in all)
                    if (o.status == OrderStatus.delivered) o,
                ],
                empty: 'No delivered orders yet.',
              ),
              _OrderList(
                orders: [
                  for (final o in all)
                    if (o.status == OrderStatus.cancelled) o,
                ],
                empty: 'No cancelled orders.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders, required this.empty});

  final List<Order> orders;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return EmptyView(icon: Icons.receipt_long_outlined, message: empty);
    }
    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: orders.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.w),
      itemBuilder: (context, index) => OrderCard(order: orders[index]),
    );
  }
}
