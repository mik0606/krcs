// lib/Modules/Admin/MerchantManagementPage.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Merchant Management Page
/// - Tabs: All / Pending / Suspended
/// - Search, filter chips, merchant cards with actions
/// - View details bottom sheet
/// - Sticky bottom navigation bar
class MerchantManagementPage extends StatefulWidget {
  const MerchantManagementPage({super.key});

  @override
  State<MerchantManagementPage> createState() => _MerchantManagementPageState();
}

class _MerchantManagementPageState extends State<MerchantManagementPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _activeTab = 'All';
  int _navIndex = 2; // Merchants tab active
  final List<String> _tabs = ['All', 'Pending', 'Suspended'];

  // sample data — replace with real API
  final List<MerchantItem> _data = [
    MerchantItem(
      name: 'Tech Solutions Inc.',
      contact: 'Alex Turner',
      email: 'alex@techsolutions.com',
      registered: 'Jan 15, 2023',
      status: MerchantStatus.verified,
      logoUrl: null,
    ),
    MerchantItem(
      name: 'Global Retail Group',
      contact: 'Sarah Chen',
      email: 'sarah.c@globalretail.com',
      registered: 'Feb 02, 2023',
      status: MerchantStatus.pending,
      logoUrl: null,
    ),
    MerchantItem(
      name: 'Innovative Designs Ltd.',
      contact: 'David Lee',
      email: 'david.lee@innovate.design',
      registered: 'Mar 21, 2023',
      status: MerchantStatus.suspended,
      logoUrl: null,
    ),
  ];

  List<MerchantItem> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _data.where((m) {
      if (_activeTab == 'Pending' && m.status != MerchantStatus.pending) return false;
      if (_activeTab == 'Suspended' && m.status != MerchantStatus.suspended) return false;
      if (_activeTab == 'All' || true) {
        if (q.isEmpty) return true;
        return m.name.toLowerCase().contains(q) ||
            m.contact.toLowerCase().contains(q) ||
            m.email.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmAction({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    Color confirmColor = Colors.red,
    String confirmLabel = 'Confirm',
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(c).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    if (ok == true) onConfirm();
  }

  void _viewDetails(MerchantItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.82,
        child: MerchantDetailSheet(item: item),
      ),
    );
  }

  void _verifyMerchant(int idx) {
    setState(() {
      final m = _filtered[idx];
      final originalIndex = _data.indexWhere((e) => e.id == m.id);
      if (originalIndex != -1) _data[originalIndex] = _data[originalIndex].copyWith(status: MerchantStatus.verified);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Merchant verified')));
  }

  void _suspendMerchant(int idx) {
    setState(() {
      final m = _filtered[idx];
      final originalIndex = _data.indexWhere((e) => e.id == m.id);
      if (originalIndex != -1) _data[originalIndex] = _data[originalIndex].copyWith(status: MerchantStatus.suspended);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Merchant suspended')));
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFFEF4444);
    final bgLight = const Color(0xFFF9FAFB);
    final bgDark = const Color(0xFF1F2937);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? bgDark : Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text('Merchants', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // add merchant action
            },
            color: isDark ? Colors.white : primary,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab nav
          Container(
            color: isDark ? bgDark : Colors.white,
            child: Row(
              children: _tabs.map((t) {
                final active = t == _activeTab;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: active
                          ? BoxDecoration(
                        border: Border(bottom: BorderSide(width: 3, color: primary)),
                        color: isDark ? bgDark : Colors.white,
                      )
                          : null,
                      child: Center(
                        child: Text(
                          t == 'All' ? 'All Merchants' : t,
                          style: GoogleFonts.inter(
                            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                            color: active ? primary : (isDark ? Colors.white70 : Colors.grey[700]),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Search & chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(children: [
              TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search merchants, owner or email...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ]),
          ),

          // Merchant list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _filtered.isEmpty
                  ? Center(child: Text('No merchants found', style: GoogleFonts.inter(color: Colors.grey)))
                  : ListView.separated(
                padding: const EdgeInsets.only(bottom: 90, top: 8),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, idx) {
                  final m = _filtered[idx];
                  return MerchantCard(
                    item: m,
                    onView: () => _viewDetails(m),
                    onVerify: () => _confirmAction(
                      title: 'Verify Merchant',
                      message: 'Verify ${m.name}?',
                      confirmColor: primary,
                      confirmLabel: 'Verify',
                      onConfirm: () => _verifyMerchant(idx),
                    ),
                    onSuspend: () => _confirmAction(
                      title: 'Suspend Merchant',
                      message: 'Suspend ${m.name}?',
                      confirmColor: Colors.red,
                      confirmLabel: 'Suspend',
                      onConfirm: () => _suspendMerchant(idx),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

    );
  }
}

/// Merchant card widget
class MerchantCard extends StatelessWidget {
  final MerchantItem item;
  final VoidCallback onView;
  final VoidCallback onVerify;
  final VoidCallback onSuspend;
  const MerchantCard({required this.item, required this.onView, required this.onVerify, required this.onSuspend, super.key});

  Color _statusColor(MerchantStatus s) {
    switch (s) {
      case MerchantStatus.verified:
        return Colors.green;
      case MerchantStatus.pending:
        return Colors.orange;
      case MerchantStatus.suspended:
        return Colors.red;
    }
  }

  String _statusLabel(MerchantStatus s) {
    switch (s) {
      case MerchantStatus.verified:
        return 'Verified';
      case MerchantStatus.pending:
        return 'Pending';
      case MerchantStatus.suspended:
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
            // logo or placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10), image: item.logoUrl != null ? DecorationImage(image: NetworkImage(item.logoUrl!), fit: BoxFit.cover) : null),
              child: item.logoUrl == null ? Center(child: Text(item.name[0], style: GoogleFonts.inter(fontWeight: FontWeight.w700))) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(item.contact, style: GoogleFonts.inter(color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(item.email, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: _statusColor(item.status).withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
              child: Text(_statusLabel(item.status), style: TextStyle(color: _statusColor(item.status), fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 12),
          Divider(height: 1),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: onView,
              child: Text('View', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onSuspend,
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(item.status == MerchantStatus.suspended ? 'Unsuspend' : 'Suspend'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onVerify,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Verify'),
            ),
          ])
        ]),
      ),
    );
  }
}

/// Merchant detail bottom sheet
class MerchantDetailSheet extends StatelessWidget {
  final MerchantItem item;
  const MerchantDetailSheet({required this.item, super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(height: 6, width: 60, margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)))),
          Row(children: [
            Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12))),
            const SizedBox(width: 12),
            Expanded(child: Text(item.name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _statusColor(item.status).withOpacity(0.12), borderRadius: BorderRadius.circular(999)), child: Text(item.status.name.toUpperCase(), style: TextStyle(color: _statusColor(item.status), fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 12),
          Text('Owner: ${item.contact}', style: GoogleFonts.inter()),
          const SizedBox(height: 4),
          Text('Email: ${item.email}', style: GoogleFonts.inter()),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: isDark ? Colors.grey[900] : Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Overview', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Registered: ${item.registered}', style: GoogleFonts.inter(color: Colors.grey)),
                const SizedBox(height: 6),
                Text('Documents: License, GST, Bank Verification', style: GoogleFonts.inter()),
                const SizedBox(height: 6),
                Text('Service areas: Local city, Suburban', style: GoogleFonts.inter()),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(children: [
              ListTile(leading: const Icon(Icons.document_scanner_outlined), title: const Text('Documents'), subtitle: const Text('View uploaded documents')),
              ListTile(leading: const Icon(Icons.history), title: const Text('Activity Log'), subtitle: const Text('Recent events and updates')),
              ListTile(leading: const Icon(Icons.note), title: const Text('Notes'), subtitle: const Text('Moderator notes and comments')),
            ]),
          ),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Open Management'))),
          ])
        ]),
      ),
    );
  }

  Color _statusColor(MerchantStatus s) {
    switch (s) {
      case MerchantStatus.verified:
        return Colors.green;
      case MerchantStatus.pending:
        return Colors.orange;
      case MerchantStatus.suspended:
        return Colors.red;
    }
  }
}

/// Model & enums
enum MerchantStatus { verified, pending, suspended }

class MerchantItem {
  final String id;
  final String name;
  final String contact;
  final String email;
  final String registered;
  final MerchantStatus status;
  final String? logoUrl;

  MerchantItem({
    String? id,
    required this.name,
    required this.contact,
    required this.email,
    required this.registered,
    required this.status,
    this.logoUrl,
  }) : id = id ?? UniqueKey().toString();

  MerchantItem copyWith({MerchantStatus? status}) {
    return MerchantItem(
      id: id,
      name: name,
      contact: contact,
      email: email,
      registered: registered,
      status: status ?? this.status,
      logoUrl: logoUrl,
    );
  }
}
