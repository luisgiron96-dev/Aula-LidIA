import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../data/models/live_class_model.dart';
import '../controllers/live_class_controller.dart';
import 'create_live_class_screen.dart';

class LiveClassesScreen extends StatefulWidget {
  final String role; // 'student' o 'teacher'
  const LiveClassesScreen({super.key, required this.role});

  @override
  State<LiveClassesScreen> createState() => _LiveClassesScreenState();
}

class _LiveClassesScreenState extends State<LiveClassesScreen> {
  int _tab = 0; // 0 = próximas, 1 = anteriores
  List<LiveClassModel> _upcoming = [];
  List<LiveClassModel> _past = [];
  bool _loading = true;
  String? _error;

  bool get _isTeacher => widget.role == 'teacher';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final upcoming = await LiveClassController.fetchUpcoming();
      final past = await LiveClassController.fetchPast();
      if (!mounted) return;
      setState(() {
        _upcoming = upcoming;
        _past = past;
        _loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando clases en vivo: $e');
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las clases. Verifica tu conexión.';
        _loading = false;
      });
    }
  }

  Future<void> _joinClass(LiveClassModel c) async {
    final uri = Uri.tryParse(c.meetingUrl);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se pudo abrir el enlace de la clase.')));
    }
  }

  Future<void> _cancelClass(LiveClassModel c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar esta clase?'),
        content: Text('Se eliminará "${c.title}" para todos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar')),
        ]));

    if (confirm != true) return;
    try {
      await LiveClassController.cancelLiveClass(c.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se pudo cancelar la clase.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(_isTeacher ? 'Clase en vivo' : 'Clases en vivo',
          style: const TextStyle(fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined,
              color: AppColors.textSecondary),
            onPressed: _load),
        ],
      ),
      floatingActionButton: _isTeacher
        ? FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Programar clase',
              style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final created = await Navigator.push<bool>(context,
                MaterialPageRoute(
                  builder: (_) => const CreateLiveClassScreen()));
              if (created == true) _load();
            })
        : null,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            _TabBtn(label: 'Próximas', active: _tab == 0,
              onTap: () => setState(() => _tab = 0)),
            const SizedBox(width: 8),
            _TabBtn(label: 'Anteriores', active: _tab == 1,
              onTap: () => setState(() => _tab = 1)),
          ]),
        ),
        Expanded(child: _buildBody()),
      ]),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(
        color: AppColors.primary));
    }
    if (_error != null) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 40,
            color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(
            color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(onPressed: _load, child: const Text('Reintentar')),
        ]));
    }

    final list = _tab == 0 ? _upcoming : _past;

    if (list.isEmpty) {
      return Center(child: Text(
        _tab == 0
          ? 'No hay clases programadas por ahora.'
          : 'Todavía no hay clases anteriores.',
        style: const TextStyle(color: AppColors.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final c = list[i];
          final mine = c.teacherId == SupabaseService.currentUser?.id;
          return _LiveClassCard(
            liveClass: c,
            isPast: _tab == 1,
            canManage: _isTeacher && mine,
            onJoin: () => _joinClass(c),
            onCancel: () => _cancelClass(c));
        }),
    );
  }
}

class _LiveClassCard extends StatelessWidget {
  final LiveClassModel liveClass;
  final bool isPast;
  final bool canManage;
  final VoidCallback onJoin;
  final VoidCallback onCancel;
  const _LiveClassCard({
    required this.liveClass,
    required this.isPast,
    required this.canManage,
    required this.onJoin,
    required this.onCancel,
  });

  String _formatDate(DateTime d) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'a.m.' : 'p.m.';
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} · $hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final live = liveClass.isLiveNow;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: live ? Colors.red.shade200 : Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (liveClass.subjectIcon != null) ...[
              Text(liveClass.subjectIcon!,
                style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
            ],
            Expanded(child: Text(liveClass.title,
              style: const TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary))),
            if (live)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4)),
                child: const Text('EN VIVO',
                  style: TextStyle(color: Colors.white,
                    fontSize: 10, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.calendar_today_outlined,
              size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(_formatDate(liveClass.scheduledAt),
              style: const TextStyle(fontSize: 11,
                color: AppColors.textSecondary)),
            const SizedBox(width: 10),
            const Icon(Icons.timer_outlined,
              size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('${liveClass.durationMinutes} min',
              style: const TextStyle(fontSize: 11,
                color: AppColors.textSecondary)),
          ]),
          if (liveClass.teacherName != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.person_outline,
                size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(liveClass.teacherName!,
                style: const TextStyle(fontSize: 11,
                  color: AppColors.textSecondary)),
            ]),
          ],
          const SizedBox(height: 10),
          Row(children: [
            if (!isPast)
              Expanded(child: ElevatedButton.icon(
                onPressed: onJoin,
                icon: const Icon(Icons.videocam_outlined,
                  size: 16, color: Colors.white),
                label: Text(live ? 'Unirse ahora' : 'Abrir enlace',
                  style: const TextStyle(color: Colors.white,
                    fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: live
                    ? Colors.red : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))))),
            if (canManage && !isPast) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 20),
                onPressed: onCancel),
            ],
          ]),
        ]),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active,
    required this.onTap});

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
          border: Border.all(color: active
            ? AppColors.primary : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(fontSize: 12,
          color: active ? AppColors.primary : AppColors.textSecondary,
          fontWeight: active ? FontWeight.w500 : FontWeight.normal)),
      ),
    );
  }
}