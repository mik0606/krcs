// lib/pages/driver_dashboard_page.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../Models/order_model.dart';
import '../../Utils/Color.dart';


class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({Key? key}) : super(key: key);

  @override
  _DriverDashboardPageState createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  late Future<OrderModel?> _activeDeliveryFuture;
  late Future<List<OrderModel>> _nextDeliveriesFuture;
  late Future<Map<String, dynamic>> _statsFuture;

  // -- In-page mock data (keep all mocks here) -------------------------------
  final Map<String, dynamic> _mockStats = {
    'earnings': 120.50,
    'distance': 25.3,
    'completed': 7,
    'rating': 4.9,
  };

  final Map<String, dynamic> _mockActive = {
    'id': '12345',
    'pickup': '123 Main St',
    'dropoff': '456 Oak Ave',
    'eta': '12:30 PM',
    'type': 'Food',
    'status': 'In Transit',
    'distance': 2.5
  };

  final List<Map<String, dynamic>> _mockNext = [
    {
      'id': '67890',
      'pickup': '789 Pine St',
      'dropoff': '101 Elm St',
      'eta': '—',
      'type': 'Food',
      'status': 'Accepted',
      'distance': 3.2
    },
    {
      'id': '11223',
      'pickup': '222 Maple Ave',
      'dropoff': '333 Cedar Ln',
      'eta': '—',
      'type': 'Parcel',
      'status': 'Pending',
      'distance': 5.1
    },
    {
      'id': '44556',
      'pickup': '44 Ocean Blvd',
      'dropoff': '99 Harbor Rd',
      'eta': '—',
      'type': 'Grocery',
      'status': 'Pending',
      'distance': 8.4
    },
  ];
  // --------------------------------------------------------------------------

  bool _isOnline = true;
  String _statusFilter = 'All Statuses';

  @override
  void initState() {
    super.initState();
    _loadMocks();
  }

  void _loadMocks() {
    // Simulate network latency with Future.delayed
    _statsFuture = Future.delayed(const Duration(milliseconds: 300), () => Map<String, dynamic>.from(_mockStats));
    _activeDeliveryFuture = Future.delayed(const Duration(milliseconds: 450), () => OrderModel.fromJson(_mockActive));
    _nextDeliveriesFuture = Future.delayed(const Duration(milliseconds: 600), () => _mockNext.map((m) => OrderModel.fromJson(m)).toList());
  }

  Future<void> _refresh() async {
    // On refresh, reassign the futures to new delayed futures (simulates refetch)
    setState(() => _loadMocks());
    try {
      await Future.wait([_statsFuture, _activeDeliveryFuture, _nextDeliveriesFuture]);
    } catch (_) {}
  }

  Widget _buildHeader(String driverName, String avatarUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          backgroundColor: AppColors.cardLight,
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome back,', style: TextStyle(color: AppColors.subtleLight)),
          const SizedBox(height: 2),
          Text('Hi, $driverName', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textLight)),
        ]),
        const Spacer(),
        Row(
          children: [
            Text(_isOnline ? 'Online' : 'Offline', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Switch(
              value: _isOnline,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _isOnline = v),
            )
          ],
        )
      ],
    );
  }

  Widget _earningsCard(double earnings) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Today's Earnings", style: TextStyle(color: AppColors.subtleLight)),
            const SizedBox(height: 6),
            Text('\$${earnings.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
          TextButton(onPressed: () {}, child: const Text('View Details', style: TextStyle(color: Color(0xFFEF4444))))
        ],
      ),
    );
  }

  Widget _smallInfoColumn(String title, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: AppColors.subtleLight, fontSize: 12)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _activeDeliveryCard(OrderModel d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Order #${d.id}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.location_pin, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text('Pickup: ${d.pickup}', style: TextStyle(color: AppColors.subtleLight))),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.flag, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text('Dropoff: ${d.dropoff}', style: TextStyle(color: AppColors.subtleLight))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _smallInfoColumn('ETA', d.eta),
                const SizedBox(width: 12),
                Container(height: 32, width: 1, color: Colors.grey[200]),
                const SizedBox(width: 12),
                _smallInfoColumn('Type', d.type),
              ]),
            ]),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.navigation),
            label: const Text('Navigate'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16)),
          )
        ],
      ),
    );
  }

  Widget _statTile(String title, String value, {bool highlight = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text(title, style: TextStyle(color: AppColors.subtleLight, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: highlight ? AppColors.yellowStar : AppColors.textLight)),
        ]),
      ),
    );
  }

  Widget _statGrid(Map<String, dynamic> stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statTile('Distance', '${stats['distance']} mi'),
        _statTile('Completed', stats['completed'].toString()),
        _statTile('Rating', '${stats['rating']} ★', highlight: true),
      ],
    );
  }

  Widget _nextDeliveryTile(OrderModel o) {
    final bool accepted = o.status.toLowerCase() == 'accepted';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Order #${o.id}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('${o.pickup} → ${o.dropoff}', style: TextStyle(color: AppColors.subtleLight)),
              const SizedBox(height: 6),
              Text('${o.distanceKm.toStringAsFixed(1)} mi', style: TextStyle(color: AppColors.subtleLight, fontWeight: FontWeight.w500)),
            ])),
        Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accepted ? Colors.green[50] : Colors.yellow[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(o.status, style: TextStyle(color: accepted ? Colors.green[800] : Colors.yellow[800], fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          accepted
              ? IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right),
          )
              : ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Accept'))
        ])
      ]),
    );
  }



  Widget _iconNavItem(IconData icon, String label, {bool active = false}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: active ? AppColors.primary : AppColors.subtleLight),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: active ? AppColors.primary : AppColors.subtleLight)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        toolbarHeight: 120,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildHeader('Alex', 'https://lh3.googleusercontent.com/aida-public/AB6AXuA8hUE7vuMHegab42pgxsQf4nfgRXrm_H1P4iNVSGbiRTiuJojl4RuO9eVFhGqzNN8ZIgxVYbMspnbjA5g24p057CIj-jNSmuvtUH7rzwE8wbYf5PWTc8buWMBVN8Z5Y6JuPv0KNy8BvbwgCoBKCOd2lWPnGAgXuCYBawG-LAE6lzdJzFNuXQRv6zaKLhkY97V00VYSN8kiCakG1KC-fhURnL_bdRCiSSCyKlO5JZwzn0YUr4pPTBk_TPscRRk9Qo9T8SEI2qwyTpGO'),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, s) {
                if (s.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 84, child: Center(child: CircularProgressIndicator()));
                } else if (s.hasError || !s.hasData) {
                  return const SizedBox(height: 84, child: Center(child: Text('Failed to load stats')));
                } else {
                  final stats = s.data!;
                  return _earningsCard(stats['earnings']);
                }
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<OrderModel?>(
              future: _activeDeliveryFuture,
              builder: (context, s) {
                if (s.connectionState == ConnectionState.waiting) {
                  return Container(height: 140, alignment: Alignment.center, child: const CircularProgressIndicator());
                } else if (s.hasError) {
                  return Container(padding: const EdgeInsets.all(12), child: Text('Error: ${s.error}'));
                } else if (s.data == null) {
                  return Container(padding: const EdgeInsets.all(12), child: const Text('No active delivery'));
                } else {
                  return _activeDeliveryCard(s.data!);
                }
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, s) {
                if (s.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 70);
                } else if (!s.hasData) {
                  return const SizedBox(height: 70);
                } else {
                  return _statGrid(s.data!);
                }
              },
            ),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Next Deliveries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
                label: const Text('Filter'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ]),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _statusFilter,
              isExpanded: true,
              items: ['All Statuses', 'Pending', 'Accepted'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _statusFilter = v ?? 'All Statuses'),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<OrderModel>>(
              future: _nextDeliveriesFuture,
              builder: (context, s) {
                if (s.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()));
                } else if (s.hasError) {
                  return Container(padding: const EdgeInsets.all(12), child: Text('Error: ${s.error}'));
                } else if (!s.hasData || s.data!.isEmpty) {
                  return const Center(child: Text('No upcoming deliveries'));
                } else {
                  final filtered = s.data!.where((o) => _statusFilter == 'All Statuses' ? true : o.status == _statusFilter).toList();
                  return Column(children: filtered.map((o) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _nextDeliveryTile(o))).toList());
                }
              },
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.support_agent),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
