import '../../catalog/model/product.dart';

/// A cart item joined with its product: what the cart screen shows.
class CartLine {
  const CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get total => product.price * quantity;

  /// False when the product ran out, or fewer pieces are left than in the cart.
  bool get available => product.inStock && quantity <= product.stock;

  /// How much cheaper this line is than the old prices.
  double get savings =>
      product.hasDiscount ? (product.oldPrice! - product.price) * quantity : 0;
}

/// The totals under the cart list.
class CartSummary {
  const CartSummary(this.lines);

  final List<CartLine> lines;

  bool get isEmpty => lines.isEmpty;

  /// All pieces (the number on the Cart tab and in the cart title).
  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  double get subtotal => lines.fold(0.0, (sum, line) => sum + line.total);

  double get savings => lines.fold(0.0, (sum, line) => sum + line.savings);

  /// True when at least one line cannot be bought as it is (stock changed).
  bool get hasUnavailable => lines.any((line) => !line.available);

  /// Free for now; delivery fees can be added here later.
  double get delivery => 0;

  double get total => subtotal + delivery;
}
