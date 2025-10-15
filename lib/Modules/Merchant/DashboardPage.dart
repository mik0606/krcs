// lib/pages/merchant_dashboard_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../Utils/Color.dart';

/// Enterprise-grade Merchant Dashboard page (single file)
/// - Uses CustomScrollView + slivers to avoid RenderFlex / overflow issues
/// - Mock data bundled inside
/// - Booking modal updates local state and validates input
/// - Clean, modular helper widgets inside file (easy to split later)

/// ------------------- Models -------------------
class Truck {
  final String truckId;
  final String driver;
  final String routeStart;
  final String routeEnd;
  final DateTime departure;
  final DateTime eta;
  double remainingSpaceM3;
  final double totalCapacityM3;
  final double pricePerM3;
  final String vehicleType;
  final double rating;
  final String imageUrl;

  Truck({
    required this.truckId,
    required this.driver,
    required this.routeStart,
    required this.routeEnd,
    required this.departure,
    required this.eta,
    required this.remainingSpaceM3,
    required this.totalCapacityM3,
    required this.pricePerM3,
    required this.vehicleType,
    required this.rating,
    required this.imageUrl,
  });
}

class Booking {
  final String bookingId;
  final String route;
  final DateTime date;
  final double bookedSpaceM3;
  final double cost;
  String status;
  final String truckId;

  Booking({
    required this.bookingId,
    required this.route,
    required this.date,
    required this.bookedSpaceM3,
    required this.cost,
    required this.status,
    required this.truckId,
  });
}

/// ------------------- Page -------------------
class MerchantDashboardPage extends StatefulWidget {
  const MerchantDashboardPage({Key? key}) : super(key: key);

  @override
  State<MerchantDashboardPage> createState() => _MerchantDashboardPageState();
}

class _MerchantDashboardPageState extends State<MerchantDashboardPage> {
  // Mock data
  late final List<Truck> _allTrucks;
  late final List<Booking> _bookings;

  // Search controllers
  final TextEditingController _pickupCtrl = TextEditingController();
  final TextEditingController _dropoffCtrl = TextEditingController();
  final TextEditingController _spaceCtrl = TextEditingController();
  DateTime? _selectedDate;

