import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogisticsRootPage extends StatefulWidget {
  const LogisticsRootPage({super.key});

  @override
  State<LogisticsRootPage> createState() => _LogisticsRootPageState();
}

class _LogisticsRootPageState extends State<LogisticsRootPage> {
  int _selectedIndex = 0;

  // Page list — replace with your actual pages later
  final List<Widget> _pages = const [
    HomePage(),
    OrdersPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  // Navigation bar items
  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.local_shipping_rounded), label: 'Orders'),
    BottomNavigationBarItem(icon: Icon(Icons.notifications_active_rounded), label: 'Alerts'),
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
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            showUnselectedLabels: true,
            selectedItemColor: const Color(0xFFEF4444), // primary red
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

/// Dummy pages for navigation
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PageTemplate(title: "Dashboard Overview", icon: Icons.dashboard_rounded);
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PageTemplate(title: "Manage Shipments", icon: Icons.local_shipping_rounded);
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PageTemplate(title: "Notifications Center", icon: Icons.notifications_active_rounded);
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PageTemplate(title: "My Profile", icon: Icons.person_rounded);
  }
}

/// Common UI template for each tab
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
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Enterprise Logistics Dashboard",
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
