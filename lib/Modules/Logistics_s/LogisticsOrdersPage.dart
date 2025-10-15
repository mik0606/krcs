// lib/Modules/Logistics_s/PendingDispatchesPage.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pending Dispatches Page
/// - Lists pending dispatch orders
/// - Supports Preview and Assign
/// - Assign opens a modal that fetches candidate drivers and allows assignment
///
/// Replace the DispatchService implementation with real API calls to your backend.

final Color kPrimary = const Color(0xFFEF4444);

class PendingDispatchesPage extends StatefulWidget {
  const PendingDispatchesPage({super.key});

  @override
  State<PendingDispatchesPage> createState() => _PendingDispatchesPageState();
}

class _PendingDispatchesPageState extends State<PendingDispatchesPage> {
  bool _loading = true;
  String? _error;
  List<DispatchItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await DispatchService.fetchPendingDispatches();
      setState(() {
        _items = items;
      });
    } catch (e) {
      setState(() => _error = "Failed to load dispatches: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _onAssign(DispatchItem item) async {
    // Open modal and handle assignment inside it
    final result = await showModalBottomSheet<_AssignResult?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => AssignModal(dispatch: item),
    );

    if (result != null && result.assigned) {
      // optimistic update: remove item from list (it became assigned)
      setState(() => _items.removeWhere((i) => i.id == item.id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order assigned successfully')));
    }
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!, style: TextStyle(color: Colors.red[700])),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _load, style: ElevatedButton.styleFrom(backgroundColor: kPrimary), child: const Text('Retry'))
        ]),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
          const SizedBox(height: 12),
          Text('No pending dispatches', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('You are caught up. New orders will appear here.', style: TextStyle(color: Colors.grey[700])),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final d = _items[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                  child: Text(d.id, style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${d.pickup} → ${d.drop}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(d.priority.toUpperCase(), style: TextStyle(color: d.priority == 'high' ? Colors.red : Colors.orange, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(d.eta, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ]),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                TextButton.icon(
                  onPressed: () => _preview(d),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Preview'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _onAssign(d),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  child: const Text('Assign'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _runAutoAssignFor(d),
                  child: const Text('Auto-Assign'),
                )
              ])
            ]),
          ),
        );
      },
    );
  }

  void _preview(DispatchItem d) {
    // Simple preview modal — extend as needed
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Preview ${d.id}'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pickup: ${d.pickup}'),
          const SizedBox(height: 6),
          Text('Drop: ${d.drop}'),
          const SizedBox(height: 6),
          Text('Type: ${d.type}'),
          const SizedBox(height: 6),
          Text('Size: ${d.size}'),
        ]),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _runAutoAssignFor(DispatchItem item) async {
    final sb = ScaffoldMessenger.of(context);
    sb.showSnackBar(const SnackBar(content: Text('Running auto-assign...')));
    try {
      final assignedDriver = await DispatchService.autoAssign(item.id);
      sb.hideCurrentSnackBar();
      if (assignedDriver != null) {
        setState(() => _items.removeWhere((i) => i.id == item.id));
        sb.showSnackBar(SnackBar(content: Text('Auto-assigned to ${assignedDriver.name}')));
      } else {
        sb.showSnackBar(const SnackBar(content: Text('Auto-assign did not find a suitable driver')));
      }
    } catch (e) {
      sb.showSnackBar(SnackBar(content: Text('Auto-assign failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Dispatches', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: RefreshIndicator(onRefresh: _load, child: SafeArea(child: _buildBody())),
    );
  }
}

/// Assign modal returns _AssignResult when assignment occurs
class AssignModal extends StatefulWidget {
  final DispatchItem dispatch;
  const AssignModal({required this.dispatch, super.key});

  @override
  State<AssignModal> createState() => _AssignModalState();
}

class _AssignModalState extends State<AssignModal> {
  bool _loading = true;
  String? _error;
  List<DriverCandidate> _candidates = [];
  DriverCandidate? _selected;
  bool _assigning = false;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final c = await DispatchService.fetchCandidateDrivers(widget.dispatch.id);
      setState(() {
        _candidates = c;
        if (c.isNotEmpty) _selected = c.first;
      });
    } catch (e) {
      setState(() => _error = 'Failed to load drivers: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmAssign() async {
    if (_selected == null) return;
    setState(() => _assigning = true);
    try {
      await DispatchService.assignDriver(widget.dispatch.id, _selected!.id);
      Navigator.of(context).pop(_AssignResult(assigned: true, driver: _selected));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assign failed: $e')));
    } finally {
      setState(() => _assigning = false);
    }
  }

  Future<void> _autoAssign() async {
    setState(() => _assigning = true);
    try {
      final driver = await DispatchService.autoAssign(widget.dispatch.id);
      if (driver != null) {
        Navigator.of(context).pop(_AssignResult(assigned: true, driver: DriverCandidate(id: driver.id, name: driver.name, etaMinutes: driver.etaMinutes, load: driver.load)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No candidate found for auto-assign')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auto-assign failed: $e')));
    } finally {
      setState(() => _assigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.78,
          child: Column(
            children: [
              Container(height: 6, width: 60, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Expanded(child: Text('Assign ${widget.dispatch.id}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700))),
                  TextButton(onPressed: _autoAssign, child: const Text('Auto-Assign'))
                ]),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text(_error!, style: TextStyle(color: Colors.red[700])))
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _candidates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final c = _candidates[i];
                    final selected = _selected?.id == c.id;
                    return ListTile(
                      tileColor: selected ? Colors.grey.shade100 : null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      leading: CircleAvatar(child: Text(c.name[0]), backgroundColor: Colors.grey[200]),
                      title: Text(c.name, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      subtitle: Text('${c.etaMinutes} min • load: ${c.load}'),
                      trailing: Radio<String>(
                        value: c.id,
                        groupValue: _selected?.id,
                        onChanged: (v) {
                          setState(() {
                            _selected = _candidates.firstWhere((x) => x.id == v);
                          });
                        },
                      ),
                      onTap: () => setState(() => _selected = c),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _assigning ? null : () => Navigator.of(context).pop(null),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _assigning ? null : _confirmAssign,
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                      child: _assigning ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirm Assign'),
                    ),
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Lightweight result model returned by the modal
class _AssignResult {
  final bool assigned;
  final DriverCandidate? driver;
  _AssignResult({required this.assigned, this.driver});
}

/// -----------------------------
/// Data models & service stubs
/// Replace these with real API implementations
/// -----------------------------

class DispatchItem {
  final String id;
  final String title;
  final String pickup;
  final String drop;
  final String type;
  final String size;
  final String eta;
  final String priority;

  DispatchItem({required this.id, required this.title, required this.pickup, required this.drop, required this.type, required this.size, required this.eta, required this.priority});
}

class DriverCandidate {
  final String id;
  final String name;
  final int etaMinutes;
  final int load; // number of active orders

  DriverCandidate({required this.id, required this.name, required this.etaMinutes, required this.load});
}

/// Minimal DriverUsed for autoAssign return
class DriverUsed {
  final String id;
  final String name;
  final int etaMinutes;
  final int load;
  DriverUsed({required this.id, required this.name, required this.etaMinutes, required this.load});
}

/// Service stub: replace methods with actual HTTP calls (use ApiConstants and AuthService)
class DispatchService {
  // Simulate network latency
  static Future<List<DispatchItem>> fetchPendingDispatches() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // mocked data
    return [
      DispatchItem(id: 'SPG-101', title: 'Parcel pickup', pickup: 'Warehouse A', drop: 'Merchant B', type: 'Parcel', size: 'Small', eta: '24-32m', priority: 'normal'),
      DispatchItem(id: 'SPG-102', title: 'Grocery pickup', pickup: 'Hub West', drop: 'Customer X', type: 'Grocery', size: 'Medium', eta: '12-20m', priority: 'high'),
      DispatchItem(id: 'SPG-103', title: 'Return pickup', pickup: 'Merchant C', drop: 'Warehouse B', type: 'Return', size: 'Large', eta: '40-55m', priority: 'normal'),
    ];
  }

  // Simulate fetching candidate drivers for the given dispatch
  static Future<List<DriverCandidate>> fetchCandidateDrivers(String dispatchId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      DriverCandidate(id: 'D-101', name: 'Alex', etaMinutes: 12, load: 1),
      DriverCandidate(id: 'D-104', name: 'Mei', etaMinutes: 16, load: 2),
      DriverCandidate(id: 'D-111', name: 'Ravi', etaMinutes: 20, load: 0),
    ];
  }

  // Simulate assigning a driver
  static Future<void> assignDriver(String dispatchId, String driverId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    // throw Exception('simulated failure'); // uncomment to test error flows
    return;
  }

  // Simulate auto-assign — returns chosen driver or null
  static Future<DriverUsed?> autoAssign(String dispatchId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // choose a mock driver
    return DriverUsed(id: 'D-111', name: 'Ravi', etaMinutes: 14, load: 0);
  }
}
