// lib/constants/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary changed to match the HTML provided (#EA2831)
  static const Color primary = Color(0xFFEA2831);

  // Backgrounds (light/dark)
  static const Color backgroundLight = Color(0xFFF8F6F6);
  static const Color backgroundDark = Color(0xFF211111);

  // Card colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static final Color cardDark = Colors.grey.shade900.withOpacity(0.55);

  // Text
  static const Color textLight = Color(0xFF111827);
  static const Color textDark = Color(0xFFF3F4F6);

  // Subtle text
  static const Color subtleLight = Color(0xFF6B7280);
  static const Color subtleDark = Color(0xFF9CA3AF);

  // Status colors
  static const Color statusPending = Color(0xFFF59E0B); // yellow
  static const Color statusAccepted = Color(0xFF0EA70E); // green
  static const Color statusInTransit = Color(0xFF10B981); // teal
  static const Color statusCompleted = Color(0xFF3B82F6); // blue

  // Others
  static const Color accent = primary;
  static const Color surface = Color(0xFFFAFAFA);
  static const Color shadow = Color(0xFF000000);
  static const Color yellowStar = Color(0xFFF59E0B);
  static const Color text = Color(0xFF111827);
  static const Color muted = Color(0xFF6B7280);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);

}
