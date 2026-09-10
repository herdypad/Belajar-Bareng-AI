import 'package:flutter/material.dart';

/// Palet warna meniru UI mockup (aksen ungu #7C3AED).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryDark = Color(0xFF6D28D9);
  static const Color primaryDeep = Color(0xFF4C1D95);
  static const Color lilac = Color(0xFFC4B5FD);

  static const Color success = Color(0xFF34D399);
  static const Color successDeep = Color(0xFF10B981);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFCA5A5);

  // Dark surface
  static const Color darkBg = Color(0xFF0F0B1E);
  static const Color darkCard = Color(0xFF1A1530);
  static const Color darkBorder = Color(0xFF2A2342);
  static const Color darkInput = Color(0xFF15112A);

  // Light surface
  static const Color lightBg = Color(0xFFF7F5FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE6E1F0);
  static const Color lightInput = Color(0xFFF1EEF8);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark, primaryDeep],
  );
}
