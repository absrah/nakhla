/// How fast the order arrives, and what it costs.
enum DeliveryOption {
  standard('Standard', '2–4 business days', 0),
  express('Express', 'Next business day', 25);

  const DeliveryOption(this.title, this.eta, this.fee);

  final String title;
  final String eta;
  final double fee; // SAR, 0 means free
}