/// A product, stored at products/{id}. Prices are in SAR.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.brand,
    required this.categoryId,
    required this.subcategoryId,
    required this.price,
    this.oldPrice,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    required this.description,
    required this.descriptionAr,
    required this.keywords,
  });

  final String id;
  final String name;
  final String nameAr;
  final String brand;
  final String categoryId;
  final String subcategoryId;
  final double price;
  final double? oldPrice; // the price before the discount, if any
  final double rating; // 0 to 5
  final int reviewCount;
  final int stock;
  final String description;
  final String descriptionAr;
  final List<String> keywords; // lowercase words, English and Arabic

  bool get inStock => stock > 0;

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  /// Whole-number percent off, for the sale tag (e.g. 26).
  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      nameAr: map['nameAr'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      subcategoryId: map['subcategoryId'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      oldPrice: (map['oldPrice'] as num?)?.toDouble(),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      description: map['description'] as String? ?? '',
      descriptionAr: map['descriptionAr'] as String? ?? '',
      keywords: List<String>.from(map['keywords'] as List<dynamic>? ?? const []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameAr': nameAr,
        'brand': brand,
        'categoryId': categoryId,
        'subcategoryId': subcategoryId,
        'price': price,
        'oldPrice': oldPrice,
        'rating': rating,
        'reviewCount': reviewCount,
        'stock': stock,
        'description': description,
        'descriptionAr': descriptionAr,
        'keywords': keywords,
      };
}