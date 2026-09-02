import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _updatePassword() async {
    final pass = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (pass.length < 6) {
      setState(() =>
        _error = 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: pass));

      if (!mounted) return;
      await SupabaseService.logout();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Contraseña actualizada. Inicia sesión con tu nueva contraseña.')));
    } catch (e) {
      // ignore: avoid_print
      print('Error actualizando contraseña: $e');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo actualizar la contraseña. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.lock_reset,
                    color: Colors.white, size: 32)),
                const SizedBox(height: 16),
                const Text('Crea tu nueva contraseña',
                  style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text(
                  'Ingresa y confirma tu nueva contraseña para continuar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
                const SizedBox(height: 24),

                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                      onPressed: () =>
                        setState(() => _obscure = !_obscure)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _confirmCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Confirma la contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none)),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(
                    color: Colors.red, fontSize: 12)),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                    child: _loading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                      : const Text('Guardar contraseña',
                          style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w600)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
