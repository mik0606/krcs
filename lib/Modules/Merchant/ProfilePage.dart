// lib/pages/merchant_profile_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/AuthServices.dart';
import '../../Utils/Color.dart';
import '../Common/Login_Page.dart';

class MerchantProfilePage extends StatefulWidget {
  const MerchantProfilePage({super.key});

  @override
  State<MerchantProfilePage> createState() => _MerchantProfilePageState();
}

class _MerchantProfilePageState extends State<MerchantProfilePage> with TickerProviderStateMixin {
  // UI & state
  bool _isLoggingOut = false;
  bool _isTogglingOpen = false;
  bool _isOpen = true;

  // Mock merchant fields — replace with API/Provider model
  String _businessName = 'GreenLeaf Grocers';
  String _ownerName = 'Priya Sharma';
  String _phone = '+91 98765 43210';
  String _email = 'priya@greenleaf.com';
  String _gstNumber = '27ABCDE1234F1Z5';
  String _bankInfo = 'HDFC • ****1234';
  String _avatarUrl = 'https://via.placeholder.com/400x400.png?text=Merchant+Logo';
  double _thisWeekEarnings = 12450.75;
  int _totalOrders = 384;
  double _rating = 4.7;
  bool _isVerified = true;

  // Animation controllers
  late final AnimationController _avatarController;

  // Optional background task handle
  Timer? _mockSyncTimer;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _avatarController.forward();

    // Load persisted open/closed state
    _loadPersistedState();

