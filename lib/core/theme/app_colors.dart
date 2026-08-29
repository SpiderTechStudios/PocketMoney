import 'package:flutter/material.dart';

/// Centralized palette for PocketMoney.
/// Keep UI colors here so screens never hardcode one-off values.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0F766E);
  static const Color primaryHover = Color(0xFF0D9488);
  static const Color primaryPressed = Color(0xFF115E59);
  static const Color primaryMuted = Color(0xFFCCFBF1);

  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFF134E4A);
  static const Color accent = Color(0xFFD4A054);

  static const Color brandingBackground = Color(0xFF042F2E);
  static const Color brandingBackgroundEnd = Color(0xFF0F766E);
  static const Color onBranding = Color(0xFFFFFFFF);
  static const Color onBrandingMuted = Color(0xFF99F6E4);

  static const Color scaffold = Color(0xFFF4F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8FAFC);

  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceMuted = Color(0xFF64748B);
  static const Color onSurfaceSubtle = Color(0xFF94A3B8);

  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineFocused = Color(0xFF0F766E);

  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color inputFillDisabled = Color(0xFFF1F5F9);

  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorMuted = Color(0xFFFEF2F2);

  static const Color success = Color(0xFF059669);
  static const Color successMuted = Color(0xFFECFDF5);

  static const Color googleButtonBackground = Color(0xFFFFFFFF);
  static const Color googleButtonHover = Color(0xFFF8FAFC);
  static const Color googleButtonPressed = Color(0xFFF1F5F9);

  static const Color divider = Color(0xFFE2E8F0);
  static const Color hoverOverlay = Color(0x0F0F766E);
  static const Color pressedOverlay = Color(0x1A0F766E);
}
