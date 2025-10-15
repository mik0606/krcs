// lib/Modules/Common/SplashPage.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../Services/Authservices.dart';
import '../Modules/Admin/RootPage.dart';
import '../Modules/Common/Login_Page.dart';
import '../Modules/Driver/RootPage.dart';
import '../Modules/Logistics_s/RootPage.dart';
import '../Modules/Merchant/RootPage.dart';
import '../Modules/Sanjit/RootPage.dart';
import '../Provider/App_Provider.dart';


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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 900));
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    bool navigated = false;

    try {
      final authResult = await _authService.getUserData();
      if (authResult != null && authResult.token != null && authResult.user != null) {
        await appProvider.setUserFromApiJson(authResult.user, authResult.token);
        navigated = _navigate(appProvider);
      }
    } catch (e) {
      debugPrint('Splash: AuthService failed $e');
    }

    if (!navigated) {
      final restored = await appProvider.restoreSession();
      if (restored) {
        navigated = _navigate(appProvider);
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
