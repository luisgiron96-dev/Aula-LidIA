import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';

class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({super.key});

  @override
  State<UpdateEmailScreen> createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  late final TextEditingController _emailCtrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(
      text: SupabaseService.currentUser?.email ?? '');
  }

  Future<void> _save() async {
    final email = _emailCtrl.text.trim();
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!valid) {
      setState(() => _error = 'Ingresa un correo válido.');
      return;
    }
    if (email == SupabaseService.currentUser?.email) {
      setState(() => _error = 'Ese ya es tu correo actual.');
      return;
    }

    setState(() { _saving = true; _error = null; });

    try {
      await SupabaseService.updateEmail(email);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Te enviamos un correo de confirmación a la '
          'nueva dirección. El cambio se aplicará cuando lo confirmes.'),
        duration: Duration(seconds: 5)));
    } catch (e) {
      // ignore: avoid_print
      print('Error actualizando correo: $e');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo actualizar el correo. Intenta de nuevo.';
        _saving = false;
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
        title: const Text('Correo electrónico',
          style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nuevo correo electrónico',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none))),

            const SizedBox(height: 8),
            const Text(
              'Te enviaremos un enlace de confirmación a la nueva '
              'dirección antes de aplicar el cambio.',
              style: TextStyle(fontSize: 11.5,
                color: AppColors.textSecondary)),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(
                color: Colors.red, fontSize: 12)),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
                child: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                  : const Text('Guardar',
                      style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w600)))),
          ],
        ),
      ),
    );
  }
}
