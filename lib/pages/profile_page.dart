import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ProfilePage extends StatelessWidget {
  final UserModel? user;
  const ProfilePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: const Color(0xFF1B4D1E),
            child: Text(user?.initials ?? 'U',
                style: const TextStyle(fontSize: 28, color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(user?.fullName ?? 'Guest',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(user?.email ?? '',
              style: const TextStyle(color: Colors.grey)),
          if (user?.phone != null && user!.phone!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(user!.phone!,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
          const SizedBox(height: 28),

          // Info cards
          _InfoCard(items: [
            _InfoRow(Icons.person_outline, 'Full Name', user?.fullName ?? '-'),
            _InfoRow(Icons.email_outlined, 'Email', user?.email ?? '-'),
            _InfoRow(Icons.phone_outlined, 'Phone',
                user?.phone?.isNotEmpty == true ? user!.phone! : 'Not set'),
            _InfoRow(Icons.location_on_outlined, 'Address',
                user?.address?.isNotEmpty == true ? user!.address! : 'Not set'),
          ]),
          const SizedBox(height: 16),

          _MenuSection(title: 'Settings', items: [
            _MenuItem(Icons.notifications_outlined, 'Notifications'),
            _MenuItem(Icons.help_outline_rounded, 'Help Centre'),
            _MenuItem(Icons.privacy_tip_outlined, 'Privacy Policy'),
          ]),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                  blurRadius: 6, offset: const Offset(0,2))]),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Log out',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 6, offset: const Offset(0,2))]),
    child: Column(children: items.map((item) => ListTile(
      leading: Icon(item.icon, color: const Color(0xFF1B4D1E), size: 20),
      title: Text(item.label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(item.value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
    )).toList()),
  );
}

class _InfoRow {
  final IconData icon; final String label; final String value;
  const _InfoRow(this.icon, this.label, this.value);
}

class _MenuSection extends StatelessWidget {
  final String title; final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title, style: TextStyle(color: Colors.grey[600],
            fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.4))),
      Container(
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 6, offset: const Offset(0,2))]),
        child: Column(children: items.map((item) => ListTile(
          leading: Icon(item.icon, color: const Color(0xFF1B4D1E)),
          title: Text(item.label, style: const TextStyle(fontSize: 14)),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: Colors.grey, size: 20),
          onTap: () {},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        )).toList()),
      ),
    ],
  );
}

class _MenuItem {
  final IconData icon; final String label;
  const _MenuItem(this.icon, this.label);
}
