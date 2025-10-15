// lib/pages/merchant_orders_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Utils/Color.dart';

/// Booking model (self-contained)
class Booking {
  final String bookingId;
  final String truckId;
  final String route; // "Start → End"
  final DateTime date;
  final double bookedSpaceM3;
  final double cost;
  String status; // Booked, In Transit, Delivered, Pending, Cancelled

  Booking({
    required this.bookingId,
    required this.truckId,
    required this.route,
    required this.date,
    required this.bookedSpaceM3,
    required this.cost,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'truckId': truckId,
    'route': route,
    'date': date.toIso8601String(),
    'bookedSpaceM3': bookedSpaceM3,
    'cost': cost,
    'status': status,
  };
}

/// Orders / Past Bookings page
class MerchantOrdersPage extends StatefulWidget {
  /// Optional: initial list can be passed in (defaults to mock)
  final List<Booking>? initialBookings;
  const MerchantOrdersPage({Key? key, this.initialBookings}) : super(key: key);

  @override
  State<MerchantOrdersPage> createState() => _MerchantOrdersPageState();
}

class _MerchantOrdersPageState extends State<MerchantOrdersPage> {
  // Data
  late List<Booking> _bookings;

  // Filters & search
  String _statusFilter = 'All';
  final List<String> _statuses = ['All', 'Booked', 'In Transit', 'Delivered', 'Pending', 'Cancelled'];
  final TextEditingController _searchCtrl = TextEditingController();
  DateTimeRange? _dateRange;

  // UI
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _bookings = widget.initialBookings ?? _mockBookings();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ------------ Mock data -------------
  List<Booking> _mockBookings() {
    final now = DateTime.now();
    return [
      Booking(
        bookingId: 'BK-20251012-001',
        truckId: 'TRK-101',
        route: 'Chennai → Bengaluru',
        date: now.subtract(const Duration(days: 2)),
        bookedSpaceM3: 2.0,
        cost: 2400,
        status: 'Delivered',
      ),
      Booking(
        bookingId: 'BK-20251011-002',
        truckId: 'TRK-309',
        route: 'Mumbai → Delhi',
        date: now.subtract(const Duration(days: 4)),
        bookedSpaceM3: 3.0,
        cost: 4500,
        status: 'In Transit',
      ),
      Booking(
        bookingId: 'BK-20251010-003',
        truckId: 'TRK-411',
        route: 'Kolkata → Hyderabad',
        date: now.subtract(const Duration(days: 6)),
        bookedSpaceM3: 1.5,
        cost: 1500,
        status: 'Pending',
      ),
      Booking(
        bookingId: 'BK-20251007-004',
        truckId: 'TRK-502',
        route: 'Ahmedabad → Pune',
        date: now.subtract(const Duration(days: 9)),
        bookedSpaceM3: 4.0,
        cost: 3200,
        status: 'Cancelled',
      ),
      Booking(
        bookingId: 'BK-20251005-005',
        truckId: 'TRK-207',
        route: 'Coimbatore → Bengaluru',
        date: now.subtract(const Duration(days: 11)),
        bookedSpaceM3: 2.5,
        cost: 2375,
        status: 'Delivered',
      ),
    ];
  }

  // ------------ Filtering & searching -------------
  List<Booking> get _filteredBookings {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _bookings.where((b) {
      final matchesStatus = _statusFilter == 'All' || b.status == _statusFilter;
      final matchesQuery = q.isEmpty || b.bookingId.toLowerCase().contains(q) || b.route.toLowerCase().contains(q) || b.truckId.toLowerCase().contains(q);
      final matchesDate = _dateRange == null || (b.date.isAfter(_dateRange!.start.subtract(const Duration(seconds: 1))) && b.date.isBefore(_dateRange!.end.add(const Duration(seconds: 1))));
      return matchesStatus && matchesQuery && matchesDate;
    }).toList();
  }

