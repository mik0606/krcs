// lib/Modules/Driver/DriverRootPage.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Services/AuthServices.dart';
import '../Common/Login_Page.dart';
import 'Earnings.dart';
import 'HomePage.dart';
import 'MyordersPage.dart';
import 'ProfilePage.dart';

class DriverRootPage extends StatefulWidget {
  const DriverRootPage({super.key});

  @override
  State<DriverRootPage> createState() => _DriverRootPageState();
}

class _DriverRootPageState extends State<DriverRootPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DriverDashboardPage(),
    DriverOrdersPage(),
    DriverEarningsPage(),
    DriverProfilePage(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.local_shipping_rounded), label: 'My Orders'),
    BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Earnings'),
    BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
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
/// 🚚 Driver Dashboard Page
/// ---------------------------------------------------------------------------

/// ---------------------------------------------------------------------------
/// 📦 Driver Orders Page
/// ---------------------------------------------------------------------------

/// ---------------------------------------------------------------------------
/// 💰 Driver Earnings Page
/// ---------------------------------------------------------------------------


/// ---------------------------------------------------------------------------
/// 👤 Driver Profile Page with Logout Button
/// ---------------------------------------------------------------------------

/// ---------------------------------------------------------------------------
/// 🌟 Common Page Template for Placeholders
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
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              "Driver Control Panel — Spazigo Fleet System",
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
