// lib/Modules/Logistics_s/DriverTrackingPage.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // add to pubspec if you want call/message
// If you plan to use Google Maps, add google_maps_flutter and replace the map placeholder with GoogleMap widget.

final Color kPrimary = const Color(0xFFEF4444);

class DriverTrackingPage extends StatefulWidget {
  const DriverTrackingPage({super.key});

  @override
  State<DriverTrackingPage> createState() => _DriverTrackingPageState();
}

class _DriverTrackingPageState extends State<DriverTrackingPage> {
  bool _loading = true;
  String? _error;
  List<DriverModel> _drivers = [];
  String _filter = 'all';
  String _search = '';
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
    // TODO: replace polling with WebSocket / Socket.io for realtime updates
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchDrivers(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDrivers({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final drivers = await DriverService.fetchDrivers(); // replace with real service
      setState(() => _drivers = drivers);
    } catch (e) {
      setState(() => _error = 'Failed to load drivers: $e');
    } finally {
      if (!silent) setState(() => _loading = false);
    }
  }

  void _openDriverDetails(DriverModel d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DriverDetailSheet(driver: d, onReassign: _onReassign),
    );
  }

  Future<void> _onReassign(DriverModel driver, String dispatchId) async {
    // Launch reassign flow — open assign modal (you already have AssignModal in Pending page)
    // Example: Navigator.push(... to assign page)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reassign requested to ${driver.name} for $dispatchId')));
  }

  List<DriverModel> get _filteredDrivers {
    var list = _drivers;
    if (_filter == 'online') list = list.where((d) => d.status == DriverStatus.online).toList();
    if (_filter == 'busy') list = list.where((d) => d.status == DriverStatus.onTrip).toList();
    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((d) => d.name.toLowerCase().contains(q) || d.id.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Tracking', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // search + filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search driver name or ID',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Filter drivers',
                  icon: const Icon(Icons.filter_list),
                  onSelected: (v) => setState(() => _filter = v),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'all', child: Text('All')),
                    const PopupMenuItem(value: 'online', child: Text('Online')),
                    const PopupMenuItem(value: 'busy', child: Text('On Trip')),
                    const PopupMenuItem(value: 'offline', child: Text('Offline')),
                  ],
                )
              ]),
            ),

            // map area (fixed aspect; replace with GoogleMap or Mapbox)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                    children: [
                      // Replace below Container with GoogleMap widget, using driver lat/lng to show markers.
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
                        child: const Center(child: Text('Map placeholder — integrate GoogleMap / Mapbox')),
                      ),
                      // small overlay: legend + center
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                // center map logic
                              },
                              icon: const Icon(Icons.my_location_rounded, size: 16),
                              label: const Text('Center'),
                              style: ElevatedButton.styleFrom(backgroundColor: kPrimary, elevation: 2, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [
                                _LegendDot(label: 'On trip', color: Colors.green),
                                _LegendDot(label: 'Idle', color: Colors.orange),
                                _LegendDot(label: 'Offline', color: Colors.grey),
                              ]),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // drivers list header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                Text('${_filteredDrivers.length} drivers', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  onPressed: _fetchDrivers,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh drivers',
                )
              ]),
            ),

            const SizedBox(height: 8),

            // drivers list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                  : _filteredDrivers.isEmpty
                  ? Center(child: Text('No drivers found', style: GoogleFonts.inter()))
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _filteredDrivers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final d = _filteredDrivers[i];
                  return _DriverRow(driver: d, onTap: () => _openDriverDetails(d));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// ---------------- Driver Row ----------------
class _DriverRow extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback onTap;
  const _DriverRow({required this.driver, required this.onTap});

  Color get statusColor {
    switch (driver.status) {
      case DriverStatus.online:
        return Colors.green;
      case DriverStatus.onTrip:
        return Colors.orange;
      case DriverStatus.offline:
      default:
        return Colors.grey;
    }
  }

  String get statusLabel {
    switch (driver.status) {
      case DriverStatus.online:
        return 'Online';
      case DriverStatus.onTrip:
        return 'On Trip';
      case DriverStatus.offline:
      default:
        return 'Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade100)),
          child: Row(children: [
            CircleAvatar(radius: 26, backgroundColor: Colors.grey.shade100, child: Text(driver.name[0], style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(driver.name, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${driver.vehicle} • ${driver.rating.toStringAsFixed(1)} ★', style: TextStyle(color: Colors.grey.shade700)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 6),
                Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              Text('${driver.speed} km/h', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ])
          ]),
        ),
      ),
    );
  }
}

