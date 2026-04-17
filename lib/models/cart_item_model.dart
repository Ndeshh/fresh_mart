import 'product_model.dart';

class CartItemModel {
  final String id;
  final String userId;
  final String productId;
  int quantity;
  final ProductModel? product;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      product: json['products'] != null
          ? ProductModel.fromJson(json['products'])
          : null,
    );
  }

  double get totalPrice => (product?.priceKsh ?? 0) * quantity;

  String get formattedTotal => 'KSh ${totalPrice.toStringAsFixed(2)}';
}
