// lib/Modules/Common/ProfilePage.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Services/AuthServices.dart';
import '../Common/Login_Page.dart'; // adjust path if needed
 // adjust path if needed

final Color kPrimary = const Color(0xFFEF4444);

class ProfilePage extends StatefulWidget {
  // Pass initial user data if available
  final String name;
  final String email;
  final String phone;
  final String role;

  const ProfilePage({
    super.key,
    this.name = "Sanjit",
    this.email = "user@spazigo.com",
    this.phone = "+91 90000 00000",
    this.role = "Logistics",
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _name;
  late String _email;
  late String _phone;
  late String _role;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _email = widget.email;
    _phone = widget.phone;
    _role = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 1,
      ),
      body: SafeArea(
        child: _busy
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildContactCard(),
            const SizedBox(height: 12),
            _buildAccountActions(),
            const SizedBox(height: 18),
            _buildDangerZone(),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: const AssetImage('assets/logo.jpg'),
            child: _name.isEmpty ? const Icon(Icons.person, size: 36) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(_role, style: GoogleFonts.inter(color: Colors.grey[700])),
              const SizedBox(height: 10),
              Row(children: [
                TextButton.icon(
                  onPressed: () => _openEditProfile(),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text('Edit profile', style: GoogleFonts.inter(fontSize: 14)),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _openChangePassword(),
                  icon: const Icon(Icons.lock_outline, size: 16),
                  label: Text('Change password', style: GoogleFonts.inter(fontSize: 14)),
                ),
              ]),
            ]),
          )
        ]),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Contact Information', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email_outlined),
            title: Text('Email', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text(_email, style: TextStyle(color: Colors.grey[700])),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.phone_outlined),
            title: Text('Phone', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text(_phone, style: TextStyle(color: Colors.grey[700])),
          ),
        ]),
      ),
    );
  }

  Widget _buildAccountActions() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        ListTile(
          leading: const Icon(Icons.support_agent_outlined),
          title: Text('Support', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          subtitle: const Text('Contact support@spazigo.com'),
          trailing: const Icon(Icons.open_in_new),
          onTap: _contactSupport,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: Text('Appearance', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          trailing: Switch(value: Theme.of(context).brightness == Brightness.dark, onChanged: (_) {}),
          onTap: () {},
        ),
      ]),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      color: Colors.red.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Danger Zone', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.red.shade800)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout_outlined, color: Colors.red),
            title: Text('Log out', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: const Text('Sign out and clear local session'),
            onTap: _confirmLogout,
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: Text('Delete account', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.red)),
            subtitle: const Text('Permanently delete account (admin only)'),
            onTap: () => _confirmDeleteAccount(),
          ),
        ]),
      ),
    );
  }

  // ---------------- Actions ----------------

  void _openEditProfile() async {
    final result = await showModalBottomSheet<Map<String, String>?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (c) {
        final _formKey = GlobalKey<FormState>();
        final nameCtrl = TextEditingController(text: _name);
        final emailCtrl = TextEditingController(text: _email);
        final phoneCtrl = TextEditingController(text: _phone);

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
          child: FractionallySizedBox(
            heightFactor: 0.7,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Container(height: 6, width: 60, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 12),
                Text('Edit profile', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(children: [
                      TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null),
                      const SizedBox(height: 8),
                      TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null),
                      const SizedBox(height: 8),
                      TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.of(c).pop(null), child: const Text('Cancel'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                Navigator.of(c).pop({
                                  'name': nameCtrl.text.trim(),
                                  'email': emailCtrl.text.trim(),
                                  'phone': phoneCtrl.text.trim(),
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                            child: const Text('Save'),
                          ),
                        )
                      ])
                    ]),
                  ),
                )
              ]),
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _name = result['name'] ?? _name;
        _email = result['email'] ?? _email;
        _phone = result['phone'] ?? _phone;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated (local only)')));
      // TODO: call backend API to persist changes
    }
  }

  void _openChangePassword() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (c) {
        final _formKey = GlobalKey<FormState>();
        final cur = TextEditingController();
        final nw = TextEditingController();
        final conf = TextEditingController();
        bool obscure = true;

        return StatefulBuilder(builder: (context, setSb) {
          return AlertDialog(
            title: const Text('Change password'),
            content: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(controller: cur, obscureText: obscure, decoration: const InputDecoration(labelText: 'Current password'), validator: (v) => (v == null || v.isEmpty) ? 'Enter current' : null),
                const SizedBox(height: 8),
                TextFormField(controller: nw, obscureText: obscure, decoration: const InputDecoration(labelText: 'New password'), validator: (v) => (v == null || v.length < 8) ? 'Min 8 chars' : null),
                const SizedBox(height: 8),
                TextFormField(controller: conf, obscureText: obscure, decoration: const InputDecoration(labelText: 'Confirm new password'), validator: (v) => (v != nw.text) ? 'Does not match' : null),
                Row(children: [Checkbox(value: !obscure, onChanged: (v) => setSb(() => obscure = !v!)), const Text('Show')])
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.of(c).pop(true), style: ElevatedButton.styleFrom(backgroundColor: kPrimary), child: const Text('Change')),
            ],
          );
        });
      },
    );

    if (changed == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password change requested (simulate API call)')));
      // TODO: call backend change-password endpoint
    }
  }

  void _contactSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@spazigo.com',
      queryParameters: {'subject': 'Support request from $_name'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open mail app')));
    }
  }

  void _confirmLogout() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(c).pop(true), style: ElevatedButton.styleFrom(backgroundColor: kPrimary), child: const Text('Log out')),
        ],
      ),
    );

    if (yes == true) await _performLogout();
  }

  Future<void> _performLogout() async {
    setState(() => _busy = true);
    try {
      // AuthService should clear tokens and local session
      await AuthService.instance.signOut();
    } catch (e) {
      // ignore errors but continue navigation
    } finally {
      setState(() => _busy = false);
      if (!mounted) return;
      // Replace navigation stack with login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) =>  LoginPage()),
            (route) => false,
      );
    }
  }

  void _confirmDeleteAccount() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text('This will permanently delete your account. This cannot be undone. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(c).pop(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );

    if (sure == true) {
      // TODO: call delete account API
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted (simulation)')));
      await _performLogout();
    }
  }
}
