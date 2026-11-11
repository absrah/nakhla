import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/view_model/session_provider.dart';
import '../model/order.dart';
import '../model/order_repository.dart';

/// The logged-in user's orders, newest first (empty for a guest).
final ordersProvider = StreamProvider<List<Order>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <Order>[]);
  return ref.watch(orderRepositoryProvider).watchOrders(user.uid);
});

/// One order by id, or null if it does not exist.
final orderByIdProvider = Provider.family<AsyncValue<Order?>, String>((
  ref,
  id,
) {
  return ref.watch(ordersProvider).whenData((all) {
    for (final order in all) {
      if (order.id == id) return order;
    }
    return null;
  });
});
