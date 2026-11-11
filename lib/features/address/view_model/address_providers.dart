import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/view_model/session_provider.dart';
import '../model/address.dart';
import '../model/address_repository.dart';

/// The logged-in user's saved addresses (empty for a guest).
final addressesProvider = StreamProvider<List<Address>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <Address>[]);
  return ref.watch(addressRepositoryProvider).watchAddresses(user.uid);
});

/// The id of the address the shopper picked for this order, or null.
class SelectedAddressViewModel extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) => state = id;
}

final selectedAddressIdProvider =
    NotifierProvider<SelectedAddressViewModel, String?>(
      SelectedAddressViewModel.new,
    );

/// The address that will be used: the picked one, otherwise the oldest one.
/// Null when the shopper has no address yet.
final selectedAddressProvider = Provider<Address?>((ref) {
  final list = ref.watch(addressesProvider).value ?? const <Address>[];
  if (list.isEmpty) return null;
  final id = ref.watch(selectedAddressIdProvider);
  for (final address in list) {
    if (address.id == id) return address;
  }
  return list.first;
});
