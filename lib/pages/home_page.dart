import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

const _categories = [
  'All',
  'Fruits & Vegetables',
  'Dairy & Eggs',
  'Beverages',
  'Snacks & Cereals',
];

class HomePage extends StatefulWidget {
  final UserModel? user;
  final Function(int)? onCartUpdated;
  const HomePage({super.key, this.user, this.onCartUpdated});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      List<ProductModel> products;
      if (_selectedCategory == 'All' && _searchQuery.isEmpty) {
        products = await SupabaseService.getProducts();
      } else if (_searchQuery.isNotEmpty) {
        products = await SupabaseService.searchProducts(_searchQuery);
      } else {
        products =
            await SupabaseService.getProductsByCategory(_selectedCategory);
      }
      setState(() { _products = products; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Failed to load products. Pull to refresh.'; _isLoading = false; });
    }
  }

  void _onSearch(String value) {
    setState(() => _searchQuery = value);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_searchQuery == value) _loadProducts();
    });
  }

  void _addToCart(ProductModel product) async {
    if (widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to add items to cart')));
      return;
    }
    try {
      await SupabaseService.addToCart(
          userId: widget.user!.id, productId: product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${product.name} added to cart!'),
          backgroundColor: const Color(0xFF1B4D1E),
          duration: const Duration(seconds: 1),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FreshMart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF1B4D1E),
        onRefresh: _loadProducts,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _loadProducts();
                        })
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    selectedColor: const Color(0xFF1B4D1E),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.grey[700],
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                      _loadProducts();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ]),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1B4D1E)));
    }
    if (_error != null) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadProducts, child: const Text('Retry')),
        ],
      ));
    }
    if (_products.isEmpty) {
      return const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('No products found', style: TextStyle(color: Colors.grey)),
        ],
      ));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _products.length,
      itemBuilder: (context, i) =>
          _ProductCard(product: _products[i], onAddToCart: _addToCart),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final Function(ProductModel) onAddToCart;
  const _ProductCard({required this.product, required this.onAddToCart});
  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 100, width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFF0F7F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          child: Center(
            child: Text(widget.product.emoji,
                style: const TextStyle(fontSize: 48))),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.product.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(widget.product.category,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(
                child: Text(widget.product.formattedPrice,
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.bold, color: Color(0xFF1B4D1E))),
              ),
              GestureDetector(
                onTap: _adding ? null : () async {
                  setState(() => _adding = true);
                  widget.onAddToCart(widget.product);
                  await Future.delayed(const Duration(milliseconds: 600));
                  if (mounted) setState(() => _adding = false);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: _adding
                        ? const Color(0xFF1B4D1E)
                        : const Color(0xFFD4E8D5),
                    borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    _adding ? Icons.check : Icons.add,
                    size: 18,
                    color: _adding ? Colors.white : const Color(0xFF1B4D1E)),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
