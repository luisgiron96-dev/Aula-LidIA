import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Genera los ThemeData claro y oscuro de la app a partir de un
/// color de acento (elegido por el usuario en Configuración >
/// Apariencia). El resto de las pantallas sigue usando AppColors
/// para sus colores fijos; este tema controla los widgets de
/// Material que no tienen un color escrito a mano (AppBar, botones,
/// campos de texto, Switch, etc.) y el fondo general de la app.
class AppTheme {
  static ThemeData light(Color seed) => _build(seed, Brightness.light);
  static ThemeData dark(Color seed) => _build(seed, Brightness.dark);

  static ThemeData _build(Color seed, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    final background = isDark ? const Color(0xFF121212) : AppColors.background;
    final surface    = isDark ? const Color(0xFF1E1E1E) : AppColors.surface;
    final textPrimary   = isDark ? const Color(0xFFF2F2F2) : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFFA9A9A9) : AppColors.textSecondary;

    return ThemeData(
      useMaterial3: false,
      brightness: brightness,
      colorScheme: scheme,
      primaryColor: seed,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: isDark ? Colors.white12 : Colors.grey.shade200,
      textTheme: isDark
        ? ThemeData.dark().textTheme.apply(
            bodyColor: textPrimary, displayColor: textPrimary)
        : ThemeData.light().textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: seed, width: 2),
        ),
        hintStyle: TextStyle(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Colores dependientes del tema activo, para usarlos en las
/// pantallas que ya se actualizaron para soportar modo oscuro
/// (navegación principal, configuración) sin tener que leer
/// Theme.of(context) en cada widget.
class AppThemeColors {
  final bool isDark;
  const AppThemeColors(this.isDark);

  Color get background =>
    isDark ? const Color(0xFF121212) : AppColors.background;
  Color get surface =>
    isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get border =>
    isDark ? Colors.white12 : Colors.grey.shade200;
  Color get textPrimary =>
    isDark ? const Color(0xFFF2F2F2) : AppColors.textPrimary;
  Color get textSecondary =>
    isDark ? const Color(0xFFA9A9A9) : AppColors.textSecondary;
}
