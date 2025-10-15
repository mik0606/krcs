// lib/pages/driver_orders_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../Models/order_model.dart';
import '../../Utils/Color.dart';

// If you already have an OrderModel in your project, replace the fallback model below
// with your import: import '../models/order_model.dart';



class DriverOrdersPage extends StatefulWidget {
  const DriverOrdersPage({Key? key}) : super(key: key);

  @override
  _DriverOrdersPageState createState() => _DriverOrdersPageState();
}

class _DriverOrdersPageState extends State<DriverOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<OrderModel>> _ordersFuture;

  // In-page mock data (kept inside the page)
  final List<Map<String, dynamic>> _mockData = [
    {
      'id': '12345',
      'pickup': '123 Main St',
      'dropoff': '456 Oak Ave',
      'eta': '30 min',
      'type': 'Food',
      'status': 'In-Transit',
      'distanceKm': 15.0
    },
    {
      'id': '67890',
      'pickup': '789 Pine St',
      'dropoff': '101 Elm St',
      'eta': '15 min',
      'type': 'Parcel',
      'status': 'Accepted',
      'distanceKm': 8.0
    },
    {
      'id': '24680',
      'pickup': '321 Maple Ave',
      'dropoff': '654 Cedar Ln',
      'eta': '45 min',
      'type': 'Grocery',
      'status': 'Pending',
      'distanceKm': 22.0
    },
    {
      'id': '99999',
      'pickup': '12 Ocean Rd',
      'dropoff': '34 Harbor Way',
      'eta': '—',
      'type': 'Food',
      'status': 'Completed',
      'distanceKm': 5.2
    },
  ];

  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _ordersFuture = _loadMockOrders();
  }

  Future<List<OrderModel>> _loadMockOrders() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockData.map((m) => OrderModel.fromJson(m)).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _ordersFuture = _loadMockOrders();
    });
    try {
      await _ordersFuture;
    } catch (_) {}
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders, int tabIndex) {
    final q = _searchQuery.trim().toLowerCase();
    final filtered = orders.where((o) {
      // Tab filter
      final tabMatch = switch (tabIndex) {
        0 => ['In-Transit', 'Accepted'].contains(o.status),
        1 => o.status == 'Pending',
        2 => o.status == 'Completed',
        _ => true,
      };

      // Search filter: check id/pickup/dropoff/type
      final searchMatch = q.isEmpty ||
          o.id.toLowerCase().contains(q) ||
          o.pickup.toLowerCase().contains(q) ||
          o.dropoff.toLowerCase().contains(q) ||
          o.type.toLowerCase().contains(q);

      return tabMatch && searchMatch;
    }).toList();

    // Optionally sort: active first by ETA/Proximity (simple: distance ascending)
    filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return filtered;
  }

  Color _badgeBg(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.statusPending.withOpacity(0.16);
      case 'Accepted':
        return AppColors.statusAccepted.withOpacity(0.12);
      case 'In-Transit':
        return AppColors.statusInTransit.withOpacity(0.12);
      case 'Completed':
        return AppColors.statusCompleted.withOpacity(0.12);
      default:
        return Colors.grey.withOpacity(0.12);
    }
  }

  Color _badgeTextColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.statusPending;
      case 'Accepted':
        return AppColors.statusAccepted;
      case 'In-Transit':
        return AppColors.statusInTransit;
      case 'Completed':
        return AppColors.statusCompleted;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          children: [
            // Row: refresh, title, notifications
            Row(
              children: [
                IconButton(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  color: AppColors.textLight,
                ),
                const Spacer(),
                Text('Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textLight)),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications),
                  color: AppColors.textLight,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search orders...',
                      filled: true,
                      fillColor: AppColors.cardLight.withOpacity(0.95),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => setState(() {
                      _searchQuery = v;
                    }),
                    onTap: () => setState(() => _isSearching = true),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // open filters (not implemented)
                  },
                  icon: const Icon(Icons.tune),
                  color: AppColors.textLight,
                )
              ],
            ),
            const SizedBox(height: 12),
            // Tabs
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardLight.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.subtleLight,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.0, color: AppColors.primary),
                  insets: const EdgeInsets.symmetric(horizontal: 12),
                ),
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(OrderModel o) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // left content
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('#${o.id}', style: TextStyle(fontSize: 12, color: AppColors.subtleLight)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(o.pickup, style: TextStyle(fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.flag, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(o.dropoff, style: TextStyle(fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 8),
              Text('${o.distanceKm.toStringAsFixed(1)} km • ${o.type}', style: TextStyle(color: AppColors.subtleLight, fontSize: 12)),
            ]),
          ),

          // right content
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _badgeBg(o.status),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                o.status,
                style: TextStyle(color: _badgeTextColor(o.status), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                // open navigation or details
              },
              icon: const Icon(Icons.navigation, size: 18),
              label: Text('ETA: ${o.eta}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _tabViewContent(int tabIndex, List<OrderModel> orders) {
    final list = _filterOrders(orders, tabIndex);
    if (list.isEmpty) {
      return Center(
        child: Text('No orders', style: TextStyle(color: AppColors.subtleLight)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final o = list[index];
        return _orderCard(o);
      },
    );
  }

  Widget _bottomNav() {
    return BottomAppBar(
      elevation: 8,
      color: AppColors.cardLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _navItem(Icons.home, 'Home', active: false),
          _navItem(Icons.inventory_2, 'Orders', active: true),
          _navItem(Icons.payments, 'Earnings', active: false),
          _navItem(Icons.person, 'Profile', active: false),
        ]),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {bool active = false}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: active ? AppColors.primary : AppColors.subtleLight),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: active ? AppColors.primary : AppColors.subtleLight)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Use a light background and card colors; the app's theme should adapt to dark mode elsewhere.
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: FutureBuilder<List<OrderModel>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load orders', style: TextStyle(color: AppColors.subtleLight)));
                } else {
                  final orders = snapshot.data ?? [];
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _tabViewContent(0, orders),
                      _tabViewContent(1, orders),
                      _tabViewContent(2, orders),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Support action
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.support_agent),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
