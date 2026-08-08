import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../auth/screens/login_screen.dart';

class TeacherProfileScreen extends StatefulWidget {
  final String userName;
  const TeacherProfileScreen({super.key, this.userName = 'Docente'});
  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  bool _notificationsOn = true;
  bool _liveAlertsOn    = true;

  String get _avatarText {
    if (widget.userName.isEmpty) return 'MP';
    final parts = widget.userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.userName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Mi perfil',
          style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined,
              size: 16, color: AppColors.primary),
            label: const Text('Editar',
              style: TextStyle(fontSize: 13,
                color: AppColors.primary))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Banner perfil docente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF185FA5), Color(0xFF0D3D6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Stack(alignment: Alignment.bottomRight, children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(_avatarText,
                      style: const TextStyle(fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.white))),
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent, width: 2)),
                    child: const Icon(Icons.camera_alt,
                      size: 14, color: AppColors.accent)),
                ]),
                const SizedBox(height: 12),
                Text(widget.userName,
                  style: const TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20)),
                  child: const Text('Docente · Matemáticas',
                    style: TextStyle(fontSize: 12,
                      color: Colors.white))),
                const SizedBox(height: 4),
                const Text('Sede La Montañita',
                  style: TextStyle(fontSize: 12,
                    color: Colors.white70)),
              ])),
            const SizedBox(height: 16),

            // Estadísticas
            const Text('Mis estadísticas',
              style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(children: [
              _StatCard(number: '34', label: 'Estudiantes',
                icon: Icons.people_outline,
                color: AppColors.primary),
              const SizedBox(width: 8),
              _StatCard(number: '12', label: 'Videos subidos',
                icon: Icons.video_library_outlined,
                color: AppColors.accent),
              const SizedBox(width: 8),
              _StatCard(number: '87%', label: 'Asistencia',
                icon: Icons.bar_chart_outlined,
                color: const Color(0xFFEF9F27)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _StatCard(number: '48', label: 'Clases dictadas',
                icon: Icons.cast_for_education_outlined,
                color: const Color(0xFF534AB7)),
              const SizedBox(width: 8),
              _StatCard(number: '142', label: 'Reproducciones',
                icon: Icons.play_circle_outline,
                color: AppColors.primary),
              const SizedBox(width: 8),
              _StatCard(number: '4.8', label: 'Calificación',
                icon: Icons.star_outline,
                color: const Color(0xFFEF9F27)),
            ]),
            const SizedBox(height: 16),

            // Materias
            const Text('Materias que dicto',
              style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200)),
              child: Column(children: [
                _SubjectRow(icon: '🧮',
                  name: 'Matemáticas',
                  grades: 'Grados 6° y 7°',
                  students: 34),
                _SubjectRow(icon: '🌱',
                  name: 'Cs. Naturales',
                  grades: 'Grado 5°',
                  students: 28,
                  isLast: true),
              ])),
            const SizedBox(height: 16),

            // Información personal
            const Text('Información personal',
              style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200)),
              child: Column(children: [
                _InfoRow(icon: Icons.person_outline,
                  label: 'Nombre completo',
                  value: widget.userName),
                _InfoRow(icon: Icons.badge_outlined,
                  label: 'Código docente',
                  value: 'DOC-2020-0015'),
                _InfoRow(icon: Icons.school_outlined,
                  label: 'Sede',
                  value: 'Sede La Montañita'),
                _InfoRow(icon: Icons.email_outlined,
                  label: 'Correo',
                  value: SupabaseService.currentUser?.email ?? ''),
                _InfoRow(icon: Icons.calendar_today_outlined,
                  label: 'Vinculación',
                  value: 'Desde 2020', isLast: true),
              ])),
            const SizedBox(height: 16),

            // Configuración
            const Text('Configuración',
              style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200)),
              child: Column(children: [
                _SwitchRow(
                  icon: Icons.notifications_outlined,
                  label: 'Notificaciones',
                  subtitle: 'Alertas de actividad estudiantil',
                  value: _notificationsOn,
                  onChanged: (v) =>
                    setState(() => _notificationsOn = v)),
                _SwitchRow(
                  icon: Icons.live_tv_outlined,
                  label: 'Alertas de clase en vivo',
                  subtitle: 'Notificar antes de iniciar clase',
                  value: _liveAlertsOn,
                  onChanged: (v) =>
                    setState(() => _liveAlertsOn = v)),
                _ActionRow(
                  icon: Icons.lock_outline,
                  label: 'Cambiar contraseña',
                  onTap: () {}),
                _ActionRow(
                  icon: Icons.help_outline,
                  label: 'Ayuda y soporte',
                  onTap: () {}),
                _ActionRow(
                  icon: Icons.logout,
                  label: 'Cerrar sesión',
                  isRed: true,
                  isLast: true,
                  onTap: () async {
                    await SupabaseService.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                        (route) => false);
                    }
                  }),
              ])),
            const SizedBox(height: 24),

            const Center(
              child: Text('Aula Lid-IA v1.0.0',
                style: TextStyle(fontSize: 11,
                  color: AppColors.textSecondary))),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── WIDGETS ───────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.number, required this.label,
    required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(number, style: TextStyle(fontSize: 18,
          fontWeight: FontWeight.w500, color: color)),
        Text(label,
          style: const TextStyle(fontSize: 9,
            color: AppColors.textSecondary),
          textAlign: TextAlign.center),
      ]),
    ));
  }
}

class _SubjectRow extends StatelessWidget {
  final String icon;
  final String name;
  final String grades;
  final int students;
  final bool isLast;
  const _SubjectRow({required this.icon, required this.name,
    required this.grades, required this.students,
    this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
            Text(grades, style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary)),
          ])),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE1F5EE),
            borderRadius: BorderRadius.circular(8)),
          child: Text('$students estudiantes',
            style: const TextStyle(fontSize: 10,
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow({required this.icon, required this.label,
    required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
              fontSize: 10, color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(
              fontSize: 13, color: AppColors.textPrimary)),
          ])),
      ]),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  const _SwitchRow({required this.icon, required this.label,
    required this.subtitle, required this.value,
    required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
              fontSize: 13, color: AppColors.textPrimary)),
            Text(subtitle, style: const TextStyle(
              fontSize: 10, color: AppColors.textSecondary)),
          ])),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.accent),
      ]),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isRed;
  final bool isLast;
  const _ActionRow({required this.icon, required this.label,
    required this.onTap, this.isRed = false,
    this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : Border(
            bottom: BorderSide(color: Colors.grey.shade100))),
        child: Row(children: [
          Icon(icon, size: 18,
            color: isRed ? Colors.red : AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
            style: TextStyle(fontSize: 13,
              color: isRed
                ? Colors.red : AppColors.textPrimary))),
          Icon(Icons.chevron_right,
            size: 18, color: Colors.grey.shade400),
        ]),
      ),
    );
  }
}