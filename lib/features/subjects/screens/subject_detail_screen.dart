import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String icon;
  final String name;
  final double progress;

  const SubjectDetailScreen({
    super.key,
    required this.icon,
    required this.name,
    required this.progress,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  int _tabIndex = 0;

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
        title: Row(children: [
          Text(widget.icon,
            style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(widget.name,
            style: const TextStyle(fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search,
              color: AppColors.textSecondary),
            onPressed: () {}),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Banner de progreso
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D9E75), Color(0xFF085041)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.name,
                        style: const TextStyle(fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                      Text(widget.icon,
                        style: const TextStyle(fontSize: 32)),
                    ]),
                  const SizedBox(height: 8),
                  const Text('Tu progreso en esta materia',
                    style: TextStyle(fontSize: 12,
                      color: Colors.white70)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.progress,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.white))),
                  const SizedBox(height: 4),
                  Text(
                    '${(widget.progress * 100).toInt()}% completado',
                    style: const TextStyle(fontSize: 11,
                      color: Colors.white70)),
                ]),
            ),
            const SizedBox(height: 16),

            // Pestañas
            Row(children: [
              _TabBtn(label: 'Videos',
                icon: Icons.play_circle_outline,
                active: _tabIndex == 0,
                onTap: () => setState(() => _tabIndex = 0)),
              const SizedBox(width: 8),
              _TabBtn(label: 'Actividades',
                icon: Icons.assignment_outlined,
                active: _tabIndex == 1,
                onTap: () => setState(() => _tabIndex = 1)),
              const SizedBox(width: 8),
              _TabBtn(label: 'Recursos',
                icon: Icons.folder_outlined,
                active: _tabIndex == 2,
                onTap: () => setState(() => _tabIndex = 2)),
            ]),
            const SizedBox(height: 12),

            // Contenido pestañas
            if (_tabIndex == 0) _VideosTab(subjectName: widget.name),
            if (_tabIndex == 1) _ActivitiesTab(),
            if (_tabIndex == 2) _ResourcesTab(),
          ],
        ),
      ),
    );
  }
}

// ── PESTAÑA VIDEOS ────────────────────────────────────
class _VideosTab extends StatelessWidget {
  final String subjectName;
  const _VideosTab({required this.subjectName});

  @override
  Widget build(BuildContext context) {
    final videos = [
      {'title': 'Clase 1 — Introducción',
        'duration': '18 min', 'viewed': true},
      {'title': 'Clase 2 — Conceptos base',
        'duration': '22 min', 'viewed': true},
      {'title': 'Clase 3 — Ejercicios prácticos',
        'duration': '15 min', 'viewed': false},
      {'title': 'Clase 4 — Resolución de problemas',
        'duration': '25 min', 'viewed': false},
      {'title': 'Clase 5 — Repaso general',
        'duration': '12 min', 'viewed': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${videos.length} videos disponibles',
          style: const TextStyle(fontSize: 12,
            color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        ...videos.map((v) => _VideoCard(
          title: v['title'] as String,
          duration: v['duration'] as String,
          viewed: v['viewed'] as bool,
          subjectName: subjectName,
        )).toList(),
      ],
    );
  }
}

// ── PESTAÑA ACTIVIDADES ───────────────────────────────
class _ActivitiesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activities = [
      {'title': 'Taller cap. 1', 'due': 'Vence: hoy',
        'status': 'pendiente'},
      {'title': 'Quiz unidad 1', 'due': 'Vence: viernes',
        'status': 'pendiente'},
      {'title': 'Tarea cap. 2', 'due': 'Entregado',
        'status': 'entregado'},
      {'title': 'Proyecto final', 'due': 'Vence: 15 ago',
        'status': 'pendiente'},
    ];

    return Column(
      children: activities.map((a) {
        final bool done = a['status'] == 'entregado';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200)),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: done
                  ? const Color(0xFFE1F5EE)
                  : const Color(0xFFFAEEDA),
                borderRadius: BorderRadius.circular(8)),
              child: Icon(
                done
                  ? Icons.check_circle_outline
                  : Icons.assignment_outlined,
                size: 18,
                color: done
                  ? AppColors.primary
                  : const Color(0xFFEF9F27))),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a['title']!,
                  style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
                Text(a['due']!,
                  style: TextStyle(fontSize: 11,
                    color: done
                      ? AppColors.primary
                      : const Color(0xFFEF9F27))),
              ])),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: done
                  ? const Color(0xFFE1F5EE)
                  : const Color(0xFFFAEEDA),
                borderRadius: BorderRadius.circular(8)),
              child: Text(
                done ? 'Entregado ✓' : 'Pendiente',
                style: TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: done
                    ? AppColors.primaryDark
                    : const Color(0xFF633806)))),
          ]),
        );
      }).toList(),
    );
  }
}

// ── PESTAÑA RECURSOS ──────────────────────────────────
class _ResourcesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final resources = [
      {'name': 'Guía de estudio unidad 1', 'type': 'PDF',
        'size': '2.4 MB'},
      {'name': 'Presentación clase 2', 'type': 'PPTX',
        'size': '5.1 MB'},
      {'name': 'Ejercicios complementarios', 'type': 'PDF',
        'size': '1.2 MB'},
      {'name': 'Mapa conceptual', 'type': 'IMG',
        'size': '0.8 MB'},
    ];

    return Column(
      children: resources.map((r) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.insert_drive_file_outlined,
              size: 18, color: Color(0xFF185FA5))),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r['name']!,
                style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
              Text('${r['type']} · ${r['size']}',
                style: const TextStyle(fontSize: 11,
                  color: AppColors.textSecondary)),
            ])),
          IconButton(
            icon: const Icon(Icons.download_outlined,
              size: 20, color: AppColors.textSecondary),
            onPressed: () {}),
        ]),
      )).toList(),
    );
  }
}

// ── WIDGETS ───────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final bool viewed;
  final String subjectName;
  const _VideoCard({required this.title, required this.duration,
    required this.viewed, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [

        // Miniatura video
        Container(
          width: 90, height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFF085041),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10))),
          child: Stack(alignment: Alignment.center, children: [
            Icon(Icons.play_circle_outline,
              color: Colors.white.withOpacity(0.9), size: 28),
            if (viewed)
              Positioned(
                top: 6, right: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle),
                  child: const Icon(Icons.check,
                    size: 10, color: Colors.white))),
          ])),

        // Info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.access_time,
                    size: 11, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(duration,
                    style: const TextStyle(fontSize: 10,
                      color: AppColors.textSecondary)),
                  const SizedBox(width: 10),
                  if (viewed)
                    const Text('Visto ✓',
                      style: TextStyle(fontSize: 10,
                        color: AppColors.primary)),
                ]),
              ])),
        ),

        // Botón reproducir
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6)),
            child: const Text('Ver',
              style: TextStyle(fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500)))),
      ]),
    );
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
        padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
            ? AppColors.primaryLight.withOpacity(0.3)
            : Colors.white,
          border: Border.all(
            color: active
              ? AppColors.primary
              : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14,
            color: active
              ? AppColors.primary
              : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12,
            color: active
              ? AppColors.primary
              : AppColors.textSecondary,
            fontWeight: active
              ? FontWeight.w500
              : FontWeight.normal)),
        ]),
      ),
    );
  }
}