/// ---------------- Driver Detail Bottom Sheet ----------------
class DriverDetailSheet extends StatelessWidget {
  final DriverModel driver;
  final Future<void> Function(DriverModel driver, String dispatchId) onReassign;

  const DriverDetailSheet({required this.driver, required this.onReassign, super.key});

  Future<void> _callDriver(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _messageDriver(String phone) async {
    final uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(children: [
            Container(height: 6, width: 60, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3))),
            Row(children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.grey.shade100, child: Text(driver.name[0], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Text(driver.name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800))),
              Text('${driver.rating.toStringAsFixed(1)} ★', style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Vehicle', style: TextStyle(color: Colors.grey.shade600)), const SizedBox(height: 6), Text(driver.vehicle, style: GoogleFonts.inter(fontWeight: FontWeight.w700))]),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Last seen', style: TextStyle(color: Colors.grey.shade600)), const SizedBox(height: 6), Text(driver.lastSeen, style: GoogleFonts.inter(fontWeight: FontWeight.w700))]),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            // action buttons
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _callDriver(driver.phone),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _messageDriver(driver.phone),
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Message'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            // current assignments preview (mock)
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(leading: const Icon(Icons.local_shipping_rounded), title: Text('Active: SPG-1012'), subtitle: Text('ETA 12m')),
                  ListTile(leading: const Icon(Icons.history), title: Text('Completed: 18'), subtitle: Text('Today')),
                ],
              ),
            ),
            // reassign (quick) example
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      // prompt for dispatch id to reassign (quick demo)
                      final idController = TextEditingController();
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reassign Dispatch'),
                          content: TextField(controller: idController, decoration: const InputDecoration(hintText: 'Enter dispatch id e.g. SPG-101')),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Reassign')),
                          ],
                        ),
                      );
                      if (ok == true && idController.text.isNotEmpty) {
                        await onReassign(driver, idController.text.trim());
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Quick Reassign'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // open full profile or navigation to driver detail screen
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                    child: const Text('Open Profile'),
                  ),
                ),
              ]),
            )
          ]),
        ),
      ),
    );
  }
}

/// ---------- small legend item ----------
class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      const SizedBox(height: 6),
    ]);
  }
}

/// ---------------- Data models & service stubs ----------------
/// Replace with real API + websocket integration.

enum DriverStatus { online, onTrip, offline }

class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String vehicle;
  final double rating;
  final DriverStatus status;
  final double lat;
  final double lng;
  final double speed;
  final String lastSeen;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.rating,
    required this.status,
    required this.lat,
    required this.lng,
    required this.speed,
    required this.lastSeen,
  });
}

class DriverService {
  // simulate network fetch
  static Future<List<DriverModel>> fetchDrivers() async {
    await Future.delayed(const Duration(milliseconds: 450));
    return [
      DriverModel(id: 'D-101', name: 'Alex', phone: '+911234567890', vehicle: 'Bike • KA-01-AB1234', rating: 4.8, status: DriverStatus.onTrip, lat: 12.9716, lng: 77.5946, speed: 32.0, lastSeen: '2m'),
      DriverModel(id: 'D-102', name: 'Mei', phone: '+911234567891', vehicle: 'Van • KA-01-VC4321', rating: 4.6, status: DriverStatus.online, lat: 12.9721, lng: 77.5950, speed: 0.0, lastSeen: '1m'),
      DriverModel(id: 'D-103', name: 'Ravi', phone: '+911234567892', vehicle: 'Bike • KA-01-XZ9876', rating: 4.9, status: DriverStatus.offline, lat: 12.9730, lng: 77.5960, speed: 0.0, lastSeen: '40m'),
    ];
  }
}
