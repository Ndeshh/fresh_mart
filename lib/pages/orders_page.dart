import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../services/supabase_service.dart';

class OrdersPage extends StatefulWidget {
  final UserModel? user;
  const OrdersPage({super.key, this.user});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (widget.user == null) { setState(() => _isLoading = false); return; }
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final orders = await SupabaseService.getOrders(widget.user!.id);
      setState(() { _orders = orders; _isLoading = false; });
    } catch (e) {
      debugPrint('Error loading orders: $e');
      setState(() { _errorMessage = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4D1E)))
          : _errorMessage != null
              ? Center(child: Text('Failed to load orders: $_errorMessage', style: const TextStyle(color: Colors.red)))
              : widget.user == null
                  ? const Center(child: Text('Please sign in to view orders',
                      style: TextStyle(color: Colors.grey)))
                  : _orders.isEmpty
                  ? const Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No orders yet',
                            style: TextStyle(fontSize: 18,
                                fontWeight: FontWeight.w600, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Your completed orders will appear here',
                            style: TextStyle(color: Colors.grey)),
                      ]))
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      color: const Color(0xFF1B4D1E),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _OrderCard(order: _orders[i]),
                      ),
                    ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 6, offset: const Offset(0,2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('#${order.id.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: order.statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20)),
            child: Text(order.status.toUpperCase(),
                style: TextStyle(color: order.statusColor,
                    fontWeight: FontWeight.w600, fontSize: 11)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(order.formattedDate,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        if (order.deliveryAddress != null &&
            order.deliveryAddress!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(child: Text(order.deliveryAddress!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ],
        const Divider(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 13)),
          Text(order.formattedTotal,
              style: const TextStyle(fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4D1E), fontSize: 15)),
        ]),
      ]),
    );
  }
}
