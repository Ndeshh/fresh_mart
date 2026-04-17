import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/cart_item_model.dart';
import '../services/supabase_service.dart';

class CartPage extends StatefulWidget {
  final UserModel? user;
  final Function(int)? onCartUpdated;
  const CartPage({super.key, this.user, this.onCartUpdated});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItemModel> _items = [];
  bool _isLoading = true;
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    if (widget.user == null) { setState(() => _isLoading = false); return; }
    setState(() => _isLoading = true);
    try {
      final items = await SupabaseService.getCart(widget.user!.id);
      setState(() { _items = items; _isLoading = false; });
      widget.onCartUpdated?.call(items.length);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get _delivery => _subtotal > 0 ? 150.0 : 0.0;
  double get _total => _subtotal + _delivery;

  Future<void> _updateQty(CartItemModel item, int newQty) async {
    try {
      await SupabaseService.updateCartQuantity(
          userId: widget.user!.id,
          productId: item.productId,
          quantity: newQty);
      _loadCart();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _checkout() async {
    if (widget.user == null || _items.isEmpty) return;
    setState(() => _isCheckingOut = true);
    try {
      await SupabaseService.createOrder(
        userId: widget.user!.id,
        cartItems: _items,
        totalAmount: _total,
        deliveryAddress: widget.user!.address ?? 'Not specified',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully! 🎉'),
            backgroundColor: Color(0xFF1B4D1E)));
        setState(() => _items = []);
        widget.onCartUpdated?.call(0);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e'),
              backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4D1E)))
          : widget.user == null
              ? _buildSignInPrompt()
              : _items.isEmpty
                  ? _buildEmptyCart()
                  : Column(children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadCart,
                          color: const Color(0xFF1B4D1E),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) => _CartTile(
                              item: _items[i],
                              onIncrement: () => _updateQty(_items[i], _items[i].quantity + 1),
                              onDecrement: () => _updateQty(_items[i], _items[i].quantity - 1),
                            ),
                          ),
                        ),
                      ),
                      _buildSummary(),
                    ]),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,-2))],
      ),
      child: Column(children: [
        _SummaryRow('Subtotal', 'KSh ${_subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        _SummaryRow('Delivery', 'KSh ${_delivery.toStringAsFixed(2)}'),
        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
        _SummaryRow('Total', 'KSh ${_total.toStringAsFixed(2)}', bold: true),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isCheckingOut ? null : _checkout,
          child: _isCheckingOut
              ? const SizedBox(height: 22, width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Text('Checkout & Place Order'),
        ),
      ]),
    );
  }

  Widget _buildEmptyCart() => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey),
      SizedBox(height: 16),
      Text('Your cart is empty',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
      SizedBox(height: 8),
      Text('Add some products to get started',
          style: TextStyle(color: Colors.grey)),
    ]),
  );

  Widget _buildSignInPrompt() => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.lock_outline, size: 60, color: Colors.grey),
      SizedBox(height: 16),
      Text('Please sign in to view your cart',
          style: TextStyle(color: Colors.grey, fontSize: 16)),
    ]),
  );
}

class _CartTile extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  const _CartTile({required this.item, required this.onIncrement, required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 6, offset: const Offset(0,2))]),
      child: Row(children: [
        Container(width: 60, height: 60,
          decoration: BoxDecoration(color: const Color(0xFFF0F7F0),
              borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(item.product?.emoji ?? '🛒',
              style: const TextStyle(fontSize: 28)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.product?.name ?? '', style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text('KSh ${(item.product?.priceKsh ?? 0).toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFF1B4D1E),
                  fontWeight: FontWeight.w600)),
        ])),
        Row(children: [
          _QBtn(icon: Icons.remove, onTap: onDecrement),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
          _QBtn(icon: Icons.add, onTap: onIncrement),
        ]),
      ]),
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _QBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 28, height: 28,
      decoration: BoxDecoration(color: const Color(0xFFD4E8D5),
          borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 16, color: const Color(0xFF1B4D1E))),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label; final String value; final bool bold;
  const _SummaryRow(this.label, this.value, {this.bold = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: bold ? 16 : 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: bold ? Colors.black87 : Colors.grey[600])),
      Text(value, style: TextStyle(fontSize: bold ? 16 : 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: bold ? const Color(0xFF1B4D1E) : Colors.black87)),
    ],
  );
}
