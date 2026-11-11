/// Where an order is on its way. Stored as the [value] text in Firestore.
/// The shop owner changes it in the Firebase console.
enum OrderStatus {
  placed('placed', 'Order placed'),
  packed('packed', 'Packed'),
  shipped('shipped', 'Shipped'),
  outForDelivery('outForDelivery', 'Out for delivery'),
  delivered('delivered', 'Delivered'),
  cancelled('cancelled', 'Cancelled');

  const OrderStatus(this.value, this.label);

  final String value; // what is stored in Firestore
  final String label; // what the shopper reads

  /// Unknown or missing text counts as "placed".
  static OrderStatus fromValue(String? value) {
    return values.firstWhere(
      (status) => status.value == value,
      orElse: () => placed,
    );
  }

  /// Still on its way (the "Active" tab).
  bool get isActive => this != delivered && this != cancelled;

  /// The steps of a normal delivery in order (cancelled is not one of them).
  static const List<OrderStatus> timeline = [
    placed,
    packed,
    shipped,
    outForDelivery,
    delivered,
  ];
}
