import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/supabase_service.dart';
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
  bool _isLoading  = false;
  bool _showPass   = false;
  String _errorMsg = '';

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.trim().isEmpty) {
      setState(() =>
        _errorMsg = 'Por favor ingresa tu correo y contraseña');
      return;
    }

    setState(() { _isLoading = true; _errorMsg = ''; });

    try {
      final response = await SupabaseService.login(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      if (response.user != null && mounted) {
        final role = await SupabaseService.getUserRole();
        if (mounted) {
          Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) =>
              MainLayout(role: role)));
        }
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Correo o contraseña incorrectos. '
          'Verifica tus datos e intenta de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(
      text: _emailCtrl.text.trim());
    bool isLoading = false;
    bool sent = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
          title: Row(children: const [
            Icon(Icons.lock_reset,
              color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Recuperar contraseña',
              style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w500)),
          ]),
          content: sent
            ? Column(mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5EE),
                      borderRadius: BorderRadius.circular(12)),
                    child: Column(children: const [
                      Icon(Icons.mark_email_read_outlined,
                        color: AppColors.primary, size: 40),
                      SizedBox(height: 8),
                      Text('¡Correo enviado!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryDark)),
                      SizedBox(height: 4),
                      Text(
                        'Revisa tu bandeja de entrada y '
                        'sigue las instrucciones para '
                        'restablecer tu contraseña.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12,
                          color: AppColors.textSecondary)),
                    ])),
                ])
            : Column(mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ingresa tu correo institucional y te '
                    'enviaremos un enlace para restablecer '
                    'tu contraseña.',
                    style: TextStyle(fontSize: 13,
                      color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo institucional',
                      prefixIcon: Icon(Icons.email_outlined))),
                ]),
          actions: sent
            ? [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cerrar')),
              ]
            : [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (emailCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ingresa tu correo'),
                          backgroundColor: Colors.red));
                      return;
                    }
                    setStateDialog(() => isLoading = true);
                    try {
                      await SupabaseService.resetPassword(
                        emailCtrl.text.trim());
                      setStateDialog(() {
                        isLoading = false;
                        sent = true;
                      });
                    } catch (e) {
                      setStateDialog(() => isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red));
                    }
                  },
                  child: isLoading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : const Text('Enviar enlace')),
              ],
        )));
  }

  void _showRegisterDialog() {
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl  = TextEditingController();
    String role = 'student';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
          title: const Text('Crear cuenta',
            style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.w500)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  _RoleTab(label: 'Estudiante',
                    icon: Icons.person,
                    active: role == 'student',
                    onTap: () =>
                      setStateDialog(() => role = 'student')),
                  const SizedBox(width: 8),
                  _RoleTab(label: 'Docente',
                    icon: Icons.co_present,
                    active: role == 'teacher',
                    onTap: () =>
                      setStateDialog(() => role = 'teacher')),
                ]),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo institucional',
                    prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 8),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline))),
              ])),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (nameCtrl.text.trim().isEmpty ||
                    emailCtrl.text.trim().isEmpty ||
                    passCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completa todos los campos'),
                      backgroundColor: Colors.red));
                  return;
                }
                setStateDialog(() => isLoading = true);
                try {
                  await SupabaseService.register(
                    emailCtrl.text.trim(),
                    passCtrl.text.trim(),
                    nameCtrl.text.trim(),
                    role,
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '✅ Cuenta creada. Ya puedes ingresar.'),
                        backgroundColor: AppColors.primary));
                  }
                } catch (e) {
                  setStateDialog(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red));
                }
              },
              child: isLoading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                : const Text('Crear cuenta')),
          ],
        )));
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
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo institucional',
                  hintText: AppStrings.emailHint,
                  prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 12),

              // Contraseña
              TextField(
                controller: _passCtrl,
                obscureText: !_showPass,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_showPass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                    onPressed: () =>
                      setState(() => _showPass = !_showPass)))),
              const SizedBox(height: 8),

              // Error
              if (_errorMsg.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCEBEB),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(_errorMsg,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF791F1F)))),
              const SizedBox(height: 12),

              // Botón ingresar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2))
                    : const Text(AppStrings.loginButton))),
              const SizedBox(height: 12),

              // Olvidé contraseña
              GestureDetector(
                onTap: () => _showForgotPasswordDialog(),
                child: const Text(
                  '¿Olvidaste tu contraseña? Recupérala aquí',
                  style: TextStyle(fontSize: 12,
                    color: AppColors.primary))),
              const SizedBox(height: 24),

              // Registro
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta? ',
                    style: TextStyle(fontSize: 12,
                      color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => _showRegisterDialog(),
                    child: const Text('Regístrate',
                      style: TextStyle(fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500))),
                ]),
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
            ? AppColors.primaryLight.withValues(alpha: 0.3)
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
                ? FontWeight.w500 : FontWeight.normal,
              color: active
                ? AppColors.primary
                : AppColors.textSecondary)),
          ]),
      ),
    ));
  }
}