    // mock background tasks
    _mockSyncTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      // TODO: periodic sync or status ping
    });
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isOpen = prefs.getBool('merchant_open') ?? true;
    });
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _mockSyncTimer?.cancel();
    super.dispose();
  }

  // ---------- small helpers ----------
  void _showSnack(String message, {Color? background}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: background));
  }

  String _shortError(Object e) {
    final s = e.toString();
    return s.length > 80 ? '${s.substring(0, 77)}...' : s;
  }

  // ---------- avatar picker stub ----------
  Future<void> _pickLogo() async {
    // TODO: integrate image_picker + crop + upload
    _showSnack('Logo picker not implemented — integrate image_picker or file_picker.');
  }

  // ---------- toggle open / closed with backend mock ----------
  Future<void> _toggleOpenClosed() async {
    if (_isTogglingOpen) return;
    setState(() => _isTogglingOpen = true);

    final target = !_isOpen;
    try {
      // optimistic UI
      setState(() => _isOpen = target);

      // simulate API call
      await Future.delayed(const Duration(milliseconds: 700));
      // TODO: call real endpoint; throw to simulate
      // throw Exception('Network error');

      // persist locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('merchant_open', _isOpen);

      _showSnack(_isOpen ? 'Store is now Open' : 'Store set to Closed', background: _isOpen ? AppColors.success : AppColors.warning);
    } catch (e) {
      // revert
      setState(() => _isOpen = !target);
      _showSnack('Failed to update status: ${_shortError(e)}', background: Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isTogglingOpen = false);
    }
  }

  // ---------- logout flow ----------
  Future<void> _confirmLogout() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm logout'),
        content: const Text('Do you want to sign out from your Merchant account?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Log out')),
        ],
      ),
    );

    if (yes == true) await _doLogout();
  }

  Future<void> _doLogout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    // Stop any background tasks
    _mockSyncTimer?.cancel();

    try {
      // 1) server / auth sign out
      await AuthService.instance.signOut();
      // 2) clear local persistent session
      // await AuthService.instance.clearLocalSession();
      // 3) clear additional data (providers, caches) if needed — TODO hook

      // 4) navigate to login and remove stack
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    } catch (e) {
      if (mounted) _showSnack('Logout failed: ${_shortError(e)}', background: Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  // ---------- small reusable UI blocks ----------
  Widget _buildAvatar(double size) {
    return GestureDetector(
      onTap: _pickLogo,
      child: Hero(
        tag: 'merchant-avatar-hero',
        child: AnimatedBuilder(
          animation: _avatarController,
          builder: (context, child) {
            final s = 0.9 + 0.1 * _avatarController.value;
            return Transform.scale(scale: s, child: child);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/placeholder-merchant.png',
              image: _avatarUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              imageErrorBuilder: (c, e, s) => Container(
                width: size,
                height: size,
                color: Colors.grey.shade200,
                child: Icon(Icons.storefront, size: size * 0.45, color: Colors.grey.shade500),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statTile(String label, String value, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) Icon(icon, size: 18, color: AppColors.muted),
        if (icon != null) const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ])
      ]),
    );
  }

  Widget _infoCard({required String title, required List<Widget> children, VoidCallback? onTap}) {
    return Material(
      color: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ...children,
          ]),
        ),
      ),
    );
  }

  // ---------- nav & page actions (placeholders) ----------
  void _openBusinessDetails() => _showSnack('Open Business Details — implement page');
  void _openBankDetails() => _showSnack('Open Bank Details — implement page');
  void _openOrders() => _showSnack('Open Orders — implement page');
  void _openDocuments() => _showSnack('Open Documents — implement page');
  void _openPayouts() => _showSnack('Open Payouts — implement page');
  void _openEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 18, top: 18, left: 18, right: 18),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Edit Merchant Profile', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text('Profile editing form placeholder', style: GoogleFonts.inter(color: AppColors.muted)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scaffoldBg = brightness == Brightness.dark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg.withOpacity(0.98),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
          color: brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
        title: Text('Merchant Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: brightness == Brightness.dark ? Colors.white : Colors.black87)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none),
            color: brightness == Brightness.dark ? Colors.white : Colors.black87,
            onPressed: () => _showSnack('Notifications tapped'),
          )
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 760;
          final avatarSize = isWide ? 160.0 : 110.0;

          final content = SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              // HEADER
              Center(
                child: Column(children: [
                  _buildAvatar(avatarSize),
                  const SizedBox(height: 12),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(_businessName, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 8),
                        if (_isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                            child: Row(children: [
                              Icon(Icons.verified, size: 14, color: AppColors.success),
                              const SizedBox(width: 6),
                              Text('Verified', style: GoogleFonts.inter(fontSize: 12, color: AppColors.success)),
                            ]),
                          )
                      ]),
                      const SizedBox(height: 6),
                      Text('Owner: $_ownerName', style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
                    ])
                  ]),
                  const SizedBox(height: 12),

                  // stats row
                  Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [
                    _statTile('This week', '₹${_thisWeekEarnings.toStringAsFixed(0)}', icon: Icons.currency_rupee),
                    _statTile('Orders', '$_totalOrders', icon: Icons.shopping_bag),
                    _statTile('Rating', '$_rating ★', icon: Icons.star),
                  ]),
                  const SizedBox(height: 12),

                  // Open/Closed chip
                  GestureDetector(
                    onTap: _toggleOpenClosed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                      decoration: BoxDecoration(
                        color: _isOpen ? AppColors.primary.withOpacity(0.12) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _isTogglingOpen
                              ? SizedBox(key: const ValueKey('loader'), width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                              : Icon(_isOpen ? Icons.storefront : Icons.store_mall_directory, color: _isOpen ? AppColors.primary : AppColors.muted, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(_isOpen ? 'Open for Orders' : 'Closed', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: _isOpen ? AppColors.primary : AppColors.muted)),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 18),
                ]),
              ),

              // MAIN CARDS (responsive)
              if (isWide)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    flex: 6,
                    child: Column(children: [
                      _infoCard(title: 'Business Details', children: [
                        ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('GST'), subtitle: Text(_gstNumber)),
                        const Divider(),
                        ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('Contact'), subtitle: Text('$_phone • $_email')),
                        const Divider(),
                        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _openBusinessDetails, child: const Text('Edit'))),
                      ], onTap: _openBusinessDetails),
                      const SizedBox(height: 12),
                      _infoCard(title: 'Documents & Verification', children: [
                        ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.picture_as_pdf, color: AppColors.muted), title: Text('Business Registration'), subtitle: Text('Uploaded')),
                        const SizedBox(height: 8),
                        ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.badge, color: AppColors.muted), title: Text('Owner ID'), subtitle: Text('Verified')),
                        const SizedBox(height: 8),
                        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _openDocuments, child: const Text('View Documents'))),
                      ], onTap: _openDocuments),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: Column(children: [
                      _infoCard(title: 'Bank & Payouts', children: [
                        ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('Bank'), subtitle: Text(_bankInfo)),
                        const Divider(),
                        ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('Payout Frequency'), subtitle: Text('Weekly')),
                        const SizedBox(height: 8),
                        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _openPayouts, child: const Text('Payouts'))),
                      ], onTap: _openBankDetails),
                      const SizedBox(height: 12),
                      _infoCard(title: 'Quick Actions', children: [
                        ElevatedButton.icon(onPressed: _openOrders, icon: const Icon(Icons.list), label: const Text('View Orders'), style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44))),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(onPressed: _openEditProfile, icon: const Icon(Icons.edit), label: const Text('Edit Profile'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44))),
                      ], onTap: _openOrders),
                    ]),
                  ),
                ])
              else
                Column(children: [
                  _infoCard(title: 'Business Details', children: [
                    ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('GST'), subtitle: Text(_gstNumber)),
                    const Divider(),
                    ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('Contact'), subtitle: Text('$_phone • $_email')),
                    const Divider(),
                    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _openBusinessDetails, child: const Text('Edit'))),
                  ], onTap: _openBusinessDetails),
                  const SizedBox(height: 12),
                  _infoCard(title: 'Bank & Payouts', children: [
                    ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('Bank'), subtitle: Text(_bankInfo)),
                    const Divider(),
                    ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('Payout Frequency'), subtitle: Text('Weekly')),
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _openPayouts, child: const Text('Payouts'))),
                  ], onTap: _openBankDetails),
                  const SizedBox(height: 12),
                  _infoCard(title: 'Documents & Verification', children: [
                    ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.picture_as_pdf, color: AppColors.muted), title: Text('Business Registration'), subtitle: Text('Uploaded')),
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _openDocuments, child: const Text('View Documents'))),
                  ], onTap: _openDocuments),
                  const SizedBox(height: 12),
                  _infoCard(title: 'Quick Actions', children: [
                    ElevatedButton.icon(onPressed: _openOrders, icon: const Icon(Icons.list), label: const Text('View Orders'), style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44))),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(onPressed: _openEditProfile, icon: const Icon(Icons.edit), label: const Text('Edit Profile'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44))),
                  ], onTap: _openOrders),
                ]),

              const SizedBox(height: 18),

              // Logout row
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoggingOut ? null : _confirmLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _isLoggingOut
                          ? Row(key: const ValueKey(1), mainAxisAlignment: MainAxisAlignment.center, children: const [
                        SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 12),
                        Text('Signing out...')
                      ])
                          : Row(key: const ValueKey(2), mainAxisAlignment: MainAxisAlignment.center, children: const [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout')
                      ]),
                    ),
                  ),
                )
              ]),

              const SizedBox(height: 28),
            ]),
          );

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 1100 : constraints.maxWidth),
              child: content,
            ),
          );
        }),
      ),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  // bottom nav (simple)
  Widget _buildBottomNav() {
    return BottomAppBar(
      elevation: 10,
      color: Theme.of(context).brightness == Brightness.dark ? AppColors.backgroundDark.withOpacity(0.98) : AppColors.backgroundLight.withOpacity(0.98),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _bottomNavItem(icon: Icons.home, label: 'Home', idx: 0),
          _bottomNavItem(icon: Icons.receipt_long, label: 'Orders', idx: 1),
          _bottomNavItem(icon: Icons.account_balance_wallet, label: 'Payouts', idx: 2),
          _bottomNavItem(icon: Icons.person, label: 'Profile', idx: 3),
        ]),
      ),
    );
  }

  int _selectedIndex = 3;
  Widget _bottomNavItem({required IconData icon, required String label, required int idx}) {
    final selected = _selectedIndex == idx;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = idx);
        _showSnack('Navigate: $label');
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(8), decoration: selected ? BoxDecoration(color: AppColors.primary.withOpacity(0.14), shape: BoxShape.circle) : null, child: Icon(icon, color: selected ? AppColors.primary : Colors.grey)),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: selected ? AppColors.primary : Colors.grey, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      ]),
    );
  }
}
