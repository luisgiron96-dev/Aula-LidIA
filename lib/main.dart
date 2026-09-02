import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/new_password_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  // Escucha los eventos de autenticación. Cuando alguien entra desde el
  // link de "recuperar contraseña" del correo, Supabase dispara el evento
  // passwordRecovery — ahí lo mandamos a la pantalla de nueva contraseña.
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const NewPasswordScreen()));
    }
  });

  runApp(const AulaLidIAApp());
}

class AulaLidIAApp extends StatelessWidget {
  const AulaLidIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Aula Lid-IA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}