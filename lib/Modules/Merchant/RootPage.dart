// lib/Modules/Merchant/MerchantRootPage.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Services/AuthServices.dart';
import '../Common/Login_Page.dart';

class MerchantRootPage extends StatefulWidget {
  const MerchantRootPage({super.key});

  @override
  State<MerchantRootPage> createState() => _MerchantRootPageState();
}

class _MerchantRootPageState extends State<MerchantRootPage> {
  int _selectedIndex = 0;

  // Replace these placeholders with real screens as you implement them.
  final List<Widget> _pages = const [
    MerchantOverviewPage(),
    MerchantOrdersPage(),
    MerchantInventoryPage(),
    MerchantProfilePage(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Overview'),
    BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
    BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
    BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFFEF4444),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12),
            items: _navItems,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Placeholder pages — replace with real implementations
/// ---------------------------------------------------------------------------
class MerchantOverviewPage extends StatelessWidget {
  const MerchantOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PageTemplate(title: "Merchant Overview", icon: Icons.home_outlined);
  }
}

class MerchantOrdersPage extends StatelessWidget {
  const MerchantOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PageTemplate(title: "Orders", icon: Icons.receipt_long_outlined);
  }
}

class MerchantInventoryPage extends StatelessWidget {
  const MerchantInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PageTemplate(title: "Inventory", icon: Icons.inventory_2_outlined);
  }
}

/// ---------------------------------------------------------------------------
/// Profile page with functional logout
/// ---------------------------------------------------------------------------
class MerchantProfilePage extends StatelessWidget {
  const MerchantProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Log out')),
        ],
      ),
    );
    if (yes == true) {
      await _doLogout(context);
    }
  }

  Future<void> _doLogout(BuildContext context) async {
    final auth = AuthService.instance;
    try {
      await auth.signOut();
    } catch (_) {
      // ignore errors on sign out — still navigate to login
    }
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront_rounded, size: 100, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              Text(
                "Merchant Profile",
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                "Manage your store, orders and settings.",
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout_rounded),
                label: Text("Log Out", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Common template used by placeholders
/// ---------------------------------------------------------------------------
class _PageTemplate extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PageTemplate({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: const Color(0xFFEF4444)),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Merchant dashboard — replace these placeholders with real modules",
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
