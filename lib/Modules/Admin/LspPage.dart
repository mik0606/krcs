// lib/Modules/Admin/LspManagementPage.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LspManagementPage extends StatefulWidget {
  const LspManagementPage({super.key});

  @override
  State<LspManagementPage> createState() => _LspManagementPageState();
}

class _LspManagementPageState extends State<LspManagementPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _activeFilter = 'All';
  int _selectedNavIndex = 1; // LSPs tab active by default

  // Sample data (replace with your backend)
  List<LspItem> _items = [
    LspItem(name: 'Swift Logistics', fleet: 50, route: 'Metro', active: 12, status: LspStatus.approved, registered: '2023-11-15'),
    LspItem(name: 'Rapid Delivery', fleet: 30, route: 'Suburban', active: 5, status: LspStatus.pending, registered: '2023-11-20'),
    LspItem(name: 'Express Couriers', fleet: 20, route: 'Regional', active: 8, status: LspStatus.suspended, registered: '2023-10-02'),
    LspItem(name: 'Quick Ship', fleet: 40, route: 'Metro', active: 25, status: LspStatus.approved, registered: '2023-09-01'),
    LspItem(name: 'Speedy Transport', fleet: 15, route: 'Suburban', active: 3, status: LspStatus.approved, registered: '2023-07-12'),
  ];

  List<String> get _filters => ['All', 'Approved', 'Pending', 'Suspended'];

  List<LspItem> get _filteredItems {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _items.where((i) {
      if (_activeFilter != 'All') {
        final matchFilter = (_activeFilter == 'Approved' && i.status == LspStatus.approved) ||
            (_activeFilter == 'Pending' && i.status == LspStatus.pending) ||
            (_activeFilter == 'Suspended' && i.status == LspStatus.suspended);
        if (!matchFilter) return false;
      }
      if (q.isEmpty) return true;
      return i.name.toLowerCase().contains(q) ||
          i.route.toLowerCase().contains(q) ||
          i.registered.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmApprove(int idx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Approve LSP'),
        content: Text('Approve ${_filteredItems[idx].name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Approve')),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        final target = _filteredItems[idx];
        final originalIndex = _items.indexWhere((e) => e.id == target.id);
        if (originalIndex != -1) _items[originalIndex] = _items[originalIndex].copyWith(status: LspStatus.approved);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Approved')));
    }
  }

  Future<void> _confirmSuspend(int idx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Suspend LSP'),
        content: Text('Suspend ${_filteredItems[idx].name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Suspend'),),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        final target = _filteredItems[idx];
        final originalIndex = _items.indexWhere((e) => e.id == target.id);
        if (originalIndex != -1) _items[originalIndex] = _items[originalIndex].copyWith(status: LspStatus.suspended);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Suspended')));
    }
  }

  void _viewDetails(LspItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.78,
          child: _LspDetailSheet(item: item),
        ),
      ),
    );
  }

  void _onNavTap(int idx) {
    setState(() => _selectedNavIndex = idx);
    // In a real app you'd navigate or change the page; for now, show toast
    const labels = ['Dashboard', 'LSPs', 'Merchants', 'Drivers', 'Settings'];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open: ${labels[idx]}')));
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFFEF4343);
    final bgLight = const Color(0xFFF8F6F6);
    final bgDark = const Color(0xFF221010);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? bgDark : Colors.white,
        elevation: 1,
        title: Text('LSP Management', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: isDark ? Colors.white : Colors.black87,
            tooltip: 'Global Search',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search area + filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(children: [
              TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search LSPs by name, route...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final label = _filters[i];
                    final active = _activeFilter == label;
                    return ChoiceChip(
                      label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      selected: active,
                      selectedColor: primary.withOpacity(0.12),
                      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
                      onSelected: (_) => setState(() => _activeFilter = label),
                    );
                  },
                ),
              ),
            ]),
          ),

          // List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _filteredItems.isEmpty
                  ? Center(child: Text('No LSPs found', style: GoogleFonts.inter(color: Colors.grey)))
                  : ListView.separated(
                padding: const EdgeInsets.only(bottom: 100, top: 8),
                itemCount: _filteredItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, idx) {
                  final item = _filteredItems[idx];
                  return _LspCard(
                    item: item,
                    onView: () => _viewDetails(item),
                    onApprove: () => _confirmApprove(idx),
                    onSuspend: () => _confirmSuspend(idx),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // Sticky bottom nav (mimics HTML)

    );
  }
}

/// ======================= Widgets & Models =======================

enum LspStatus { approved, pending, suspended }

class LspItem {
  final String id;
  final String name;
  final int fleet;
  final String route;
  final int active;
  final LspStatus status;
  final String registered;

  LspItem({
    String? id,
    required this.name,
    required this.fleet,
    required this.route,
    required this.active,
    required this.status,
    required this.registered,
  }) : id = id ?? UniqueKey().toString();

  LspItem copyWith({LspStatus? status}) {
    return LspItem(
      id: id,
      name: name,
      fleet: fleet,
      route: route,
      active: active,
      status: status ?? this.status,
      registered: registered,
    );
  }
}

class _LspCard extends StatelessWidget {
  final LspItem item;
  final VoidCallback onView;
  final VoidCallback onApprove;
  final VoidCallback onSuspend;
  const _LspCard({required this.item, required this.onView, required this.onApprove, required this.onSuspend});

  Color get _statusColor {
    switch (item.status) {
      case LspStatus.approved:
        return Colors.green;
      case LspStatus.pending:
        return Colors.orange;
      case LspStatus.suspended:
        return Colors.red;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case LspStatus.approved:
        return 'Approved';
      case LspStatus.pending:
        return 'Pending';
      case LspStatus.suspended:
        return 'Suspended';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.grey[850] : Colors.white;

    return Card(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Fleet: ${item.fleet} | Route: ${item.route} | ${item.active} Active', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: _statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
              child: Text(_statusLabel, style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: onView,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('View Details', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onApprove,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Approve'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onSuspend,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Suspend'),
            ),
          ])
        ]),
      ),
    );
  }
}

class _LspDetailSheet extends StatelessWidget {
  final LspItem item;
  const _LspDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(height: 6, width: 60, margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6))),
          ),
          Text(item.name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Registered: ${item.registered}', style: GoogleFonts.inter(color: Colors.grey)),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: isDark ? Colors.grey[900] : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Overview', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Fleet size: ${item.fleet}', style: GoogleFonts.inter()),
                const SizedBox(height: 4),
                Text('Route type: ${item.route}', style: GoogleFonts.inter()),
                const SizedBox(height: 4),
                Text('Active drivers: ${item.active}', style: GoogleFonts.inter()),
                const SizedBox(height: 8),
                Text('Status: ${item.status.name.toUpperCase()}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: item.status == LspStatus.approved ? Colors.green : item.status == LspStatus.pending ? Colors.orange : Colors.red)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                ListTile(leading: const Icon(Icons.map_rounded), title: const Text('Service Areas'), subtitle: const Text('Metro, Suburban')),
                ListTile(leading: const Icon(Icons.person_rounded), title: const Text('Primary Contact'), subtitle: const Text('Priya | +91 90000 000')),
                ListTile(leading: const Icon(Icons.document_scanner_rounded), title: const Text('Documents'), subtitle: const Text('License, GST, Insurance')),
                ListTile(leading: const Icon(Icons.history_rounded), title: const Text('Activity Log'), subtitle: const Text('View recent events')),
              ],
            ),
          ),
          Row(children: [
            Expanded(
              child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // navigate to full management screen (placeholder)
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Open Management'),
              ),
            )
          ])
        ]),
      ),
    );
  }
}