  // UI state
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initMocks();
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    _spaceCtrl.dispose();
    super.dispose();
  }

  void _initMocks() {
    final now = DateTime.now();
    _allTrucks = [
      Truck(
        truckId: 'TRK-101',
        driver: 'Ravi Kumar',
        routeStart: 'Chennai',
        routeEnd: 'Bengaluru',
        departure: now.add(const Duration(days: 2, hours: 18)),
        eta: now.add(const Duration(days: 3, hours: 8)),
        remainingSpaceM3: 8.5,
        totalCapacityM3: 20,
        pricePerM3: 1200,
        vehicleType: 'Container',
        rating: 4.6,
        imageUrl:
        'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=400&q=60',
      ),
      Truck(
        truckId: 'TRK-207',
        driver: 'Sita Rao',
        routeStart: 'Coimbatore',
        routeEnd: 'Bengaluru',
        departure: now.add(const Duration(days: 4, hours: 7)),
        eta: now.add(const Duration(days: 4, hours: 13)),
        remainingSpaceM3: 4.3,
        totalCapacityM3: 12,
        pricePerM3: 950,
        vehicleType: 'Flatbed',
        rating: 4.4,
        imageUrl:
        'https://images.unsplash.com/photo-1549921296-3a4d5f8f6a5b?auto=format&fit=crop&w=400&q=60',
      ),
      Truck(
        truckId: 'TRK-309',
        driver: 'Arjun S.',
        routeStart: 'Mumbai',
        routeEnd: 'Delhi',
        departure: now.add(const Duration(days: 3, hours: 8)),
        eta: now.add(const Duration(days: 3, hours: 20)),
        remainingSpaceM3: 10.2,
        totalCapacityM3: 30,
        pricePerM3: 1500,
        vehicleType: 'Trailer',
        rating: 4.7,
        imageUrl:
        'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=400&q=60',
      ),
      Truck(
        truckId: 'TRK-411',
        driver: 'Vijay P.',
        routeStart: 'Kolkata',
        routeEnd: 'Hyderabad',
        departure: now.add(const Duration(days: 5, hours: 10)),
        eta: now.add(const Duration(days: 5, hours: 22)),
        remainingSpaceM3: 6.8,
        totalCapacityM3: 18,
        pricePerM3: 1000,
        vehicleType: 'Container',
        rating: 4.3,
        imageUrl:
        'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=400&q=60',
      ),
      Truck(
        truckId: 'TRK-502',
        driver: 'Meera L.',
        routeStart: 'Ahmedabad',
        routeEnd: 'Pune',
        departure: now.add(const Duration(days: 1, hours: 9)),
        eta: now.add(const Duration(days: 1, hours: 15)),
        remainingSpaceM3: 12.0,
        totalCapacityM3: 25,
        pricePerM3: 800,
        vehicleType: 'Open Bed',
        rating: 4.5,
        imageUrl:
        'https://images.unsplash.com/photo-1518183214770-9cffbec72538?auto=format&fit=crop&w=400&q=60',
      ),
    ];

    _bookings = [
      Booking(
        bookingId: 'BK-20231018-001',
        route: 'Chennai → Bengaluru',
        date: DateTime.now().subtract(const Duration(days: 1)),
        bookedSpaceM3: 2.0,
        cost: 2400.0,
        status: 'Delivered',
        truckId: 'TRK-101',
      ),
      Booking(
        bookingId: 'BK-20231017-002',
        route: 'Mumbai → Delhi',
        date: DateTime.now().subtract(const Duration(days: 2)),
        bookedSpaceM3: 3.0,
        cost: 4500.0,
        status: 'In Transit',
        truckId: 'TRK-309',
      ),
      Booking(
        bookingId: 'BK-20231016-003',
        route: 'Kolkata → Hyderabad',
        date: DateTime.now().subtract(const Duration(days: 3)),
        bookedSpaceM3: 1.5,
        cost: 1500.0,
        status: 'Pending',
        truckId: 'TRK-411',
      ),
    ];
  }

  // ----------------- Helpers -----------------
  List<Truck> _filterTrucksPreview() {
    final pickup = _pickupCtrl.text.trim().toLowerCase();
    final dropoff = _dropoffCtrl.text.trim().toLowerCase();
    final requiredSpace = double.tryParse(_spaceCtrl.text.trim()) ?? 0.0;

    return _allTrucks.where((t) {
      final matchesPickup = pickup.isEmpty || t.routeStart.toLowerCase().contains(pickup);
      final matchesDropoff = dropoff.isEmpty || t.routeEnd.toLowerCase().contains(dropoff);
      final hasSpace = requiredSpace <= 0.0 || t.remainingSpaceM3 >= requiredSpace;
      final matchesDate = _selectedDate == null ||
          (t.departure.year == _selectedDate!.year &&
              t.departure.month == _selectedDate!.month &&
              t.departure.day == _selectedDate!.day);
      return matchesPickup && matchesDropoff && hasSpace && matchesDate;
    }).toList();
  }

  String _formatDateTime(DateTime d) {
    final day = '${d.day}-${d.month}-${d.year}';
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$day $h:$m';
  }

  void _openDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _pickupCtrl.clear();
      _dropoffCtrl.clear();
      _spaceCtrl.clear();
      _selectedDate = null;
    });
  }

  // Booking logic
  Future<void> _openBookingModal(Truck truck) async {
    // use StatefulBuilder inside bottom sheet to handle local modal state
    final requestedCtrl = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16),
              child: StatefulBuilder(builder: (ctx, setModalState) {
                double requested = double.tryParse(requestedCtrl.text) ?? 0.0;
                final estCost = (requested * truck.pricePerM3);

                return SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Container(width: 48, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)))),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _truckAvatar(truck.imageUrl, size: 64),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${truck.routeStart} → ${truck.routeEnd}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Driver: ${truck.driver} • ${truck.vehicleType}'),
                              const SizedBox(height: 6),
                              Text('Remaining: ${truck.remainingSpaceM3.toStringAsFixed(1)} m³  •  ₹${truck.pricePerM3.toStringAsFixed(0)}/m³'),
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Requested space (m³)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textLight)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: requestedCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'e.g. 2.0',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (v) {
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      Text('Estimated cost', style: TextStyle(color: AppColors.subtleLight)),
                      const SizedBox(height: 6),
                      Text('₹${estCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final val = double.tryParse(requestedCtrl.text) ?? 0.0;
                              if (val <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid space')));
                                return;
                              }
                              if (val > truck.remainingSpaceM3) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Requested space exceeds remaining capacity')));
                                return;
                              }
                              _confirmBooking(truck, val);
                              Navigator.of(context).pop(true);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Confirm Booking')),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            );
          },
        );
      },
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking confirmed')));
    }
  }

  void _confirmBooking(Truck truck, double requestedM3) {
    setState(() {
      final idx = _allTrucks.indexWhere((t) => t.truckId == truck.truckId);
      if (idx != -1) {
        _allTrucks[idx].remainingSpaceM3 = max(0.0, _allTrucks[idx].remainingSpaceM3 - requestedM3);
      }
      final booking = Booking(
        bookingId: 'BK-${DateTime.now().millisecondsSinceEpoch}',
        route: '${truck.routeStart} → ${truck.routeEnd}',
        date: DateTime.now(),
        bookedSpaceM3: requestedM3,
        cost: requestedM3 * truck.pricePerM3,
        status: 'Booked',
        truckId: truck.truckId,
      );
      _bookings.insert(0, booking);
    });
  }

  // Rebook shortcut from booking card
  void _rebookFromBooking(Booking b) {
    final parts = b.route.split('→').map((s) => s.trim()).toList();
    if (parts.length == 2) {
      setState(() {
        _pickupCtrl.text = parts[0];
        _dropoffCtrl.text = parts[1];
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search pre-filled from booking — tap Find Trucks')));
    }
  }

  // ----------------- Small UI building blocks -----------------
  Widget _truckAvatar(String url, {double size = 48}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(url, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
        return Container(width: size, height: size, color: Colors.grey[300]);
      }),
    );
  }

  Widget _kpiCard(String label, String value, String delta, Color deltaColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: AppColors.subtleLight, fontSize: 12)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(delta, style: TextStyle(color: deltaColor, fontWeight: FontWeight.w600)),
          ]),
          Icon(Icons.show_chart, color: deltaColor),
        ]),
      ]),
    );
  }

  Widget _truckCardSmall(Truck t) {
    return Material(
      color: AppColors.cardLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openBookingModal(t),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            _truckAvatar(t.imageUrl, size: 64),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${t.routeStart} → ${t.routeEnd}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Departs ${_formatDateTime(t.departure)}', style: TextStyle(color: AppColors.subtleLight, fontSize: 12)),
                const SizedBox(height: 6),
                Text('${t.remainingSpaceM3.toStringAsFixed(1)} m³ • ₹${t.pricePerM3.toStringAsFixed(0)}/m³ • ${t.driver}', style: TextStyle(color: AppColors.subtleLight, fontSize: 12)),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: () => _openBookingModal(t),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.primary)),
                    child: Text('Book', style: TextStyle(color: AppColors.primary)),
                  ),
                )
              ]),
            )
          ]),
        ),
      ),
    );
  }

  Widget _bookingRow(Booking b) {
    Color chipColor;
    Color textColor;
    switch (b.status) {
      case 'Delivered':
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'In Transit':
        chipColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case 'Pending':
        chipColor = Colors.yellow.shade100;
        textColor = Colors.orange.shade800;
        break;
      default:
        chipColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      title: Text(b.route, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(b.bookingId, style: TextStyle(color: AppColors.subtleLight)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(12)), child: Text(b.status, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        IconButton(onPressed: () => _rebookFromBooking(b), icon: Icon(Icons.replay, color: AppColors.subtleLight)),
      ]),
      onTap: () {
        // booking detail dialog
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Booking ${b.bookingId}'),
            content: Text('Route: ${b.route}\nSpace: ${b.bookedSpaceM3} m³\nCost: ₹${b.cost.toStringAsFixed(0)}\nStatus: ${b.status}'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
          ),
        );
      },
    );
  }

  // ----------------- Navigation / secondary pages -----------------
  void _onBottomNavTap(int idx) {
    setState(() {
      _activeTabIndex = idx;
    });

    switch (idx) {
      case 0:
      // home - already here
        break;
      case 1:
        _openBookingsPage();
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Messages (stub)')));
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile (stub)')));
        break;
    }
  }

  void _openBookingsPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Bookings'), backgroundColor: AppColors.backgroundLight, foregroundColor: AppColors.textLight, elevation: 0),
        body: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemBuilder: (c, i) => _bookingRow(_bookings[i]),
          separatorBuilder: (_, __) => const Divider(),
          itemCount: _bookings.length,
        ),
      );
    }));
  }

  void _openMatchingList() {
    final results = _filterTrucksPreview();
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return Scaffold(
        appBar: AppBar(title: const Text('Matching Trucks'), backgroundColor: AppColors.backgroundLight, foregroundColor: AppColors.textLight),
        body: results.isEmpty
            ? Center(child: Text('No matching trucks', style: TextStyle(color: AppColors.subtleLight)))
            : ListView.separated(
          padding: const EdgeInsets.all(12),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _truckCardSmall(results[index]),
          itemCount: results.length,
        ),
      );
    }));
  }

  // ----------------- Build -----------------
  @override
  Widget build(BuildContext context) {
    final previewTrucks = _filterTrucksPreview();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(children: [
                  _truckAvatar(_allTrucks.first.imageUrl, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Spazigo Express', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text('4.8', style: TextStyle(color: AppColors.subtleLight)),
                        const SizedBox(width: 6),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                      ]),
                    ]),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
                ]),
              ),
            ),

            // KPI grid (2 columns)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                  _kpiCard('Active Bookings', '${_bookings.where((b) => b.status == 'Booked' || b.status == 'In Transit').length}', '+10%', Colors.green),
                  _kpiCard('Space Booked', '${_bookings.fold<double>(0, (s, b) => s + b.bookedSpaceM3).toStringAsFixed(0)} m³', '+5%', Colors.green),
                  _kpiCard('Upcoming Matches', '${_allTrucks.length}', '-2%', Colors.red),
                  _kpiCard('Saved Routes', '5', '+8%', Colors.green),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.3),
              ),
            ),

            // Search form
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      // Pickup
                      TextField(
                        controller: _pickupCtrl,
                        decoration: InputDecoration(prefixIcon: const Icon(Icons.location_on), hintText: 'Pickup', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                      ),
                      const SizedBox(height: 8),
                      // Dropoff
                      TextField(
                        controller: _dropoffCtrl,
                        decoration: InputDecoration(prefixIcon: const Icon(Icons.flag), hintText: 'Dropoff', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: _spaceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(prefixIcon: const Icon(Icons.aspect_ratio), hintText: 'Space (m³)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: _openDatePicker,
                            child: AbsorbPointer(
                              child: TextField(
                                controller: TextEditingController(text: _selectedDate == null ? 'Any Date' : '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}'),
                                decoration: InputDecoration(prefixIcon: const Icon(Icons.calendar_today), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                              ),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Searching trucks...')));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                            child: const Text('Find Trucks', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(onPressed: _clearSearch, icon: const Icon(Icons.clear)),
                      ]),
                    ],
                  ),
                ),
              ),
            ),

            // Matches preview header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Matches Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: _openMatchingList, child: Text('View all', style: TextStyle(color: AppColors.primary))),
                ]),
              ),
            ),

            // Matches preview list (sliver list)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: previewTrucks.isEmpty
                  ? SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text('No matches — widen your search', style: TextStyle(color: AppColors.subtleLight))),
                ),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    // show up to 3 preview items
                    if (index >= min(previewTrucks.length, 3)) return null;
                    return Padding(padding: const EdgeInsets.only(bottom: 12), child: _truckCardSmall(previewTrucks[index]));
                  },
                  childCount: min(previewTrucks.length, 3),
                ),
              ),
            ),

            // Recent bookings header
            SliverToBoxAdapter(
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: const Text('Recent Bookings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            ),

            // Bookings list (sliver list)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _bookingRow(_bookings[index]),
                  childCount: _bookings.length,
                ),
              ),
            ),

            // bottom padding
            SliverToBoxAdapter(child: SizedBox(height: 88)),
          ],
        ),
      ),
    );
  }
}
