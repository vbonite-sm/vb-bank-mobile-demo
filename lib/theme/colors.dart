import 'package:flutter/material.dart';

class AppColors {
  /// Global brightness flag — set by AuthProvider when theme toggles
  static bool isDark = true;

  // ── Always the same regardless of theme ──
  static const primary = Color(0xFF6366f1);
  static const primaryLight = Color(0xFF818cf8);
  static const accent = Color(0xFF22d3ee);
  static const success = Color(0xFF10b981);
  static const successLight = Color(0xFF34d399);
  static const error = Color(0xFFef4444);
  static const errorLight = Color(0xFFf87171);
  static const warning = Color(0xFFf59e0b);
  static const warningLight = Color(0xFFFBBF24);
  static const info = Color(0xFF3b82f6);

  // ── Dark-only constants (for reference / ThemeData) ──
  static const _darkBackground = Color(0xFF0a0e27);
  static const _darkCardBg = Color(0xFF1a1f3a);
  static const _darkCardBgLight = Color(0xFF252a4a);
  static const _darkText = Color(0xFFe2e8f0);
  static const _darkTextMuted = Color(0xFF94a3b8);
  static const _darkTextDark = Color(0xFF64748b);
  static const _darkBorder = Color(0xFF2a2f4a);
  static const _darkDivider = Color(0xFF1e2340);
  static const _darkSurface = Color(0xFF1e2340);
  static const _darkInputBg = Color(0xFF141830);
  static const _darkShimmer = Color(0xFF2a2f4a);

  // ── Light-only constants ──
  static const _lightBackground = Color(0xFFF5F7FA);
  static const _lightCardBg = Color(0xFFFFFFFF);
  static const _lightCardBgLight = Color(0xFFF0F2F5);
  static const _lightText = Color(0xFF1A202C);
  static const _lightTextMuted = Color(0xFF718096);
  static const _lightTextDark = Color(0xFFA0AEC0);
  static const _lightBorder = Color(0xFFE2E8F0);
  static const _lightDivider = Color(0xFFEDF2F7);
  static const _lightSurface = Color(0xFFF7FAFC);
  static const _lightInputBg = Color(0xFFF7FAFC);
  static const _lightShimmer = Color(0xFFE2E8F0);

  // ── Theme-aware getters — every AppColors.xxx usage auto-switches ──
  static Color get background => isDark ? _darkBackground : _lightBackground;
  static Color get cardBg => isDark ? _darkCardBg : _lightCardBg;
  static Color get cardBgLight => isDark ? _darkCardBgLight : _lightCardBgLight;
  static Color get text => isDark ? _darkText : _lightText;
  static Color get textMuted => isDark ? _darkTextMuted : _lightTextMuted;
  static Color get textDark => isDark ? _darkTextDark : _lightTextDark;
  static Color get border => isDark ? _darkBorder : _lightBorder;
  static Color get divider => isDark ? _darkDivider : _lightDivider;
  static Color get surface => isDark ? _darkSurface : _lightSurface;
  static Color get inputBg => isDark ? _darkInputBg : _lightInputBg;
  static Color get shimmer => isDark ? _darkShimmer : _lightShimmer;

  // ── Kept for backward compat (old lightXxx references) ──
  static const lightBackground = _lightBackground;
  static const lightCardBg = _lightCardBg;
  static const lightText = _lightText;
  static const lightTextMuted = _lightTextMuted;
  static const lightBorder = _lightBorder;
  static const lightInputBg = _lightInputBg;
  static const lightDivider = _lightDivider;

  // Card gradient colors
  static const gradientPurple = [Color(0xFF6366f1), Color(0xFF8b5cf6)];
  static const gradientCyan = [Color(0xFF06b6d4), Color(0xFF22d3ee)];
  static const gradientGreen = [Color(0xFF10b981), Color(0xFF34d399)];
  static const gradientOrange = [Color(0xFFf59e0b), Color(0xFFFBBF24)];
  static const gradientPink = [Color(0xFFec4899), Color(0xFFf472b6)];
  static const gradientBlue = [Color(0xFF3b82f6), Color(0xFF60a5fa)];
}
