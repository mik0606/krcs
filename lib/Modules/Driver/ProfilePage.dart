// lib/pages/driver_profile_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/AuthServices.dart';
import '../../Utils/Color.dart';
import '../Common/Login_Page.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> with TickerProviderStateMixin {
  // UI state
  bool _online = true;
  bool _isLoggingOut = false;
  bool _isTogglingOnline = false;

  // Mock driver fields (replace with provider/api model)
  String _name = 'Ethan Carter';
  String _role = 'Driver - Spazigo Fleet';
  String _phone = '+91 98765 43210';
  String _vehicle = 'Mahindra Bolero — MH12XY3456';
  String _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAA1MlvZDSVORWeJ4zyuYH1YmN6JMy7QoLMki6xcVo27GCCts-N0p0Ytmh3BabQxVsF6cp9Gml3DVgiSJNFHbY3sBNDmchKxwWW76TEgwBckWv0g5oKmGxoIHK_xNIDbNp8uKdCs-_UFu6Othxj3ssLRaeIoHeKZtcYvwwhbN5VI8HNB_kaU88YfbksD_d_Hv9Woy1Np2bnwjvw-EPRBNpqaz_l4X0pFxP1ZPd5BEZ9LdXdkE3oFRL3BcE2jXHRjpIA5MUCf5oe1-od';

  // Animation controllers
  late final AnimationController _avatarController;
  Timer? _mockBackgroundTimer;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _avatarController.forward();

    // Example: start a background sync timer (mock). Cancel on logout.
    _mockBackgroundTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      // TODO: background sync or location ping
    });
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _mockBackgroundTimer?.cancel();
    super.dispose();
  }

  // ---------- UX Helpers ----------
  void _showSnack(String message, {Color? color}) {
    if (!mounted) return;
    final snack = SnackBar(content: Text(message), backgroundColor: color);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  // ---------- Avatar picker (stub) ----------
  Future<void> _pickAvatar() async {
    // TODO: integrate image_picker or file_picker to select and upload
    _showSnack('Avatar picker not implemented — integrate image_picker.');
  }

  // ---------- Online toggle that calls backend (mock) ----------
  // Future<void> _toggleOnline() async {
  //   if (_isTogglingOnline) return;
  //   setState(() => _isTogglingOnline = true);
  //
  //   final target = !_online;
  //   try {
  //     // Show optimistic UI change
  //     setState(() => _online = target);
  //
  //     // Simulate API call
  //     await Future.delayed(const Duration(milliseconds: 700));
  //     // TODO: call your backend to update driver status. Throw to simulate error:
  //     // throw Exception('Network error');
  //
  //     // Persist status locally for fast startup
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setBool('driver_online', _online);
  //
  //     _showSnack(_online ? 'You are Online' : 'You are Offline', color: _online ? AppColors.success : AppColors.warning);
  //   } catch (e) {
  //     // revert UI
  //     setState(() => _online = !target);
  //     _showSnack('Failed to update status: ${_shortError(e)}', color: Colors.redAccent);
  //   } finally {
  //     if (mounted) setState(() => _isTogglingOnline = false);
  //   }
  // }

  String _shortError(Object e) {
    final s = e.toString();
    return s.length > 80 ? '${s.substring(0, 77)}...' : s;
  }

  // ---------- Logout flow (robust) ----------
  Future<void> _confirmLogout() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm logout'),
        content: const Text('Are you sure you want to log out from Spazigo?'),
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

    // Fade out timers / background tasks
    _mockBackgroundTimer?.cancel();

    try {
      // 1) Call backend / auth provider sign out
      await AuthService.instance.signOut();

      // // 2) Clear local session & tokens
      // await AuthService.instance.clearLocalSession();

      // 3) Optionally clear providers / caches
      // TODO: call Provider/Bloc to clear in-memory state

      // 4) Navigate to login and remove back stack
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    } catch (e) {
      if (mounted) {
        _showSnack('Logout failed: ${_shortError(e)}', color: Colors.redAccent);
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  // ---------- Small reusable UI components ----------
  Widget _buildAvatar(double size) {
    return Semantics(
      label: 'Driver avatar',
      child: GestureDetector(
        onTap: _pickAvatar,
        child: Hero(
          tag: 'driver-avatar-hero',
          child: AnimatedBuilder(
            animation: _avatarController,
            builder: (context, child) {
              final scale = 0.9 + 0.1 * _avatarController.value;
              return Transform.scale(scale: scale, child: child);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/placeholder-avatar.png', // provide a local placeholder
                image: _avatarUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                imageErrorBuilder: (c, e, s) => Container(
                  width: size,
                  height: size,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.person, size: size * 0.6, color: Colors.grey.shade400),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.cardDark : AppColors.cardLight;
    return Material(
      color: bg,
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
                ]),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Responsive layout ----------
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
        title: Text('Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: brightness == Brightness.dark ? Colors.white : Colors.black87)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_none),
              color: brightness == Brightness.dark ? Colors.white : Colors.black87,
              onPressed: () => _showSnack('Notifications tapped'),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final avatarSize = isWide ? 160.0 : 112.0;

          final body = SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              // Header block
              Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _buildAvatar(avatarSize),
                  const SizedBox(height: 12),
                  Text(_name, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(_role, style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
                  const SizedBox(height: 12),
                  // contact & vehicle mini row
                  Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 8,
                    spacing: 12,
                    children: [
                      _chipInfo(Icons.phone, _phone),
                      _chipInfo(Icons.directions_car, _vehicle),
                      // _chipStatus(),
                    ],
                  ),
                  const SizedBox(height: 16),
                ]),
              ),

              // Cards / panels
              SizedBox(height: 8),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(children: [
                        _infoCard(icon: Icons.person, title: 'Personal Info', subtitle: 'Name, phone, email, license', onTap: _openPersonalInfo),
                        const SizedBox(height: 12),
                        _infoCard(icon: Icons.local_shipping, title: 'Vehicle Info', subtitle: 'Model, registration, capacity', onTap: _openVehicleInfo),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Column(children: [
                        _infoCard(icon: Icons.show_chart, title: 'Performance', subtitle: 'Deliveries & ratings', onTap: _openPerformance),
                        const SizedBox(height: 12),
                        _infoCard(icon: Icons.payments, title: 'Earnings Summary', subtitle: 'This week & payouts', onTap: _openEarnings),
                      ]),
                    )
                  ],
                )
              else
                Column(children: [
                  _infoCard(icon: Icons.person, title: 'Personal Info', subtitle: 'Name, phone, email, license', onTap: _openPersonalInfo),
                  const SizedBox(height: 12),
                  _infoCard(icon: Icons.local_shipping, title: 'Vehicle Info', subtitle: 'Model, registration, capacity', onTap: _openVehicleInfo),
                  const SizedBox(height: 12),
                  _infoCard(icon: Icons.show_chart, title: 'Performance', subtitle: 'Deliveries & ratings', onTap: _openPerformance),
                  const SizedBox(height: 12),
                  _infoCard(icon: Icons.payments, title: 'Earnings Summary', subtitle: 'This week & payouts', onTap: _openEarnings),
                ]),

              const SizedBox(height: 18),

              // Actions
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openEditProfile,
                    icon: const Icon(Icons.edit),
                    label: Text('Edit Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openDocuments,
                    icon: const Icon(Icons.folder_open),
                    label: Text('View Documents', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.primary.withOpacity(0.22)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 12),

              // Logout area with descriptive text
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
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
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

          // Wrap with container to provide top-level card-like surface
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 1000 : constraints.maxWidth),
              child: body,
            ),
          );
        }),
      ),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------- Small helper widgets for header chips ----------
  Widget _chipInfo(IconData i, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(i, size: 16, color: AppColors.muted),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
      ]),
    );
  }

  // Widget _chipStatus() {
  //   return GestureDetector(
  //     // onTap: _toggleOnline,
  //     // child: Container(
  //     //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  //     //   decoration: BoxDecoration(
  //     //     color: _online ? AppColors.primary.withOpacity(0.12) : Colors.grey.shade200,
  //     //     borderRadius: BorderRadius.circular(999),
  //     //   ),
  //     //   child: Row(children: [
  //     //     AnimatedSwitcher(
  //     //       duration: const Duration(milliseconds: 250),
  //     //       child: _isTogglingOnline
  //     //           ? SizedBox(key: const ValueKey('loader'), width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
  //     //           : Icon(_online ? Icons.toggle_on : Icons.toggle_off, color: _online ? AppColors.primary : Colors.grey, size: 22),
  //     //     ),
  //     //     const SizedBox(width: 8),
  //     //     Text(_online ? 'Online' : 'Offline', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _online ? AppColors.primary : AppColors.muted)),
  //     //   ]),
  //     // ),
  //   );
  // }

  // ---------- Navigation placeholders (replace with actual navigation) ----------
  void _openPersonalInfo() => _showSnack('Open Personal Info — implement page');
  void _openVehicleInfo() => _showSnack('Open Vehicle Info — implement page');
  void _openPerformance() => _showSnack('Open Performance — implement page');
  void _openEarnings() => _showSnack('Open Earnings — implement page');
  void _openEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 18, top: 18, left: 18, right: 18),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Edit Profile', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text('Profile editing form placeholder', style: GoogleFonts.inter(color: AppColors.muted)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  void _openDocuments() => _showSnack('Open Documents — implement page');

  // ---------- Bottom navigation (enterprise look) ----------
  Widget _buildBottomNav() {
    return BottomAppBar(
      elevation: 10,
      color: Theme.of(context).brightness == Brightness.dark ? AppColors.backgroundDark.withOpacity(0.98) : AppColors.backgroundLight.withOpacity(0.98),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _bottomNavItem(icon: Icons.home, label: 'Home', idx: 0),
          _bottomNavItem(icon: Icons.list_alt, label: 'Orders', idx: 1),
          _bottomNavItem(icon: Icons.account_balance_wallet, label: 'Earnings', idx: 2),
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
        // TODO: navigate to target page
        _showSnack('Navigate: $label');
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: selected ? BoxDecoration(color: AppColors.primary.withOpacity(0.14), shape: BoxShape.circle) : null,
          child: Icon(icon, color: selected ? AppColors.primary : Colors.grey),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: selected ? AppColors.primary : Colors.grey, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      ]),
    );
  }
}
