import 'package:flutter/material.dart';

/// Yeni nesil, canlı ve tutarlı tasarım dili.
/// - Canlı kırmızı/rose tonları
/// - Kart/Buton/NavigationBar stilleri tek yerde
/// - Material 3 ile modern görünüm
ThemeData appTheme() {
  const primary = Color(0xFFE11D48); // canlı rose/red
  const secondary = Color(0xFFFB7185); // gradient destek rengi
  const bg = Color(0xFFFFF6F7); // hafif pembe arka plan
  const text = Color(0xFF111827);
  const muted = Color(0xFF6B7280);

  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: primary,
    secondary: secondary,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,

    textTheme: const TextTheme(
      headlineLarge:
          TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: text),
      headlineMedium:
          TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: text),
      headlineSmall:
          TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: text),
      titleMedium:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: text),
      bodyMedium:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text),
      bodySmall:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: muted),
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle:
          TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: text),
      iconTheme: IconThemeData(color: text),
    ),

    cardTheme: CardTheme(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: muted, fontWeight: FontWeight.w600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      indicatorColor: primary.withValues(alpha: 0.12), // ✅ deprecated temizlendi
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          fontSize: 12,
          color: selected ? primary : muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? primary : muted,
          size: 24,
        );
      }),
    ),
  );
}
