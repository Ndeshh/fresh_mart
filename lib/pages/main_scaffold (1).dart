import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'home_page.dart';
import 'cart_page.dart';
import 'orders_page.dart';
import 'profile_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  UserModel? _user;
  int _cartCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is UserModel) {
      setState(() => _user = args);
    }
  }

  void _updateCartCount(int count) {
    setState(() => _cartCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(user: _user, onCartUpdated: _updateCartCount),
      CartPage(user: _user, onCartUpdated: _updateCartCount),
      OrdersPage(user: _user),
      ProfilePage(user: _user),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD4E8D5),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF1B4D1E)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$_cartCount'),
              isLabelVisible: _cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              label: Text('$_cartCount'),
              isLabelVisible: _cartCount > 0,
              child: const Icon(Icons.shopping_cart_rounded,
                  color: Color(0xFF1B4D1E)),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded,
                color: Color(0xFF1B4D1E)),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF1B4D1E)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
