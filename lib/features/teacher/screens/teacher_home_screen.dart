import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../live_class/screens/live_class_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});
  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.school, color: Colors.white, size: 18)),
          const SizedBox(width: 8),
          const Text('Aula Lid-IA · Docente',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textSecondary),
            onPressed: () {}),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.teacherColor,
            child: Text('MP',
              style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.accent))),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Banner docente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF185FA5), Color(0xFF0D3D6B)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('¡Hola, Prof. Mariela! 👋',
                        style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Tienes 1 clase programada hoy',
                        style: TextStyle(fontSize: 12,
                          color: Colors.white70)),
                    ]),
                  const Text('👩🏽‍🏫', style: TextStyle(fontSize: 36)),
                ]),
            ),
            const SizedBox(height: 16),

            // Estadísticas
            Row(children: [
              _StatCard(number: '34', label: 'Estudiantes',
                icon: Icons.people_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              _StatCard(number: '12', label: 'Videos subidos',
                icon: Icons.video_library_outlined, color: AppColors.accent),
              const SizedBox(width: 8),
              _StatCard(number: '87%', label: 'Asistencia',
                icon: Icons.bar_chart_outlined,
                color: const Color(0xFFEF9F27)),
            ]),
            const SizedBox(height: 16),

            // Pestañas
            Row(children: [
              _TabBtn(label: 'Subir contenido',
                icon: Icons.upload_outlined,
                active: _tabIndex == 0,
                onTap: () => setState(() => _tabIndex = 0)),
              const SizedBox(width: 8),
              _TabBtn(label: 'Clase en vivo',
                icon: Icons.videocam_outlined,
                active: _tabIndex == 1,
                onTap: () => setState(() => _tabIndex = 1)),
              const SizedBox(width: 8),
              _TabBtn(label: 'Estudiantes',
                icon: Icons.people_outline,
                active: _tabIndex == 2,
                onTap: () => setState(() => _tabIndex = 2)),
            ]),
            const SizedBox(height: 12),

            // Contenido de pestañas
            if (_tabIndex == 0) _UploadTab(),
            if (_tabIndex == 1) _LiveTab(),
            if (_tabIndex == 2) _StudentsTab(),
          ],
        ),
      ),
    );
  }
}

// ── PESTAÑA: SUBIR CONTENIDO ──────────────────────────
class _UploadTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.4),
            width: 1.5)),
        child: Column(children: [
          const Icon(Icons.cloud_upload_outlined,
            size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          const Text('Arrastra tu video o actividad aquí',
            style: TextStyle(fontSize: 13,
              color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          const Text('MP4 · AVI · MOV · PDF · PPTX · hasta 2 GB',
            style: TextStyle(fontSize: 11,
              color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.folder_outlined, size: 14),
              label: const Text('Explorar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: Colors.grey.shade300))),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload, size: 14),
              label: const Text('Subir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 36))),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      const Text('Contenido reciente',
        style: TextStyle(fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      _VideoItem(title: 'Fracciones — Clase 1',
        subject: 'Matemáticas · 7° · 18 min', views: '142 vistas',
        icon: Icons.play_circle_outline),
      _VideoItem(title: 'Decimales — Repaso',
        subject: 'Matemáticas · 6° · 12 min', views: '98 vistas',
        icon: Icons.play_circle_outline),
      _VideoItem(title: 'Taller cap. 3 — PDF',
        subject: 'Matemáticas · 7° · Actividad', views: '34 entregas',
        icon: Icons.picture_as_pdf_outlined),
    ]);
  }
}

// ── PESTAÑA: CLASE EN VIVO ────────────────────────────
class _LiveTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
        child: Column(children: [
          Container(
            width: double.infinity, height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2A),
              borderRadius: BorderRadius.circular(8)),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_off_outlined,
                  color: Colors.white38, size: 32),
                SizedBox(height: 6),
                Text('Cámara apagada',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              ])),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _CtrlBtn(icon: Icons.mic_outlined, label: 'Micrófono'),
              _CtrlBtn(icon: Icons.videocam_outlined, label: 'Cámara'),
              _CtrlBtn(icon: Icons.screen_share_outlined, label: 'Compartir'),
              _CtrlBtn(icon: Icons.chat_outlined, label: 'Chat'),
              _CtrlBtn(icon: Icons.call_end_outlined,
                label: 'Terminar', isRed: true),
            ]),
        ]),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(
                builder: (_) => const LiveClassScreen())),
            icon: const Icon(Icons.broadcast_on_home_outlined, size: 16),
            label: const Text('Iniciar clase ahora'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44)))),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.calendar_month_outlined, size: 16),
          label: const Text('Programar'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(color: Colors.grey.shade300))),
      ]),
    ]);
  }
}

