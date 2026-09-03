import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import 'login_screen.dart';

class VerifyResetCodeScreen extends StatefulWidget {
  final String email;
  const VerifyResetCodeScreen({super.key, required this.email});

  @override
  State<VerifyResetCodeScreen> createState() =>
    _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _confirm() async {
    final code = _codeCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (code.length < 6) {
      setState(() => _error = 'Ingresa el código de 6 dígitos del correo.');
      return;
    }
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
      // Verifica el código: esto crea una sesión temporal de recuperación
      await SupabaseService.client.auth.verifyOTP(
        email: widget.email,
        token: code,
        type: OtpType.recovery,
      );

      // Con la sesión de recuperación activa, ya se puede cambiar la
      // contraseña
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
      print('Error verificando código: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Código incorrecto o expirado. Pide uno nuevo e '
          'inténtalo de nuevo.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
            color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context)),
      ),
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
                  child: const Icon(Icons.mark_email_read_outlined,
                    color: Colors.white, size: 32)),
                const SizedBox(height: 16),
                const Text('Verifica tu código',
                  style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(
                  'Escribe el código de 6 dígitos que enviamos a '
                  '${widget.email}, y tu nueva contraseña.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
                const SizedBox(height: 24),

                TextField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, letterSpacing: 6),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    counterText: '',
                    hintText: '000000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 12),

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
                  Text(_error!, textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red, fontSize: 12)),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                    child: _loading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                      : const Text('Confirmar y cambiar contraseña',
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
