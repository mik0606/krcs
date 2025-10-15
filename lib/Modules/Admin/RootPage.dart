import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Services/AuthServices.dart';
import '../Common/Login_Page.dart';
import '../Logistics_s/RootPage.dart';
import 'DashboardPage.dart';
import 'LspPage.dart';
import 'MerchantsPage.dart';
import 'ProfilePage.dart';

class AdminRootPage extends StatefulWidget {
  const AdminRootPage({super.key});

  @override
  State<AdminRootPage> createState() => _AdminRootPageState();
}

class _AdminRootPageState extends State<AdminRootPage> {
  int _selectedIndex = 0;

  // Page list — placeholder screens for now
  final List<Widget> _pages = const [
    AdminDashboardPage(),
    LspManagementPage(),
    MerchantManagementPage(),
    ProfilePage(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.local_shipping_rounded), label: 'LSPs'),
    BottomNavigationBarItem(icon: Icon(Icons.storefront_rounded), label: 'Merchants'),
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
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            showUnselectedLabels: true,
            selectedItemColor: const Color(0xFFEF4444),
            unselectedItemColor: Colors.grey.shade500,
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
/// 🏠 Dashboard Page
/// ---------------------------------------------------------------------------


/// ---------------------------------------------------------------------------
/// 👥 Manage Users Page
/// ---------------------------------------------------------------------------
class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PageTemplate(title: "User Management", icon: Icons.group_rounded);
  }
}

/// ---------------------------------------------------------------------------
/// 📊 Reports Page
/// ---------------------------------------------------------------------------
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PageTemplate(title: "Reports & Analytics", icon: Icons.bar_chart_rounded);
  }
}

/// ---------------------------------------------------------------------------
/// 👤 Profile Page with Logout Button
/// ---------------------------------------------------------------------------


/// ---------------------------------------------------------------------------
/// 🌟 Common Page Template for Placeholder Pages
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
              "Admin Panel - Spazigo",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
