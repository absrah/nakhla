import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/view_model/session_provider.dart';
import '../model/address.dart';
import '../model/address_repository.dart';

/// The address commands the screens can call. The list itself comes from
/// addressesProvider; Firestore sends changes back through it.
class AddressViewModel {
  AddressViewModel(this._ref);

  final Ref _ref;

  String _uid() {
    final user = _ref.read(authStateProvider).value;
    if (user == null) throw const AppException('Log in to manage your addresses.');
    return user.uid;
  }

  /// Returns the id of the new address.
  Future<String> add(Address address) =>
      _ref.read(addressRepositoryProvider).add(_uid(), address);

  Future<void> update(Address address) =>
      _ref.read(addressRepositoryProvider).update(_uid(), address);

  Future<void> delete(String addressId) =>
      _ref.read(addressRepositoryProvider).delete(_uid(), addressId);
}

final addressViewModelProvider =
    Provider<AddressViewModel>((ref) => AddressViewModel(ref));