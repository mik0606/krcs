// lib/Modules/Common/Login_Page.dart
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../Provider/App_Provider.dart';
import '../../Services/AuthServices.dart';
import '../../Utils/Constants.dart'; // for ApiException, ApiClient if needed
import '../Admin/RootPage.dart';
import '../Driver/RootPage.dart';
import '../Merchant/RootPage.dart';
import '../Logistics_s/RootPage.dart';
import '../Sanjit/RootPage.dart';
import 'RootRegisterPage.dart';

/// Enterprise-grade Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _loading = false;
  bool _obscure = true;
  bool _remember = true;
  String? _errorMessage;

  final AuthService _auth = AuthService.instance;

  // subtle entrance animation for form
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate first
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await _auth.signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      // Save user to provider and navigate by role
      final app = Provider.of<AppProvider>(context, listen: false);
      await app.setUserFromApiJson(result.user, result.token);

      // Route to appropriate root page
      _navigateByRole(app);
    } on ApiException catch (e) {
      // Friendly error from ApiClient/Constants
      setState(() => _errorMessage = e.message);
      _showError(e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Login failed. Please try again.');
      _showError('Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
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
      // Fallback (shouldn't happen if backend provides role)
      dest = const DriverRootPage();
    }

    // Replace entire stack (user shouldn't return to login)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => dest),
          (route) => false,
    );
  }

  // Small helper for "Forgot password" - navigate to your forgot page when implemented
  void _onForgotPassword() {
    // TODO: implement password reset flow (OTP or email)
    _showError('Forgot password not implemented yet.');
  }

  // Quick demo social sign-in hooks (placeholders)
  Future<void> _onSocialSignIn(String provider) async {
    _showError('Social sign-in ($provider) not configured yet.');
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
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
          child: SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 26),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 14),
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
        // Logo or app name
        Text('Spazigo',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            )),
        const SizedBox(height: 6),
        Text('Sign in to continue',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email
          TextFormField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'you@company.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: const OutlineInputBorder(),
            ),
            validator: (v) {
              final s = v?.trim() ?? '';
              if (s.isEmpty) return 'Please enter email';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(s)) return 'Invalid email';
              return null;
            },
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
          ),

          const SizedBox(height: 12),

          // Password
          TextFormField(
            controller: _passwordCtrl,
            focusNode: _passwordFocus,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
                tooltip: _obscure ? 'Show password' : 'Hide password',
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),

          const SizedBox(height: 8),

          // Remember + Forgot Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v ?? true),
                  ),
                  const SizedBox(width: 6),
                  const Text('Remember me'),
                ],
              ),
              InkWell(
                onTap: _onForgotPassword,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Text('Forgot?', style: TextStyle(color: Colors.blue)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Primary sign-in button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 4,
            ),
            child: _loading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Sign in', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary action row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Don\'t have an account?'),
            const SizedBox(width: 6),
            RichText(
              text: TextSpan(
                text: 'Register',
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildSocialRow() {
    // minimal social button row — placeholders for OAuth flows
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton('Google', Colors.redAccent, () => _onSocialSignIn('Google')),
        const SizedBox(width: 12),
        _socialButton('Apple', Colors.black, () => _onSocialSignIn('Apple')),
      ],
    );
  }

  Widget _socialButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(label == 'Google' ? Icons.g_mobiledata : Icons.apple, size: 18),
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
        'By signing in you agree to our Terms & Privacy Policy.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return AbsorbPointer(
      absorbing: _loading,
      child: Container(
        color: Colors.black.withOpacity(0.25),
        child: const Center(
          child: SizedBox(width: 80, height: 80, child: CircularProgressIndicator(strokeWidth: 3)),
        ),
      ),
    );
  }
}
