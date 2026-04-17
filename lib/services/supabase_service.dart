import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ── AUTH ──────────────────────────────────────────────────────────────────
  static Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      // Check if user already exists
      final existing = await _client
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existing != null) {
        // User already exists — return their profile so they can proceed
        return UserModel.fromJson(existing);
      }

      // Insert new user into users table
      final response = await _client
          .from('users')
          .insert({
            'full_name': fullName,
            'email': email,
            'phone': phone ?? '',
          })
          .select()
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  static Future<UserModel?> signIn({
    required String email,
  }) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();
      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // ── PRODUCTS ─────────────────────────────────────────────────────────────
  static Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('is_available', true)
          .order('name');
      return (response as List)
          .map((p) => ProductModel.fromJson(p))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  static Future<List<ProductModel>> getProductsByCategory(
      String category) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('category', category)
          .eq('is_available', true)
          .order('name');
      return (response as List)
          .map((p) => ProductModel.fromJson(p))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  static Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('is_available', true)
          .ilike('name', '%$query%')
          .order('name');
      return (response as List)
          .map((p) => ProductModel.fromJson(p))
          .toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  // ── CART ─────────────────────────────────────────────────────────────────
  static Future<List<CartItemModel>> getCart(String userId) async {
    try {
      final response = await _client
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', userId)
          .order('added_at');
      return (response as List)
          .map((c) => CartItemModel.fromJson(c))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  static Future<void> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    try {
      // Check if already in cart — if so, increment quantity
      final existing = await _client
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        await _client
            .from('cart_items')
            .update({'quantity': existing['quantity'] + quantity})
            .eq('user_id', userId)
            .eq('product_id', productId);
      } else {
        await _client.from('cart_items').insert({
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity,
        });
      }
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  static Future<void> updateCartQuantity({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(userId: userId, productId: productId);
      } else {
        await _client
            .from('cart_items')
            .update({'quantity': quantity})
            .eq('user_id', userId)
            .eq('product_id', productId);
      }
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  static Future<void> removeFromCart({
    required String userId,
    required String productId,
  }) async {
    try {
      await _client
          .from('cart_items')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  static Future<void> clearCart(String userId) async {
    try {
      await _client.from('cart_items').delete().eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // ── ORDERS ───────────────────────────────────────────────────────────────
  static Future<OrderModel> createOrder({
    required String userId,
    required List<CartItemModel> cartItems,
    required double totalAmount,
    required String deliveryAddress,
  }) async {
    try {
      // Create order
      final orderResponse = await _client
          .from('orders')
          .insert({
            'user_id': userId,
            'total_amount_ksh': totalAmount,
            'status': 'pending',
            'delivery_address': deliveryAddress,
          })
          .select()
          .single();

      final orderId = orderResponse['id'];

      // Create order items
      final orderItems = cartItems
          .map((item) => <String, dynamic>{
                'order_id': orderId,
                'product_id': item.productId,
                'quantity': item.quantity,
                'unit_price_ksh': item.product?.priceKsh ?? 0,
              })
          .toList();

      await _client.from('order_items').insert(orderItems);

      // Clear the cart
      await clearCart(userId);

      return OrderModel.fromJson(orderResponse);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  static Future<List<OrderModel>> getOrders(String userId) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((o) => OrderModel.fromJson(o))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // ── USER ─────────────────────────────────────────────────────────────────
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateUser({
    required String userId,
    String? fullName,
    String? phone,
    String? address,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;

      await _client.from('users').update(updates).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
}
