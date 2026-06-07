import 'package:flutter/material.dart';
import '../models/vault_entry.dart';

class AppTheme {
  // ── Palette ───────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0D0D14);
  static const Color surface = Color(0xFF16161F);
  static const Color surfaceCard = Color(0xFF1E1E2C);
  static const Color surfaceHigh = Color(0xFF252535);
  static const Color border = Color(0xFF2A2A3E);

  static const Color primary = Color(0xFF6C63FF);
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentGreen = Color(0xFF00E5A0);

  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF9090B0);
  static const Color textHint = Color(0xFF5A5A7A);

  static const Color danger = Color(0xFFFF5C7A);
  static const Color warning = Color(0xFFFFB347);

  // ── Category meta ─────────────────────────────────────────────────────────
  static Color categoryColor(VaultCategory cat) {
    switch (cat) {
      case VaultCategory.login:
        return const Color(0xFF6C63FF); // indigo
      case VaultCategory.kartu:
        return const Color(0xFF00D4FF); // cyan
      case VaultCategory.identitas:
        return const Color(0xFF00E5A0); // mint
      case VaultCategory.catatanAman:
        return const Color(0xFFFFB347); // amber
    }
  }

  static IconData categoryIcon(VaultCategory cat) {
    switch (cat) {
      case VaultCategory.login:
        return Icons.key_rounded;
      case VaultCategory.kartu:
        return Icons.credit_card_rounded;
      case VaultCategory.identitas:
        return Icons.badge_rounded;
      case VaultCategory.catatanAman:
        return Icons.sticky_note_2_rounded;
    }
  }

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surface,
      error: danger,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: danger, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textHint),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(color: border, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceHigh,
      contentTextStyle: const TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
