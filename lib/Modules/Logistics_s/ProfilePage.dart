import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Services/AuthServices.dart'; // adjust path if needed
import '../Common/Login_Page.dart'; // adjust path if needed

final Color kPrimary = const Color(0xFFEF4444);

class LogisticsProfilePage extends StatefulWidget {
  const LogisticsProfilePage({super.key});

  @override
  State<LogisticsProfilePage> createState() => _LogisticsProfilePageState();
}

class _LogisticsProfilePageState extends State<LogisticsProfilePage> {
  // Simulated local user state. Replace with your AppProvider / API-backed user.
  String _name = "Logistics Admin";
  String _email = "logistics@spazigo.com";
  String _phone = "+91 90000 00004";
  String _company = "Spazigo Logistics";
  String _role = "Logistics Provider";

  bool _isDarkMode = false;
  bool _busy = false;

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SafeArea(
        child: _busy
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 16),
              _buildInfoCard(),
              const SizedBox(height: 12),
              _buildAccountActions(context),
              const SizedBox(height: 16),
              _buildDangerZone(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.grey[200],
              backgroundImage: const AssetImage('assets/logo.jpg'), // fallback avatar
              child: _name.isEmpty ? const Icon(Icons.person, size: 36) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(_company, style: GoogleFonts.inter(color: Colors.grey[700])),
                const SizedBox(height: 8),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                    child: Text(_role, style: GoogleFonts.inter(fontSize: 12, color: Colors.green[800])),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _editProfile(context),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text('Edit', style: GoogleFonts.inter(fontSize: 14)),
                  ),
                ])
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_city_outlined),
            title: Text('Company', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text(_company, style: TextStyle(color: Colors.grey[700])),
          ),
        ]),
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context) {
    return Column(children: [
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 1,
        child: Column(children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text('Change Password', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: const Text('Update your login password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _changePassword(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: Text('Support', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: const Text('Contact support or raise a ticket'),
            trailing: const Icon(Icons.open_in_new),
            onTap: _contactSupport,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text('Appearance', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text(_isDarkMode ? 'Dark' : 'Light', style: TextStyle(color: Colors.grey[700])),
            trailing: Switch(value: _isDarkMode, onChanged: (v) => setState(() => _isDarkMode = v)),
            onTap: () => setState(() => _isDarkMode = !_isDarkMode),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildDangerZone(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.red.shade50,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Danger Zone', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.red.shade800)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout_outlined, color: Colors.red),
            title: Text('Log out', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: const Text('Sign out and clear local session'),
            onTap: () => _confirmLogout(context),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: Text('Delete account', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.red)),
            subtitle: const Text('Permanently delete your company account'),
            onTap: () => _confirmDeleteAccount(context),
          ),
        ]),
      ),
    );
  }

  // ------------------- Actions -------------------

  void _editProfile(BuildContext ctx) async {
    // show edit modal and update local state
    final result = await showModalBottomSheet<Map<String, String>?>(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (c) {
        final _formKey = GlobalKey<FormState>();
        final nameController = TextEditingController(text: _name);
        final emailController = TextEditingController(text: _email);
        final phoneController = TextEditingController(text: _phone);
        final companyController = TextEditingController(text: _company);

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
          child: FractionallySizedBox(
            heightFactor: 0.78,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(height: 6, width: 60, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)))),
                const SizedBox(height: 12),
                Text('Edit Profile', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Full name'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(labelText: 'Phone'),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: companyController,
                          decoration: const InputDecoration(labelText: 'Company'),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.of(c).pop(null), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              Navigator.of(c).pop({
                                'name': nameController.text.trim(),
                                'email': emailController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'company': companyController.text.trim(),
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                          child: const Text('Save'))),
                ])
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
        _company = result['company'] ?? _company;
      });

      // TODO: call backend API to persist profile changes
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated (local only)')));
    }
  }

  void _changePassword(BuildContext ctx) async {
    final success = await showDialog<bool>(
      context: ctx,
      builder: (c) {
        final _formKey = GlobalKey<FormState>();
        final curCtrl = TextEditingController();
        final newCtrl = TextEditingController();
        final confirmCtrl = TextEditingController();
        bool _obscure = true;

        return StatefulBuilder(builder: (context, setStateSB) {
          return AlertDialog(
            title: const Text('Change password'),
            content: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: curCtrl,
                  obscureText: _obscure,
                  decoration: const InputDecoration(labelText: 'Current password'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter current password' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: newCtrl,
                  obscureText: _obscure,
                  decoration: const InputDecoration(labelText: 'New password'),
                  validator: (v) => (v == null || v.length < 8) ? 'Min 8 chars' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: _obscure,
                  decoration: const InputDecoration(labelText: 'Confirm new password'),
                  validator: (v) => (v != newCtrl.text) ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Checkbox(value: !_obscure, onChanged: (v) => setStateSB(() => _obscure = !v!)),
                  const SizedBox(width: 6),
                  const Text('Show passwords')
                ])
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // TODO: Call backend change password API here
                      Navigator.of(c).pop(true);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  child: const Text('Change')),
            ],
          );
        });
      },
    );

    if (success == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed (local simulation)')));
    }
  }

  void _contactSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@spazigo.com',
      query: Uri.encodeQueryComponent('subject=Support request from $_company'),
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open mail app')));
    }
  }

  void _confirmLogout(BuildContext ctx) async {
    final yes = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Confirm logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(c).pop(true), style: ElevatedButton.styleFrom(backgroundColor: kPrimary), child: const Text('Log out')),
        ],
      ),
    );
    if (yes == true) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    setState(() => _busy = true);
    try {
      await AuthService.instance.signOut(); // clears token / session
    } catch (_) {
      // ignore errors but continue to navigate to login
    } finally {
      setState(() => _busy = false);
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (r) => false,
        );
      }
    }
  }

  void _confirmDeleteAccount(BuildContext ctx) async {
    final sure = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text('This will permanently delete the account and data. This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(c).pop(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );

    if (sure == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _busy = true);
    // TODO: call backend delete account endpoint with Auth token
    await Future.delayed(const Duration(seconds: 1)); // simulate
    setState(() => _busy = false);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted (simulation)')));
      // After deletion, logout and navigate to login
      await AuthService.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
      }
    }
  }
}
