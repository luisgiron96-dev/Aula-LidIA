import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controla el modo de tema (claro/oscuro/sistema) y el color de
/// acento personalizado de toda la app. Es un singleton: se guarda
/// en el dispositivo con SharedPreferences y notifica a MaterialApp
/// cuando algo cambia para que la app se repinte con el nuevo tema.
class ThemeColorController extends ChangeNotifier {
  ThemeColorController._();
  static final ThemeColorController instance = ThemeColorController._();

  static const Color _defaultAccent = Color(0xFF1D9E75);

  ThemeMode themeMode = ThemeMode.light;
  Color accentColor = _defaultAccent;

  bool _loaded = false;
  bool get loaded => _loaded;
  bool get isDark => themeMode == ThemeMode.dark;

  static const _kTheme = 'theme_mode';
  static const _kColor = 'accent_color';

  /// Se llama una vez al iniciar la app, antes de runApp().
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeStr = prefs.getString(_kTheme);
      themeMode = switch (themeStr) {
        'dark'   => ThemeMode.dark,
        'system' => ThemeMode.system,
        _        => ThemeMode.light,
      };

      final colorValue = prefs.getInt(_kColor);
      if (colorValue != null) accentColor = Color(colorValue);
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando preferencias de tema: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode == mode) return;
    themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTheme, switch (mode) {
        ThemeMode.dark   => 'dark',
        ThemeMode.system => 'system',
        ThemeMode.light  => 'light',
      });
    } catch (_) {}
  }

  Future<void> setAccentColor(Color color) async {
    accentColor = color;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kColor, color.toARGB32());
    } catch (_) {}
  }

  Future<void> resetAccentColor() => setAccentColor(_defaultAccent);
}
