class ProductModel {
  final String id;
  final String name;
  final String category;
  final double priceKsh;
  final int stockQuantity;
  final String? imageUrl;
  final String? description;
  final bool isAvailable;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.priceKsh,
    required this.stockQuantity,
    this.imageUrl,
    this.description,
    required this.isAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      priceKsh: double.tryParse(json['price_ksh']?.toString() ?? '0') ?? 0,
      stockQuantity: int.tryParse(json['stock_quantity']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url']?.toString(),
      description: json['description']?.toString(),
      isAvailable: json['is_available'] == true,
    );
  }

  String get emoji {
    switch (category) {
      case 'Fruits & Vegetables':
        return '🥦';
      case 'Dairy & Eggs':
        return '🥛';
      case 'Beverages':
        return '🧃';
      case 'Snacks & Cereals':
        return '🌽';
      default:
        return '🛒';
    }
  }

  String get formattedPrice => 'KSh ${priceKsh.toStringAsFixed(2)}';
}
