/// A "shop by type" entry inside a category (Phones, Laptops, ...).
class Subcategory {
  const Subcategory(this.id, this.name, this.nameAr);

  final String id;
  final String name;
  final String nameAr;

  factory Subcategory.fromMap(Map<String, dynamic> map) {
    return Subcategory(
      map['id'] as String? ?? '',
      map['name'] as String? ?? '',
      map['nameAr'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'nameAr': nameAr};
}

/// A top-level category, stored at categories/{id}.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.order,
    required this.subcategories,
  });

  final String id;
  final String name;
  final String nameAr;
  final int order; // position in the list, lowest first
  final List<Subcategory> subcategories;

  factory Category.fromMap(String id, Map<String, dynamic> map) {
    final subs = (map['subcategories'] as List<dynamic>? ?? const [])
        .map((e) => Subcategory.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Category(
      id: id,
      name: map['name'] as String? ?? '',
      nameAr: map['nameAr'] as String? ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
      subcategories: subs,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameAr': nameAr,
        'order': order,
        'subcategories': subcategories.map((s) => s.toMap()).toList(),
      };
}