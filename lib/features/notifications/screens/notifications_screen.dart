import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/notification_model.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filterIndex = 0;
  List<NotificationModel> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await NotificationsController.fetchAll();
      if (!mounted) return;
      setState(() {
        _notifications = list;
        _loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando notificaciones: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<NotificationModel> get _filtered {
    if (_filterIndex == 0) return _notifications;
    if (_filterIndex == 1) {
      return _notifications.where((n) => !n.read).toList();
    }
    final types = ['live', 'task', 'video', 'grade'];
    final typeIndex = _filterIndex - 2;
    if (typeIndex < 0 || typeIndex >= types.length) return _notifications;
    return _notifications
      .where((n) => n.type == types[typeIndex])
      .toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> _markAllRead() async {
    setState(() {
      _notifications = _notifications
        .map((n) => NotificationModel(id: n.id, type: n.type,
          title: n.title, body: n.body, read: true,
          createdAt: n.createdAt))
        .toList();
    });
    try {
      await NotificationsController.markAllRead();
    } catch (e) {
      // ignore: avoid_print
      print('Error marcando notificaciones: $e');
    }
  }

  Future<void> _markOneRead(NotificationModel n) async {
    if (n.read) return;
    setState(() {
      _notifications = _notifications.map((item) =>
        item.id == n.id
          ? NotificationModel(id: item.id, type: item.type,
              title: item.title, body: item.body, read: true,
              createdAt: item.createdAt)
          : item).toList();
    });
    try {
      await NotificationsController.markRead(n.id);
    } catch (e) {
      // ignore: avoid_print
      print('Error marcando notificación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: MediaQuery.of(context).size.width < 700 ? null : AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
            color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          const Text('Notificaciones',
            style: TextStyle(fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10)),
              child: Text('$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500))),
          ],
        ]),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Marcar todo leído',
              style: TextStyle(fontSize: 12,
                color: AppColors.primary))),
        ],
      ),
      body: Column(children: [

        // Filtros
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _FilterChip(label: 'Todas',
                active: _filterIndex == 0,
                onTap: () => setState(() => _filterIndex = 0)),
              const SizedBox(width: 8),
              _FilterChip(label: 'Sin leer',
                active: _filterIndex == 1,
                onTap: () => setState(() => _filterIndex = 1)),
              const SizedBox(width: 8),
              _FilterChip(label: 'Clases',
                active: _filterIndex == 2,
                onTap: () => setState(() => _filterIndex = 2)),
              const SizedBox(width: 8),
              _FilterChip(label: 'Tareas',
                active: _filterIndex == 3,
                onTap: () => setState(() => _filterIndex = 3)),
              const SizedBox(width: 8),
              _FilterChip(label: 'Videos',
                active: _filterIndex == 4,
                onTap: () => setState(() => _filterIndex = 4)),
              const SizedBox(width: 8),
              _FilterChip(label: 'Notas',
                active: _filterIndex == 5,
                onTap: () => setState(() => _filterIndex = 5)),
            ]),
          ),
        ),

        // Lista
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(
                color: AppColors.primary))
            : _filtered.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                        size: 48, color: AppColors.textSecondary),
                      SizedBox(height: 12),
                      Text('No hay notificaciones',
                        style: TextStyle(fontSize: 14,
                          color: AppColors.textSecondary)),
                    ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final n = _filtered[i];
                      return _NotificationCard(
                        type: n.type,
                        title: n.title,
                        body: n.body,
                        time: n.timeAgo,
                        read: n.read,
                        onTap: () => _markOneRead(n),
                      );
                    })),
        ),
      ]),
    );
  }
}

// ── WIDGETS ───────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final String type;
  final String title;
  final String body;
  final String time;
  final bool read;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.type, required this.title,
    required this.body, required this.time,
    required this.read, required this.onTap,
  });

  IconData get _icon {
    switch (type) {
      case 'live':  return Icons.videocam_outlined;
      case 'task':  return Icons.assignment_outlined;
      case 'video': return Icons.play_circle_outline;
      case 'grade': return Icons.grade_outlined;
      default:      return Icons.notifications_outlined;
    }
  }

  Color get _color {
    switch (type) {
      case 'live':  return AppColors.primary;
      case 'task':  return const Color(0xFFEF9F27);
      case 'video': return const Color(0xFF378ADD);
      case 'grade': return const Color(0xFF534AB7);
      default:      return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: read ? Colors.white : _color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: read
              ? Colors.grey.shade200
              : _color.withOpacity(0.3))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(_icon, color: _color, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: read
                          ? FontWeight.normal
                          : FontWeight.w500,
                        color: AppColors.textPrimary))),
                  if (!read)
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: _color,
                        shape: BoxShape.circle)),
                ]),
                const SizedBox(height: 3),
                Text(body,
                  style: const TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Text(time,
                  style: const TextStyle(fontSize: 10,
                    color: AppColors.textSecondary)),
              ])),
        ]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({required this.label,
    required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active
            ? AppColors.primary
            : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
              ? AppColors.primary
              : Colors.grey.shade300)),
        child: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active
              ? FontWeight.w500
              : FontWeight.normal,
            color: active
              ? Colors.white
              : AppColors.textSecondary)),
      ),
    );
  }
}