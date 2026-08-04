import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(const AulaLidIAApp());
}

class AulaLidIAApp extends StatelessWidget {
  const AulaLidIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aula Lid-IA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}