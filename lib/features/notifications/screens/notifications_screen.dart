import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _filterIndex = 0;

  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'live',
      'title': 'Clase en vivo ahora',
      'body': 'Prof. Mariela inició la clase de Matemáticas',
      'time': 'Hace 2 min',
      'read': false,
    },
    {
      'type': 'task',
      'title': 'Tarea próxima a vencer',
      'body': 'Ejercicios cap. 3 vence hoy a las 11:59 pm',
      'time': 'Hace 1 hora',
      'read': false,
    },
    {
      'type': 'video',
      'title': 'Nuevo video disponible',
      'body': 'Prof. Mariela subió: Fracciones — Clase 4',
      'time': 'Hace 3 horas',
      'read': false,
    },
    {
      'type': 'message',
      'title': 'Mensaje de tu docente',
      'body': 'Recuerden entregar el taller antes del viernes',
      'time': 'Ayer 4:30 pm',
      'read': true,
    },
    {
      'type': 'task',
      'title': 'Tarea entregada',
      'body': 'Tu tarea de Español fue recibida correctamente ✓',
      'time': 'Ayer 2:15 pm',
      'read': true,
    },
    {
      'type': 'live',
      'title': 'Clase programada',
      'body': 'Mañana a las 9:00 am — Cs. Naturales con Prof. García',
      'time': 'Ayer 10:00 am',
      'read': true,
    },
    {
      'type': 'video',
      'title': 'Nuevo recurso disponible',
      'body': 'Se agregó una guía de estudio en Inglés — Unit 2',
      'time': 'Hace 2 días',
      'read': true,
    },
    {
      'type': 'message',
      'title': 'Felicitaciones',
      'body': 'Obtuviste 95% en el quiz de Matemáticas 🎉',
      'time': 'Hace 3 días',
      'read': true,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filterIndex == 0) return _notifications;
    if (_filterIndex == 1) {
      return _notifications.where((n) => !n['read']).toList();
    }
    final types = ['live', 'task', 'video', 'message'];
    final typeIndex = _filterIndex - 2;
    if (typeIndex < 0 || typeIndex >= types.length) return _notifications;
    return _notifications
      .where((n) => n['type'] == types[typeIndex])
      .toList();
  }

  int get _unreadCount =>
    _notifications.where((n) => !n['read']).length;

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['read'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // En móvil la barra superior ya la muestra MainLayout, así que aquí
      // solo se dibuja en escritorio (donde MainLayout no tiene barra propia).
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
              _FilterChip(label: 'Mensajes',
                active: _filterIndex == 5,
                onTap: () => setState(() => _filterIndex = 5)),
            ]),
          ),
        ),

        // Lista
        Expanded(
          child: _filtered.isEmpty
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
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final n = _filtered[i];
                  return _NotificationCard(
                    type: n['type'],
                    title: n['title'],
                    body: n['body'],
                    time: n['time'],
                    read: n['read'],
                    onTap: () => setState(() => n['read'] = true),
                  );
                }),
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
      case 'live':    return Icons.videocam_outlined;
      case 'task':    return Icons.assignment_outlined;
      case 'video':   return Icons.play_circle_outline;
      case 'message': return Icons.chat_outlined;
      default:        return Icons.notifications_outlined;
    }
  }

  Color get _color {
    switch (type) {
      case 'live':    return AppColors.primary;
      case 'task':    return const Color(0xFFEF9F27);
      case 'video':   return const Color(0xFF378ADD);
      case 'message': return const Color(0xFF534AB7);
      default:        return AppColors.textSecondary;
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

            // Ícono
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(_icon, color: _color, size: 20)),
            const SizedBox(width: 12),

            // Contenido
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