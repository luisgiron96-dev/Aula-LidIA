import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/layouts/main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedRole = 'student';
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  void _login() {
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) =>
        MainLayout(role: _selectedRole)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(children: [

              // Logo
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.school,
                  color: Colors.white, size: 32)),
              const SizedBox(height: 12),
              const Text(AppStrings.appName,
                style: TextStyle(fontSize: 22,
                  fontWeight: FontWeight.w500)),
              const Text(AppStrings.appSlogan,
                style: TextStyle(fontSize: 13,
                  color: AppColors.textSecondary)),
              const SizedBox(height: 32),

              // Selector de rol
              Row(children: [
                _RoleTab(
                  label: AppStrings.roleStudent,
                  icon: Icons.person,
                  active: _selectedRole == 'student',
                  onTap: () => setState(
                    () => _selectedRole = 'student')),
                const SizedBox(width: 8),
                _RoleTab(
                  label: AppStrings.roleTeacher,
                  icon: Icons.co_present,
                  active: _selectedRole == 'teacher',
                  onTap: () => setState(
                    () => _selectedRole = 'teacher')),
              ]),
              const SizedBox(height: 20),

              // Email
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Correo o código de usuario',
                  hintText: AppStrings.emailHint)),
              const SizedBox(height: 12),

              // Contraseña
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña')),
              const SizedBox(height: 20),

              // Botón ingresar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text(AppStrings.loginButton))),
              const SizedBox(height: 12),

              // Olvidé contraseña
              GestureDetector(
                onTap: () {},
                child: const Text(
                  '¿Olvidaste tu contraseña? Recupérala aquí',
                  style: TextStyle(fontSize: 12,
                    color: AppColors.primary))),
            ]),
          ),
        ),
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _RoleTab({required this.label, required this.icon,
    required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active
            ? AppColors.primaryLight.withOpacity(0.3)
            : Colors.grey.shade100,
          border: Border.all(
            color: active
              ? AppColors.primary
              : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16,
              color: active
                ? AppColors.primary
                : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              fontWeight: active
                ? FontWeight.w500
                : FontWeight.normal,
              color: active
                ? AppColors.primary
                : AppColors.textSecondary)),
          ]),
      ),
    ));
  }
}