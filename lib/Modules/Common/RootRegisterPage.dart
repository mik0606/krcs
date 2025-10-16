import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../Provider/App_Provider.dart';
import '../../Services/AuthServices.dart';
import '../../Utils/Constants.dart';
import '../Admin/RootPage.dart';
import '../Driver/RootPage.dart';
import '../Merchant/RootPage.dart';
import '../Logistics_s/RootPage.dart';
import '../Sanjit/RootPage.dart';
import 'Login_Page.dart';

/// Enterprise-grade Registration Page
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  String? _errorMessage;
  String _selectedRole = 'driver'; // Default role

  final AuthService _auth = AuthService.instance;

  // Available roles matching backend
  final List<Map<String, String>> _roles = [
    {'value': 'driver', 'label': '🚗 Driver', 'desc': 'Deliver packages and goods'},
    {'value': 'merchant', 'label': '🏪 Merchant', 'desc': 'Sell products and services'},
    {'value': 'logistic', 'label': '📦 Logistics', 'desc': 'Manage logistics operations'},
    {'value': 'admin', 'label': '👑 Admin', 'desc': 'System administration'},
  ];

  // Animation controllers
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450)
    );
    _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Check terms agreement
    if (!_agreeTerms) {
      _showError('Please agree to Terms & Privacy Policy');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await _auth.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _selectedRole,
      );

      // Save user to provider and navigate by role
      final app = Provider.of<AppProvider>(context, listen: false);
      await app.setUserFromApiJson(result.user, result.token);

      // Show success message
      _showSuccess('Registration successful! Welcome aboard! 🎉');

      // Small delay for user to see success message
      await Future.delayed(const Duration(milliseconds: 1500));

      // Route to appropriate root page
      _navigateByRole(app);

    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
      _showError(e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Registration failed. Please try again.');
      _showError('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateByRole(AppProvider app) {
    Widget dest;
    if (app.isAdmin) {
      dest = const AdminRootPage();
    } else if (app.isDriver) {
      dest = const DriverRootPage();
    } else if (app.isMerchant) {
      dest = const MerchantRootPage();
    } else if (app.isLogistics) {
      dest = const LogisticsRootPage();
    } else if (app.isSanjit) {
      dest = const SanjitRootPage();
    } else {
      dest = const DriverRootPage();
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => dest),
          (route) => false,
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  // Social registration placeholders
  Future<void> _onSocialSignUp(String provider) async {
    _showError('Social sign-up ($provider) not configured yet.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildBody(theme),
          if (_loading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFAFAFA), Color(0xFFF6F6F8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 26),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 18),
                        _buildForm(),
                        const SizedBox(height: 16),
                        _buildActions(),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        _buildSocialRow(),
                        const SizedBox(height: 8),
                        _buildFooterText(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Join Spazigo',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Create your account to get started',
          style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[700]
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name
          TextFormField(
            controller: _nameCtrl,
            focusNode: _nameFocus,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'John Doe',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              final s = v?.trim() ?? '';
              if (s.isEmpty) return 'Please enter your full name';
              if (s.length < 2) return 'Name must be at least 2 characters';
              return null;
            },
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
          ),

          const SizedBox(height: 12),

          // Email
          TextFormField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'you@company.com',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              final s = v?.trim() ?? '';
              if (s.isEmpty) return 'Please enter email address';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(s)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
          ),

          const SizedBox(height: 12),

          // Phone Number (Optional)
          TextFormField(
            controller: _phoneCtrl,
            focusNode: _phoneFocus,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            decoration: const InputDecoration(
              labelText: 'Phone Number (Optional)',
              hintText: '+1 (555) 123-4567',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              final s = v?.trim() ?? '';
              if (s.isNotEmpty && s.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
          ),

          const SizedBox(height: 12),

          // Role Selection
          Text(
            'Select Your Role',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: _roles.map((role) => _buildRoleOption(role)).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Password
          TextFormField(
            controller: _passwordCtrl,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a strong password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              // Optional: Add more password strength requirements
              if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(v)) {
                return 'Password must contain both letters and numbers';
              }
              return null;
            },
            onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
          ),

          const SizedBox(height: 12),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordCtrl,
            focusNode: _confirmPasswordFocus,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                tooltip: _obscureConfirm ? 'Show password' : 'Hide password',
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),

          const SizedBox(height: 16),

          // Terms & Conditions Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreeTerms,
                onChanged: (v) => setState(() => _agreeTerms = v ?? false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: Show terms dialog or navigate to terms page
                            _showError('Terms & Conditions page not implemented yet.');
                          },
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: Show privacy policy dialog or navigate to privacy page
                            _showError('Privacy Policy page not implemented yet.');
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(Map<String, String> role) {
    final isSelected = _selectedRole == role['value'];
    return InkWell(
      onTap: () => setState(() => _selectedRole = role['value']!),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: role['value']!,
              groupValue: _selectedRole,
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue[700] : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role['desc']!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Primary registration button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
              ),
              elevation: 4,
            ),
            child: _loading
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              'Create Account',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary action row - navigate to login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(width: 6),
            RichText(
              text: TextSpan(
                text: 'Sign In',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: TapGestureRecognizer()..onTap = _navigateToLogin,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton('Google', Colors.redAccent, () => _onSocialSignUp('Google')),
        const SizedBox(width: 12),
        _socialButton('Apple', Colors.black, () => _onSocialSignUp('Apple')),
      ],
    );
  }

  Widget _socialButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(
        label == 'Google' ? Icons.g_mobiledata : Icons.apple,
        size: 18,
      ),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildFooterText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        'By creating an account you agree to our Terms & Privacy Policy.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return AbsorbPointer(
      absorbing: _loading,
      child: Container(
        color: Colors.black.withOpacity(0.25),
        child: const Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      ),
    );
  }
}
