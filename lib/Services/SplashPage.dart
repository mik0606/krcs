// lib/Modules/Common/SplashPage.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// ✅ FIXED import paths (this file is in lib/Modules/Common/)

import '../../Provider/App_Provider.dart';
import '../../Services/AuthServices.dart';
import '../Modules/Admin/RootPage.dart';
import '../Modules/Common/Login_Page.dart';
import '../Modules/Driver/RootPage.dart';
import '../Modules/Logistics_s/RootPage.dart';
import '../Modules/Merchant/RootPage.dart';
import '../Modules/Sanjit/RootPage.dart';


const Color primaryColor = Color(0xFFEF4444);
const Color backgroundColor = Color(0xFFF8FAFC);
const Color textPrimaryColor = Color(0xFF1F2937);

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthService _authService = AuthService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    // small pause so the splash shows smoothly
    await Future.delayed(const Duration(milliseconds: 600));

    final app = Provider.of<AppProvider>(context, listen: false);
    bool navigated = false;

    try {
      // Tries server /auth/me; falls back to cached user if offline
      final authResult = await _authService.getUserData();
      if (authResult != null) {
        await app.setUserFromApiJson(authResult.user, authResult.token);
        navigated = _navigate(app);
      }
    } catch (e) {
      debugPrint('Splash: getUserData failed → $e');
    }

    // If still not navigated, try provider’s local restore
    if (!navigated) {
      final restored = await app.restoreSession();
      if (restored) {
        navigated = _navigate(app);
      }
    }

    if (!navigated && mounted) {
      _replaceWith(const LoginPage());
    }
  }

  bool _navigate(AppProvider app) {
    if (!mounted || !app.isLoggedIn) return false;

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
      dest = const LoginPage();
    }

    _replaceWith(dest);
    return true;
  }

  void _replaceWith(Widget page) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Spazigo',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: primaryColor),
          ],
        ),
      ),
    );
  }
}
