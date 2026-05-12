import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - Deep & Professional SaaS Dashboard
  static const Color primary = Color(0xFF09090B); // Zinc 950 (Deepest Black)
  static const Color background = Color(0xFF09090B); // Zinc 950
  static const Color surface = Color(0xFF18181B); // Zinc 900
  static const Color cardBg = Color(0xFF18181B);
  
  static const Color accent = Color(0xFF3B82F6); // Blue 500 (Primary Action)
  static const Color accentGold = Color(0xFFF59E0B); // Amber 500
  static const Color accentRose = Color(0xFFF43F5E); // Rose 500
  
  static const Color textPrimary = Color(0xFFFAFAFA); // Zinc 50
  static const Color textSecondary = Color(0xFFA1A1AA); // Zinc 400
  
  static const Color divider = Color(0xFF27272A); // Zinc 800
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444); // Red 500

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentGold,
        surface: surface,
        onSurface: textPrimary,
        error: error,
      ),
      dividerColor: divider,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // Helper for glassmorphism-like cards
  static BoxDecoration glassCard({Color? borderColor}) {
    return BoxDecoration(
      color: cardBg.withOpacity(0.6),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: borderColor ?? divider.withOpacity(0.5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
