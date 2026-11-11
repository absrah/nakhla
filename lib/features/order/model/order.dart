import 'package:cloud_firestore/cloud_firestore.dart';

import '../../address/model/address.dart';
import '../../checkout/model/delivery_option.dart';
import 'order_status.dart';

/// One product line of an order. It is a snapshot: the name and price are
/// copied at the moment of ordering, so later price changes never alter an
/// old order.
class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String productId;
  final String name;
  final double price; // SAR, VAT included
  final int quantity;

  double get lineTotal => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'name': name,
    'price': price,
    'quantity': quantity,
  };
}

/// An order, stored at orders/{orderId}.
class Order {
  const Order({
    required this.id,
    required this.status,
    required this.items,
    required this.address,
    required this.deliveryOption,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.itemCount,
    this.createdAt,
  });

  final String id;
  final OrderStatus status;
  final List<OrderItem> items;
  final Address address; // a copy of the address used (id is empty)
  final DeliveryOption deliveryOption;
  final String paymentMethod; // 'cod' (cash on delivery)
  final double subtotal; // items, VAT included
  final double deliveryFee; // VAT included
  final double total; // subtotal + deliveryFee
  final int itemCount; // pieces, not lines
  final DateTime? createdAt; // null for a moment right after ordering

  /// Short number the shopper sees: the first 8 characters of the id.
  String get number => (id.length <= 8 ? id : id.substring(0, 8)).toUpperCase();

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? const [];
    final created = map['createdAt'];
    return Order(
      id: id,
      status: OrderStatus.fromValue(map['status'] as String?),
      items: [
        for (final raw in rawItems)
          OrderItem.fromMap(Map<String, dynamic>.from(raw as Map)),
      ],
      address: Address.fromMap(
        '',
        Map<String, dynamic>.from(map['address'] as Map? ?? const {}),
      ),
      deliveryOption: DeliveryOption.values.firstWhere(
        (option) => option.name == map['deliveryOption'],
        orElse: () => DeliveryOption.standard,
      ),
      paymentMethod: map['paymentMethod'] as String? ?? 'cod',
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      itemCount: (map['itemCount'] as num?)?.toInt() ?? 0,
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }
}
