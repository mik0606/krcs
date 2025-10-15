// lib/Modules/Admin/AdminDashboardPage.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pixel-perfect Admin Dashboard (Flutter)
/// - Responsive: adapts columns based on width
/// - KPI cards, Recent Activities, Pending Approvals
/// - Bottom nav bar with 5 items
/// - Approve / Reject buttons with confirmation and Snackbars
///
/// Add this file to your project and navigate to AdminDashboardPage() from your Root.

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // sample data (replace with real API)
  int totalLSPs = 120;
  int totalMerchants = 350;
  int activeDrivers = 280;
  int pendingVerifications = 15;

  final List<Map<String, String>> recentActivities = [
    {"title": "Logistics Pro Inc.", "subtitle": "New Sign-up · LSP", "status": "ok"},
    {"title": "Retail Hub", "subtitle": "Verification · Merchant", "status": "ok"},
    {"title": "Fast Track Delivery", "subtitle": "New Booking · Driver", "status": "ok"},
  ];

  final List<Map<String, String>> pendingApprovals = [
    {"name": "Swift Logistics", "type": "LSP", "date": "2023-11-15"},
    {"name": "Global Goods", "type": "Merchant", "date": "2023-11-10"},
  ];

  int _selectedIndex = 0;

  // Confirm approve
  Future<void> _confirmApprove(int idx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Approve'),
        content: Text('Approve ${pendingApprovals[idx]['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Approve')),
        ],
      ),
    );

    if (ok == true) {
      // simulate backend call
      setState(() {
        pendingApprovals.removeAt(idx);
        pendingVerifications = (pendingVerifications - 1).clamp(0, 9999);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Approved successfully')));
    }
  }

  // Confirm reject
  Future<void> _confirmReject(int idx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reject'),
        content: Text('Reject ${pendingApprovals[idx]['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Reject')),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        pendingApprovals.removeAt(idx);
        pendingVerifications = (pendingVerifications - 1).clamp(0, 9999);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected')));
    }
  }

  // Bottom nav handler (sample)
  void _onBottomNavTap(int idx) {
    setState(() => _selectedIndex = idx);
    // navigate or change content based on index; for now show snackbar
    const labels = ['Dashboard', 'LSPs', 'Merchants', 'Drivers', 'Reports'];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open: ${labels[idx]}')));
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFFEF4343);
    final backgroundLight = const Color(0xFFF8F6F6);
    final backgroundDark = const Color(0xFF221010);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? backgroundDark : backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? backgroundDark : Colors.white,
        elevation: 1,
        title: Text('Dashboard', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
        leading: IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black87),
          onPressed: () {}, // open drawer
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        // responsive breakpoints
        final width = constraints.maxWidth;
        final isWide = width >= 900;
        final kPadding = EdgeInsets.symmetric(horizontal: isWide ? 28 : 16, vertical: 16);

        return SingleChildScrollView(
          padding: kPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI grid (2 columns on mobile, 4 on wide)
              _buildKpiGrid(isWide, primary, isDark),
              const SizedBox(height: 20),

              // Recent Activities + Pending Approvals side-by-side on wide screens
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildRecentActivitiesCard(isDark)),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: _buildPendingApprovalsCard(primary, isDark)),
                  ],
                )
              else ...[
                _buildRecentActivitiesCard(isDark),
                const SizedBox(height: 16),
                _buildPendingApprovalsCard(primary, isDark),
              ],

              const SizedBox(height: 24),
              // You can add more sections below (charts, lists, reports)
            ],
          ),
        );
      }),

    );
  }

  Widget _buildKpiGrid(bool isWide, Color primary, bool isDark) {
    final cardBg = isDark ? Colors.black.withOpacity(0.2) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final muted = isDark ? Colors.white70 : Colors.grey[600];

    final kpis = [
      {'label': 'Total LSPs', 'value': totalLSPs.toString(), 'bg': cardBg},
      {'label': 'Total Merchants', 'value': totalMerchants.toString(), 'bg': cardBg},
      {'label': 'Active Drivers', 'value': activeDrivers.toString(), 'bg': cardBg},
      {'label': 'Pending Verifications', 'value': pendingVerifications.toString(), 'bg': Colors.red.withOpacity(0.08)},
    ];

    // Use Wrap to avoid unbounded GridView inside Column
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: kpis.map((k) {
        final bool highlight = k['label'] == 'Pending Verifications';
        final width = isWide ? 260.0 : (MediaQuery.of(context).size.width - 48) / 2;
        return SizedBox(
          width: width,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: k['bg'] as Color, borderRadius: BorderRadius.circular(12), boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2)),
            ]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('label', style: GoogleFonts.inter(fontSize: 13, color: muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('value', style: GoogleFonts.inter(fontSize: 22, color: highlight ? Colors.red : textColor, fontWeight: FontWeight.w800)),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivitiesCard(bool isDark) {
    final bg = isDark ? Colors.black.withOpacity(0.18) : Colors.white;
    final divider = isDark ? Colors.grey[700] : Colors.grey[200];

    return Card(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          // header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text('Recent Activities', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                const Spacer(),
                // optional filter or link
                TextButton(onPressed: () {}, child: Text('View all', style: GoogleFonts.inter(color: Colors.grey)))
              ],
            ),
          ),
          const Divider(height: 1),
          // list
          Column(
            children: recentActivities.mapIndexed((i, item) {
              return Column(children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  title: Text(item['title']!, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text(item['subtitle']!, style: GoogleFonts.inter(color: isDark ? Colors.white70 : Colors.grey[600], fontSize: 13)),
                  trailing: Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8))),
                ),
                if (i != recentActivities.length - 1) Divider(height: 1, color: divider),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsCard(Color primary, bool isDark) {
    final bg = isDark ? Colors.black.withOpacity(0.18) : Colors.white;
    final divider = isDark ? Colors.grey[700] : Colors.grey[200];

    return Card(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(children: [
            Text('Pending Approvals', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
            const Spacer(),
            if (pendingApprovals.isNotEmpty) Text('${pendingApprovals.length} items', style: GoogleFonts.inter(color: Colors.grey))
          ])),
          const Divider(height: 1),
          Column(
            children: pendingApprovals.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item['name']!, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 6),
                    Text('Registered: ${item['date']} · ${item['type']}', style: GoogleFonts.inter(color: Colors.grey[600])),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _confirmApprove(idx),
                          style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmReject(idx),
                          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: Text('Reject', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                        ),
                      )
                    ])
                  ]),
                ),
                if (idx != pendingApprovals.length - 1) Divider(height: 1, color: divider),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }


}

/// --------------------- Helpers ---------------------
/// small extension to get index in map iteration without package
extension IterableIndexed<E> on Iterable<E> {
  List<T> mapIndexed<T>(T Function(int index, E item) f) {
    var i = 0;
    final out = <T>[];
    for (final e in this) {
      out.add(f(i++, e));
    }
    return out;
  }
}

/// I added a convenience to iterate with index:
extension _ListIterator<E> on List<E> {
  List<T> mapIndexed<T>(T Function(int i, E e) fn) => asMap().entries.map((e) => fn(e.key, e.value)).toList();
}

/// small helper to call mapIndexed easily on List
extension MapIndexedOnList<E> on List<E> {
  List<T> mapIndexed2<T>(T Function(int idx, E item) fn) {
    final out = <T>[];
    for (var i = 0; i < length; i++) out.add(fn(i, this[i]));
    return out;
  }
}
