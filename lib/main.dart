import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/supabase_service.dart';
import 'core/services/theme_color_controller.dart';
import 'core/services/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/new_password_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  // Carga el tema, color de acento e idioma guardados antes de
  // dibujar la app.
  await ThemeColorController.instance.load();
  await LocaleController.instance.load();

  // Detecta si la página se abrió desde el link de "recuperar contraseña"
  // del correo. Leemos la URL directamente en vez de depender solo del
  // evento passwordRecovery, que en algunas versiones de supabase_flutter
  // para Web no se dispara de forma confiable.
  final uri = Uri.base;
  final isRecovery =
    uri.queryParameters['type'] == 'recovery' ||
    uri.fragment.contains('type=recovery');

  // Por si el evento sí llega en algunos casos, lo dejamos también como
  // respaldo.
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const NewPasswordScreen()));
    }
  });

  runApp(AulaLidIAApp(startWithRecovery: isRecovery));
}

class AulaLidIAApp extends StatelessWidget {
  final bool startWithRecovery;
  const AulaLidIAApp({super.key, this.startWithRecovery = false});

  @override
  Widget build(BuildContext context) {
    // Reconstruye toda la app cada vez que cambia el tema, el color
    // de acento o el idioma desde Configuración.
    return AnimatedBuilder(
      animation: Listenable.merge([
        ThemeColorController.instance,
        LocaleController.instance,
      ]),
      builder: (context, _) {
        final theme = ThemeColorController.instance;
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Aula Lid-IA',
          debugShowCheckedModeBanner: false,
          themeMode: theme.themeMode,
          theme: AppTheme.light(theme.accentColor),
          darkTheme: AppTheme.dark(theme.accentColor),
          home: startWithRecovery
            ? const NewPasswordScreen()
            : const LoginScreen(),
        );
      },
    );
  }
}
