import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const DriverManagementApp());
}

class DriverManagementApp extends StatelessWidget {
  const DriverManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Driver Management',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFEF4343),
        scaffoldBackgroundColor: const Color(0xFFF8F6F6),
        fontFamily: GoogleFonts.inter().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F6F6),
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFEF4343),
        scaffoldBackgroundColor: const Color(0xFF221010),
        fontFamily: GoogleFonts.inter().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF221010),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const DriverManagementPage(),
    );
  }
}

class Driver {
  final String name;
  final String lsp;
  final String dlNumber;
  final String image;
  final bool active;

  Driver({
    required this.name,
    required this.lsp,
    required this.dlNumber,
    required this.image,
    required this.active,
  });
}

class DriverManagementPage extends StatefulWidget {
  const DriverManagementPage({super.key});

  @override
  State<DriverManagementPage> createState() => _DriverManagementPageState();
}

class _DriverManagementPageState extends State<DriverManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 3; // Drivers tab selected by default

  final List<Driver> drivers = [
    Driver(
      name: 'Ethan Carter',
      lsp: 'Swift Logistics',
      dlNumber: 'AB123456',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCRUSdrXwpO3fKgw_RGo3VYymsZVVemR0Wv2roo884DJHnvpWKwHTgmD9I6eTHGYmKCu4QKMfD1-D-tRuuAoJ6kYT1VlT6ptbKgZy4ttyG8fjz9nlWarJG8RQkPLRgiZRm0hxTKZmcQcq4GXNdlHHKJ88NOVhdiKemVjsVuvz_-gyYlJZO-_nKpAoKlAUt3c-T8v9iVBcU8tqekIef7_yobApj2AQ9RbRqMq3RrYXN3ewrGo9uLrluwNgoTUYRYd-EZZQ1BzHPaab4A',
      active: true,
    ),
    Driver(
      name: 'Olivia Bennett',
      lsp: 'Rapid Delivery',
      dlNumber: 'CD789012',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDOXXbxCyL-Qq2B56baLrtJO3Wb0OV8InDpnXMBAoxwP0HnpmP8P2FIBwMNwGorIEqnynhJtcqZo4LM78iezU2vD1XNu9f-4XBnNR-F4UwrM4D58RGZ7kP2QIiLW4JojcNkiDc6eP_NIkRUvZ_XMX5PD8kSQX4QOWSx473aXivnbaq0QOnb6s8SoyMpck10ZepHF6FTTqS7v0RVedc1fU1Rbd59BuDfvppITMjdkGTCz8sRYO2QFont8ZnK1AGc4--PXAcGv_aZR0gK',
      active: false,
    ),
    Driver(
      name: 'Noah Thompson',
      lsp: 'Express Couriers',
      dlNumber: 'EF345678',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD87Zti_9a5ZBAcTXCFwMMtDUbHgbVU8Kgs4lbvzvvfZNIntRGglTpKYb2TozWkEWQX9tGyfaTJsHo1s_J3aUUrItpmNWs50-cJJME9gBBnWhe_WxHOK4_83IAFeJgEn-vym8Oa4z5OUIkKYHYRE9wwDODIt9uS3f1cpJ-nFprxxPpT7hZYG3UPixt9WkWS46wZg32ZFIpQ9m1ygFmwsabIa4iLR9DW7wEevBOHN0izIn-GthMgBO8OABWPnoCxJQ-k_m4TxCVlk5DF',
      active: true,
    ),
    Driver(
      name: 'Ava Harper',
      lsp: 'Swift Logistics',
      dlNumber: 'GH901234',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAN2-1dcsaKKAKP5yI60SEG4dB6qDyAw7sozYDOmYHD5cTbq_KgYXbVvYsizI7v5lBr68I4UNucAhqW8-6RWI_iS14njpJuLOvgcrxWrTmuOVRdJq1gZetfdwqyadJBAy9asSl4Y_6F0N5vje4cdr9H0-iIlmw68VhpvUopUPz7Z6_8DweIOiZlkMAIfDaCxs7maqXpW_WhfgiuzruuPOqrRB9Gby9N5fJV47iPJhCA54MFUsfxCYU9TS6Eixi4tImNdHG20I0832Rv',
      active: true,
    ),
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final bgLight = const Color(0xFFF8F6F6);
    final bgDark = const Color(0xFF221010);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: primary.withOpacity(isDark ? 0.3 : 0.2))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    color: isDark ? Colors.white : Colors.black87,
                    onPressed: () {},
                  ),
                  Text(
                    'Driver Management',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search drivers...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Driver list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  final d = drivers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(d.image, width: 56, height: 56, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: d.active ? Colors.green : Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isDark ? bgDark : Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.name,
                                      style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87)),
                                  Text('LSP: ${d.lsp}',
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                  Text('DL: ${d.dlNumber}',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: isDark ? Colors.grey[500] : Colors.grey[400])),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  d.active ? Icons.signal_cellular_alt : Icons.signal_cellular_off,
                                  color: d.active ? Colors.green : Colors.grey,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(d.active ? 'Active' : 'Offline',
                                    style: GoogleFonts.inter(
                                        fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[500])),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: primary.withOpacity(0.1),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text('View',
                                      style: TextStyle(
                                          color: primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Track', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primary,
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[500],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'LSPs'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Merchants'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_motorsports), label: 'Drivers'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
        ],
      ),
    );
  }
}
