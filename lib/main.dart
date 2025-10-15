import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Provider/App_Provider.dart';
import 'Services/SplashPage.dart';

const Color primaryColor = Color(0xFFEF4444);
const Color backgroundColor = Color(0xFFF8FAFC);
const Color textPrimaryColor = Color(0xFF1F2937);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpazigoApp());
}

class SpazigoApp extends StatelessWidget {
  const SpazigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppProvider>(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'Spazigo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          primaryColor: primaryColor,
          scaffoldBackgroundColor: backgroundColor,
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: textPrimaryColor),
            bodyMedium: TextStyle(color: textPrimaryColor),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