// ── PESTAÑA: ESTUDIANTES ──────────────────────────────
class _StudentsTab extends StatelessWidget {
  final List<Map<String, dynamic>> students = const [
    {'initials': 'VA', 'name': 'Valentina A.', 'progress': 80,
      'color': Color(0xFF9FE1CB), 'textColor': Color(0xFF0F6E56)},
    {'initials': 'CR', 'name': 'Carlos R.', 'progress': 45,
      'color': Color(0xFFB5D4F4), 'textColor': Color(0xFF185FA5)},
    {'initials': 'LM', 'name': 'Luisa M.', 'progress': 92,
      'color': Color(0xFFEEEDFE), 'textColor': Color(0xFF534AB7)},
    {'initials': 'JT', 'name': 'Juan T.', 'progress': 30,
      'color': Color(0xFFFAEEDA), 'textColor': Color(0xFF633806)},
    {'initials': 'SR', 'name': 'Sara R.', 'progress': 76,
      'color': Color(0xFFFAECE7), 'textColor': Color(0xFF993C1D)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: students.map((s) => _StudentRow(
          initials: s['initials'],
          name: s['name'],
          progress: s['progress'],
          avatarColor: s['color'],
          textColor: s['textColor'],
        )).toList(),
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
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(number, style: TextStyle(fontSize: 22,
          fontWeight: FontWeight.w500, color: color)),
        Text(label, style: const TextStyle(fontSize: 10,
          color: AppColors.textSecondary),
          textAlign: TextAlign.center),
      ]),
    ));
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.icon,
    required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
            ? AppColors.primaryLight.withOpacity(0.3)
            : Colors.white,
          border: Border.all(
            color: active ? AppColors.primary : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14,
            color: active ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12,
            color: active ? AppColors.primary : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w500 : FontWeight.normal)),
        ]),
      ),
    );
  }
}

class _VideoItem extends StatelessWidget {
  final String title;
  final String subject;
  final String views;
  final IconData icon;
  const _VideoItem({required this.title, required this.subject,
    required this.views, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Container(
          width: 44, height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, color: AppColors.primaryDark, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
            Text(subject, style: const TextStyle(fontSize: 10,
              color: AppColors.textSecondary)),
          ])),
        Text(views, style: const TextStyle(fontSize: 10,
          color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isRed;
  const _CtrlBtn({required this.icon, required this.label,
    this.isRed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isRed
          ? const Color(0xFFFCEBEB)
          : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRed
            ? const Color(0xFFF09595)
            : Colors.grey.shade300)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16,
          color: isRed
            ? const Color(0xFF791F1F)
            : AppColors.textPrimary),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12,
          color: isRed
            ? const Color(0xFF791F1F)
            : AppColors.textPrimary)),
      ]),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final String initials;
  final String name;
  final int progress;
  final Color avatarColor;
  final Color textColor;
  const _StudentRow({required this.initials, required this.name,
    required this.progress, required this.avatarColor,
    required this.textColor});

  @override
  Widget build(BuildContext context) {
    final bool isLow = progress < 50;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: avatarColor,
          child: Text(initials,
            style: TextStyle(fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor))),
        const SizedBox(width: 10),
        Expanded(child: Text(name,
          style: const TextStyle(fontSize: 12,
            color: AppColors.textPrimary))),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: isLow
              ? const Color(0xFFFAEEDA)
              : const Color(0xFFE1F5EE),
            borderRadius: BorderRadius.circular(10)),
          child: Text('$progress% ${isLow ? "⚠" : "✓"}',
            style: TextStyle(fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isLow
                ? const Color(0xFF633806)
                : AppColors.primaryDark))),
      ]),
    );
  }
}