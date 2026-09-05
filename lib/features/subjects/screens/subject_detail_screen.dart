import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/video_model.dart';
import '../controllers/subject_controller.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String subjectId;
  final String icon;
  final String name;
  final double progress;

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
    required this.icon,
    required this.name,
    required this.progress,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  int _tabIndex = 0;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
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
        title: Row(children: [
          Text(widget.icon,
            style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(widget.name,
            style: const TextStyle(fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
        ]),
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
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.white))),
                  const SizedBox(height: 4),
                  Text(
                    '${(_progress * 100).toInt()}% completado',
                    style: const TextStyle(fontSize: 11,
                      color: Colors.white70)),
                ]),
            ),
            const SizedBox(height: 16),

            // Pestañas
            Row(children: [
              _TabBtn(label: 'Contenido',
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
            if (_tabIndex == 0) _VideosTab(
              subjectId: widget.subjectId,
              onProgressChanged: (p) => setState(() => _progress = p)),
            if (_tabIndex == 1) const _ComingSoonTab(
              text: 'Las actividades y talleres estarán disponibles pronto.'),
            if (_tabIndex == 2) const _ComingSoonTab(
              text: 'Los recursos descargables estarán disponibles pronto.'),
          ],
        ),
      ),
    );
  }
}

// ── PESTAÑA VIDEOS (datos reales de Supabase) ─────────
class _VideosTab extends StatefulWidget {
  final String subjectId;
  final ValueChanged<double> onProgressChanged;
  const _VideosTab({required this.subjectId,
    required this.onProgressChanged});

  @override
  State<_VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<_VideosTab> {
  List<VideoModel> _videos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() { _loading = true; _error = null; });
    try {
      final videos = await SubjectController.fetchLessons(widget.subjectId);
      if (!mounted) return;
      setState(() {
        _videos = videos;
        _loading = false;
      });
      _reportProgress();
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando videos: $e');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los videos.';
        _loading = false;
      });
    }
  }

  void _reportProgress() {
    if (_videos.isEmpty) return;
    final viewedCount = _videos.where((v) => v.viewed).length;
    widget.onProgressChanged(viewedCount / _videos.length);
  }

  Future<void> _downloadContent(VideoModel video) async {
    final url = video.videoUrl;
    if (url == null || url.isEmpty) return;

    // Supabase Storage descarga el archivo (en vez de mostrarlo en el
    // navegador) si se le agrega el parámetro "download" a la URL pública.
    final downloadUrl =
      '$url${url.contains('?') ? '&' : '?'}download';

    final ok = await launchUrl(Uri.parse(downloadUrl),
      mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se pudo descargar el archivo')));
    }
  }

  Future<void> _openContent(VideoModel video) async {
    if (!video.viewed) {
      // Optimista: actualiza la UI antes de esperar la respuesta del servidor
      setState(() {
        _videos = _videos.map((v) =>
          v.id == video.id ? v.copyWith(viewed: true) : v).toList();
      });
      _reportProgress();
      try {
        await SubjectController.markLessonViewed(video.id);
      } catch (e) {
        // ignore: avoid_print
        print('Error guardando progreso: $e');
      }
    }

    final url = video.videoUrl;
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Este contenido no tiene un archivo asociado')));
      return;
    }

    // PDF y PPTX se abren en la app externa del dispositivo.
    // El video, por ahora, también se abre externamente (falta un
    // reproductor embebido tipo video_player/chewie).
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se pudo abrir el archivo')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(
          color: AppColors.primary)));
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Column(children: [
          Text(_error!,
            style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextButton(onPressed: _loadVideos,
            child: const Text('Reintentar')),
        ])),
      );
    }
    if (_videos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text(
          'Todavía no hay contenido para esta materia.',
          style: TextStyle(color: AppColors.textSecondary))));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${_videos.length} elementos disponibles',
          style: const TextStyle(fontSize: 12,
            color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        ..._videos.map((v) => _VideoCard(
          video: v,
          onTap: () => _openContent(v),
          onDownload: () => _downloadContent(v),
        )),
      ],
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  final String text;
  const _ComingSoonTab({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(child: Column(children: [
        const Icon(Icons.hourglass_empty,
          size: 32, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Text(text, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12,
            color: AppColors.textSecondary)),
      ])),
    );
  }
}

// ── WIDGETS ───────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;
  final VoidCallback? onDownload;
  const _VideoCard({required this.video, required this.onTap,
    this.onDownload});

  IconData get _icon {
    switch (video.tipo) {
      case 'pdf': return Icons.picture_as_pdf_outlined;
      case 'pptx': return Icons.slideshow_outlined;
      case 'video': return Icons.play_circle_outline;
      default: return Icons.insert_drive_file_outlined;
    }
  }

  Color get _thumbColor {
    switch (video.tipo) {
      case 'pdf': return const Color(0xFF8A2C2C);
      case 'pptx': return const Color(0xFF9A5A16);
      default: return const Color(0xFF085041);
    }
  }

  String get _actionLabel => video.tipo == 'video' ? 'Ver' : 'Abrir';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [

        // Miniatura
        Container(
          width: 90, height: 68,
          decoration: BoxDecoration(
            color: _thumbColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10))),
          child: Stack(alignment: Alignment.center, children: [
            Icon(_icon,
              color: Colors.white.withOpacity(0.9), size: 28),
            if (video.viewed)
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
                Text(video.title,
                  style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Row(children: [
                  if (video.tipo == 'video') ...[
                    const Icon(Icons.access_time,
                      size: 11, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text('${video.durationMinutes} min',
                      style: const TextStyle(fontSize: 10,
                        color: AppColors.textSecondary)),
                    const SizedBox(width: 10),
                  ],
                  if (video.viewed)
                    const Text('Visto ✓',
                      style: TextStyle(fontSize: 10,
                        color: AppColors.primary)),
                ]),
              ])),
        ),

        // Botón reproducir
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6)),
              child: Text(_actionLabel,
                style: const TextStyle(fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w500))))),

        // Botón descargar (solo pdf/pptx, para poder usarlos sin conexión)
        if (onDownload != null &&
            (video.tipo == 'pdf' || video.tipo == 'pptx'))
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: onDownload,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.download_outlined,
                    size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  const Text('Descargar',
                    style: TextStyle(fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500)),
                ])))),
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