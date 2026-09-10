import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controla el idioma activo de toda la app (español/inglés).
/// Es un singleton que guarda la preferencia en el dispositivo y
/// notifica a MaterialApp cuando el usuario cambia de idioma en
/// Configuración.
class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  Locale locale = const Locale('es');

  static const _kLocale = 'app_locale';

  /// Se llama una vez al iniciar la app, antes de runApp().
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_kLocale);
      if (code != null && code.isNotEmpty) {
        locale = Locale(code);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando idioma: $e');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (locale.languageCode == newLocale.languageCode) return;
    locale = newLocale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocale, newLocale.languageCode);
    } catch (_) {}
  }
}