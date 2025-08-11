class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json['id'], name: json['name']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class Item {
  final int id;
  final String name;
  final String brand;
  final String origin;
  final bool reusable;
  final int categoryId;
  final Category? category;
  final String? image;

  Item({
    required this.id,
    required this.name,
    required this.brand,
    required this.origin,
    required this.reusable,
    required this.categoryId,
    this.category,
    this.image,
  });

  String get reusableText {
    switch (reusable) {
      case false:
        return 'Bisa Digunakan Kembali';
      case true:
        return 'Sekali Pakai';
    }
  }

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'],
        name: json['name'],
        brand: json['brand'],
        origin: json['origin'],
        reusable: json['reusable'],
        categoryId: json['category_id'],
        category: json['category'] != null 
          ? Category.fromJson(json['category']) 
          : null,
        image: json['image'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'origin': origin,
        'reusable': reusable,
        'category_id': categoryId,
        if (category != null) 'category': category!.toJson(),
        'image': image,
      };
}
