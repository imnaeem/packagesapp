import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand primary
  static const Color primary = Color(0xFF006D77);
  static const Color primaryDark = Color(0xFF00B4C5);

  // Surfaces - Light
  static const Color surfaceLight = Color(0xFFF5F6FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFEEF0F8);

  // Surfaces - Dark
  static const Color surfaceDark = Color(0xFF0F1117);
  static const Color cardDark = Color(0xFF1C1F2A);
  static const Color backgroundDark = Color(0xFF13161F);

  // Text
  static const Color textPrimaryLight = Color(0xFF12131A);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF1F2F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Accent
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Tag/chip backgrounds (light)
  static const Color chipBgLight = Color(0xFFEDEEF8);
  static const Color chipBgDark = Color(0xFF252837);

  // Divider
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF2A2D3E);

  // Network brand colors
  static const Color jazz = Color(0xFFE31837);
  static const Color zong = Color(0xFF009BDE);
  static const Color telenor = Color(0xFF00A0E3);
  static const Color ufone = Color(0xFF00A650);
  static const Color ptcl = Color(0xFF003087);
}

enum AppAccentColor {
  teal(
    id: 'teal',
    label: 'Teal',
    lightColor: Color(0xFF006D77),
    darkColor: Color(0xFF00B4C5),
  ),
  indigo(
    id: 'indigo',
    label: 'Indigo Blue',
    lightColor: Color(0xFF3949AB),
    darkColor: Color(0xFF5C6BC0),
  ),
  emerald(
    id: 'emerald',
    label: 'Emerald Green',
    lightColor: Color(0xFF059669),
    darkColor: Color(0xFF10B981),
  ),
  purple(
    id: 'purple',
    label: 'Purple',
    lightColor: Color(0xFF7B1FA2),
    darkColor: Color(0xFFAB47BC),
  ),
  orange(
    id: 'orange',
    label: 'Sunset Orange',
    lightColor: Color(0xFFE65100),
    darkColor: Color(0xFFFF7043),
  );

  final String id;
  final String label;
  final Color lightColor;
  final Color darkColor;

  const AppAccentColor({
    required this.id,
    required this.label,
    required this.lightColor,
    required this.darkColor,
  });

  static AppAccentColor fromId(String? id) {
    return AppAccentColor.values.firstWhere(
      (e) => e.id == id,
      orElse: () => AppAccentColor.teal,
    );
  }
}
