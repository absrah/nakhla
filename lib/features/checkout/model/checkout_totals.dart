/// The money side of the checkout: what the shopper will pay.
/// Shelf prices and the delivery fee already include VAT, so the total is
/// just subtotal + delivery. The getters below split it into "before VAT"
/// lines and the VAT, for display. They always add up to the total.
class CheckoutTotals {
  const CheckoutTotals({
    required this.itemCount,
    required this.subtotal,
    required this.deliveryFee,
  });

  /// Saudi VAT.
  static const vatRate = 0.15;

  final int itemCount;
  final double subtotal; // items, VAT included
  final double deliveryFee; // VAT included

  /// What the shopper pays.
  double get total => subtotal + deliveryFee;

  /// Items before VAT.
  double get subtotalExVat => _round2(subtotal / (1 + vatRate));

  /// Delivery before VAT.
  double get deliveryExVat => _round2(deliveryFee / (1 + vatRate));

  /// The VAT inside the total. Computed as the remainder so that
  /// subtotalExVat + deliveryExVat + vat is always exactly the total.
  double get vat => _round2(total - subtotalExVat - deliveryExVat);

  static double _round2(double value) => (value * 100).round() / 100;
}