  // ------------ CSV export (simple in-file exporter) -------------
  String _escapeCsv(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  String _bookingsToCsv(List<Booking> list) {
    final sb = StringBuffer();
    sb.writeln('bookingId,truckId,route,date,bookedSpaceM3,cost,status');
    for (final b in list) {
      sb.writeln('${_escapeCsv(b.bookingId)},${_escapeCsv(b.truckId)},${_escapeCsv(b.route)},${_escapeCsv(b.date.toIso8601String())},${b.bookedSpaceM3.toStringAsFixed(2)},${b.cost.toStringAsFixed(2)},${_escapeCsv(b.status)}');
    }
    return sb.toString();
  }

  void _exportCsvAll() {
    final csv = _bookingsToCsv(_filteredBookings);
    // In production we'd save/share. Here we print & show a SnackBar.
    // ignore: avoid_print
    print(csv);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV exported (preview in console)')));
  }

  void _exportCsvSingle(Booking b) {
    final csv = _bookingsToCsv([b]);
    // ignore: avoid_print
    print(csv);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking CSV exported (preview in console)')));
  }

  // ------------ UI actions -------------
  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initial = DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _dateRange ?? initial,
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _dateRange = null;
    });
  }

  void _openBookingDetail(Booking b) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, sc) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: SingleChildScrollView(
                controller: sc,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 48, height: 6, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)))),
                    const SizedBox(height: 12),
                    Text('Booking ${b.bookingId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _detailRow('Route', b.route),
                    _detailRow('Truck ID', b.truckId),
                    _detailRow('Date', '${b.date.day}-${b.date.month}-${b.date.year} ${b.date.hour.toString().padLeft(2, '0')}:${b.date.minute.toString().padLeft(2, '0')}'),
                    _detailRow('Space booked', '${b.bookedSpaceM3} m³'),
                    _detailRow('Cost', '₹${b.cost.toStringAsFixed(0)}'),
                    _detailRow('Status', b.status),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _exportCsvSingle(b);
                          },
                          child: const Text('Export CSV'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Rebook: return route info to caller (dashboard) using Navigator.pop
                            Navigator.of(context).pop();
                            Navigator.of(context).pop({'rebookRoute': b.route, 'defaultSpace': b.bookedSpaceM3});
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text('Rebook'),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110, child: Text(label, style: TextStyle(color: AppColors.subtleLight))),
        const SizedBox(width: 12),
        Expanded(child: Text(value, style: TextStyle(color: AppColors.textLight))),
      ]),
    );
  }

  // ------------ Utility: update booking status (demo) -------------
  void _updateBookingStatus(Booking b, String newStatus) {
    setState(() {
      final idx = _bookings.indexWhere((x) => x.bookingId == b.bookingId);
      if (idx != -1) _bookings[idx].status = newStatus;
    });
  }

  // ------------ Build -------------
  @override
  Widget build(BuildContext context) {
    final results = _filteredBookings;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Export CSV (filtered)',
            onPressed: _filteredBookings.isEmpty ? null : _exportCsvAll,
            icon: const Icon(Icons.download_outlined),
            color: AppColors.textLight,
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Filters area
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search + date controls
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Search bookings or routes',
                              filled: true,
                              fillColor: AppColors.cardLight,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Pick date range',
                          onPressed: _pickDateRange,
                          icon: Icon(Icons.date_range, color: AppColors.primary),
                        ),
                        if (_dateRange != null)
                          IconButton(
                            tooltip: 'Clear date filter',
                            onPressed: _clearDateRange,
                            icon: Icon(Icons.clear, color: AppColors.subtleLight),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Status chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _statuses.map((s) {
                          final active = s == _statusFilter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(s),
                              selected: active,
                              selectedColor: AppColors.primary.withOpacity(0.12),
                              backgroundColor: AppColors.cardLight,
                              onSelected: (_) => setState(() => _statusFilter = s),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Summary line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${results.length} bookings', style: TextStyle(color: AppColors.subtleLight)),
                        Row(children: [
                          TextButton.icon(
                            onPressed: results.isEmpty ? null : _exportCsvAll,
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Export (CSV)'),
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bookings list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              sliver: results.isEmpty
                  ? SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 6),
                      Icon(Icons.local_shipping, size: 48, color: AppColors.subtleLight),
                      const SizedBox(height: 12),
                      Text('No bookings found', style: TextStyle(color: AppColors.subtleLight)),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () {
                          // go to Find Trucks (pop with instruction)
                          Navigator.of(context).pop({'goTo': 'find_trucks'});
                        },
                        child: const Text('Find Trucks'),
                      ),
                    ],
                  ),
                ),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final b = results[index];
                    return Card(
                      color: AppColors.cardLight,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openBookingDetail(b),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          child: Row(
                            children: [
                              // Avatar / icon
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.local_shipping, size: 28, color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(b.route, style: const TextStyle(fontWeight: FontWeight.w600))),
                                      Text('₹${b.cost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(children: [
                                    Text(b.bookingId, style: TextStyle(color: AppColors.subtleLight)),
                                    const SizedBox(width: 10),
                                    Text('${b.bookedSpaceM3} m³', style: TextStyle(color: AppColors.subtleLight)),
                                  ]),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    _statusChip(b.status),
                                    const SizedBox(width: 8),
                                    Text(_formatShortDate(b.date), style: TextStyle(color: AppColors.subtleLight)),
                                  ])
                                ]),
                              ),
                              // Actions
                              PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'export') {
                                    _exportCsvSingle(b);
                                  } else if (v == 'rebook') {
                                    Navigator.of(context).pop({'rebookRoute': b.route, 'defaultSpace': b.bookedSpaceM3});
                                  } else if (v == 'markDelivered') {
                                    _updateBookingStatus(b, 'Delivered');
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(value: 'export', child: Text('Export CSV')),
                                  const PopupMenuItem(value: 'rebook', child: Text('Rebook')),
                                  if (b.status != 'Delivered') const PopupMenuItem(value: 'markDelivered', child: Text('Mark Delivered')),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: results.length,
                ),
              ),
            ),

            // padding to avoid FAB/BottomNav overlap
            SliverToBoxAdapter(child: SizedBox(height: 88)),
          ],
        ),
      ),
      // bottom navigation is optional here — keep app-wide nav in main scaffold
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // quick action: go to search / find trucks
          Navigator.of(context).pop({'goTo': 'find_trucks'});
        },
        backgroundColor: AppColors.primary,
        label: const Text('Find Trucks'),
        icon: const Icon(Icons.search),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color text;
    switch (status) {
      case 'Delivered':
        bg = Colors.green.shade100;
        text = Colors.green.shade800;
        break;
      case 'In Transit':
        bg = Colors.blue.shade100;
        text = Colors.blue.shade800;
        break;
      case 'Pending':
        bg = Colors.yellow.shade100;
        text = Colors.orange.shade800;
        break;
      case 'Cancelled':
        bg = Colors.red.shade50;
        text = Colors.red.shade700;
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade800;
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Text(status, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w600)));
  }

  String _formatShortDate(DateTime d) => '${d.day}-${d.month}-${d.year}';
}
