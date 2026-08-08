import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../auth/screens/login_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  final String userName;
  const StudentProfileScreen({super.key, this.userName = 'Estudiante'});
  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _notificationsOn = true;
  bool _offlineModeOn   = true;

  String get _avatarText {
    if (widget.userName.isEmpty) return 'VA';
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

            // Banner perfil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D9E75), Color(0xFF085041)],
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
                        color: AppColors.primary, width: 2)),
                    child: const Icon(Icons.camera_alt,
                      size: 14, color: AppColors.primary)),
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
                  child: const Text('Estudiante · Grado 7°',
                    style: TextStyle(fontSize: 12,
                      color: Colors.white))),
                const SizedBox(height: 4),
                const Text('Sede La Montañita',
                  style: TextStyle(fontSize: 12,
                    color: Colors.white70)),
              ])),
            const SizedBox(height: 16),

            // Estadísticas
            const Text('Mi progreso',
              style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(children: [
              _StatCard(number: '9', label: 'Materias',
                icon: Icons.menu_book_outlined,
                color: AppColors.primary),
              const SizedBox(width: 8),
              _StatCard(number: '24', label: 'Clases vistas',
                icon: Icons.play_circle_outline,
                color: AppColors.accent),
              const SizedBox(width: 8),
              _StatCard(number: '87%', label: 'Asistencia',
                icon: Icons.bar_chart_outlined,
                color: const Color(0xFFEF9F27)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _StatCard(number: '12', label: 'Tareas entregadas',
                icon: Icons.assignment_turned_in_outlined,
                color: const Color(0xFF534AB7)),
              const SizedBox(width: 8),
              _StatCard(number: '3', label: 'Pendientes',
                icon: Icons.assignment_outlined,
                color: const Color(0xFFEF9F27)),
              const SizedBox(width: 8),
              _StatCard(number: '68%', label: 'Progreso general',
                icon: Icons.trending_up_outlined,
                color: AppColors.primary),
            ]),
            const SizedBox(height: 16),

            // Progreso por materia
            const Text('Progreso por materia',
              style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200)),
              child: Column(children: [
                _SubjectProgress(icon: '📖',
                  name: 'Español', progress: 0.65),
                _SubjectProgress(icon: '🇬🇧',
                  name: 'Inglés', progress: 0.40),
                _SubjectProgress(icon: '🧮',
                  name: 'Matemáticas', progress: 0.80),
                _SubjectProgress(icon: '🌍',
                  name: 'Cs. Sociales', progress: 0.55),
                _SubjectProgress(icon: '🌱',
                  name: 'Cs. Naturales', progress: 0.30),
                _SubjectProgress(icon: '🕊️',
                  name: 'Cátedra Paz', progress: 0.90),
                _SubjectProgress(icon: '✝️',
                  name: 'Religión', progress: 0.50),
                _SubjectProgress(icon: '💻',
                  name: 'Informática', progress: 0.60),
                _SubjectProgress(icon: '🎧',
                  name: 'TelePsicología',
                  progress: 0.70, isLast: true),
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
                  label: 'Código de estudiante',
                  value: 'EST-2024-0042'),
                _InfoRow(icon: Icons.school_outlined,
                  label: 'Grado',
                  value: '7° — Sede La Montañita'),
                _InfoRow(icon: Icons.email_outlined,
                  label: 'Correo',
                  value: SupabaseService.currentUser?.email ?? ''),
                _InfoRow(icon: Icons.calendar_today_outlined,
                  label: 'Año lectivo',
                  value: '2025', isLast: true),
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
                  subtitle: 'Alertas de clases y tareas',
                  value: _notificationsOn,
                  onChanged: (v) =>
                    setState(() => _notificationsOn = v)),
                _SwitchRow(
                  icon: Icons.download_outlined,
                  label: 'Modo offline',
                  subtitle: 'Descargar contenido sin internet',
                  value: _offlineModeOn,
                  onChanged: (v) =>
                    setState(() => _offlineModeOn = v)),
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

class _SubjectProgress extends StatelessWidget {
  final String icon;
  final String name;
  final double progress;
  final bool isLast;
  const _SubjectProgress({required this.icon,
    required this.name, required this.progress,
    this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(
                  fontSize: 12, color: AppColors.textPrimary)),
                Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
              ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: const Color(0xFFF5F5F5),
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.primary))),
          ])),
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
          activeThumbColor: AppColors.primary),
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