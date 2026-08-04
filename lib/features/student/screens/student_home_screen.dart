import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../subjects/screens/subject_detail_screen.dart';
import '../../notifications/screens/notifications_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // En móvil la barra superior ya la muestra MainLayout, así que aquí
      // solo se dibuja en escritorio (donde MainLayout no tiene barra propia).
      appBar: MediaQuery.of(context).size.width < 700 ? null : AppBar(
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
          const Text('Aula Lid-IA',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textSecondary),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen()))),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.studentColor,
            child: Text('VA',
              style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDark))),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Banner bienvenida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D9E75), Color(0xFF085041)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('¡Hola, Valentina! 👋',
                        style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Tienes 2 clases hoy y 1 tarea pendiente',
                        style: TextStyle(fontSize: 12,
                          color: Colors.white70)),
                    ]),
                  const Text('👩🏾‍🎓', style: TextStyle(fontSize: 36)),
                ]),
            ),
            const SizedBox(height: 20),

            // Mis materias
            const Text('Mis materias',
              style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            const SizedBox(height: 10),

            GridView.extent(
              maxCrossAxisExtent: 180,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.4,
              children: [
                _SubjectCard(
                  icon: '📖', name: 'Español',
                  lesson: 'Lección 4', progress: 0.65,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      const SubjectDetailScreen(
                        icon: '📖', name: 'Español',
                        progress: 0.65)))),
                _SubjectCard(
                  icon: '🇬🇧', name: 'Inglés',
                  lesson: 'Unit 2', progress: 0.40,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      const SubjectDetailScreen(
                        icon: '🇬🇧', name: 'Inglés',
                        progress: 0.40)))),
                _SubjectCard(
                  icon: '🧮', name: 'Matemáticas',
                  lesson: 'Cap. 3', progress: 0.80,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      const SubjectDetailScreen(
                        icon: '🧮', name: 'Matemáticas',
                        progress: 0.80)))),
                _SubjectCard(
                  icon: '🌍', name: 'Cs. Sociales',
                  lesson: 'Unidad 1', progress: 0.55,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      const SubjectDetailScreen(
                        icon: '🌍', name: 'Cs. Sociales',
                        progress: 0.55)))),
                _SubjectCard(
                  icon: '🌱', name: 'Cs. Naturales',
                  lesson: 'Tema 5', progress: 0.30,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      const SubjectDetailScreen(
                        icon: '🌱', name: 'Cs. Naturales',
                        progress: 0.30)))),
                _SubjectCard(
                  icon: '🕊️', name: 'Cátedra Paz',
                  lesson: 'Módulo 2', progress: 0.90,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      const SubjectDetailScreen(
                        icon: '🕊️', name: 'Cátedra Paz',
                        progress: 0.90)))),
                _SubjectCard(
                  icon: '✝️', name: 'Religión',
                  lesson: 'Unidad 1', progress: 0.50,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      const SubjectDetailScreen(
                        icon: '✝️', name: 'Religión',
                        progress: 0.50)))),
                _SubjectCard(
                  icon: '💻', name: 'Informática',
                  lesson: 'Tema 3', progress: 0.60,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      const SubjectDetailScreen(
                        icon: '💻', name: 'Informática',
                        progress: 0.60)))),
                _SubjectCard(
                  icon: '🎧', name: 'TelePsicología',
                  lesson: 'Sesión 2', progress: 0.70,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      const SubjectDetailScreen(
                        icon: '🎧', name: 'TelePsicología',
                        progress: 0.70)))),
              ],
            ),
            const SizedBox(height: 20),

            // Fila inferior
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Próximas clases
              Expanded(child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.video_call_outlined,
                        size: 15, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('Próximas clases',
                        style: TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w500)),
                    ]),
                    const SizedBox(height: 10),
                    _ClassItem(subject: 'Matemáticas',
                      time: 'Hoy 9:00 am', isLive: true),
                    _ClassItem(subject: 'Inglés',
                      time: 'Hoy 11:00 am', isLive: false),
                    _ClassItem(subject: 'Cs. Naturales',
                      time: 'Mañana 8:00 am', isLive: false),
                  ]),
              )),
              const SizedBox(width: 8),

              // Tareas
              Expanded(child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.checklist_outlined,
                        size: 15, color: Color(0xFF378ADD)),
                      SizedBox(width: 6),
                      Text('Tareas',
                        style: TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w500)),
                    ]),
                    const SizedBox(height: 10),
                    _TaskItem(text: 'Ejercicios cap. 3',
                      due: 'Vence: hoy', done: false),
                    _TaskItem(text: 'Lectura Español',
                      due: 'Entregado ✓', done: true),
                    _TaskItem(text: 'Video Cs. Naturales',
                      due: 'Vence: jue', done: false),
                  ]),
              )),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── WIDGETS ───────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  final String icon;
  final String name;
  final String lesson;
  final double progress;
  final VoidCallback onTap;
  const _SubjectCard({required this.icon, required this.name,
    required this.lesson, required this.progress,
    required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(name,
              style: const TextStyle(fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            Text(lesson,
              style: const TextStyle(fontSize: 10,
                color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: const Color(0xFFF5F5F5),
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.primary))),
          ]),
      ),
    );
  }
}

class _ClassItem extends StatelessWidget {
  final String subject;
  final String time;
  final bool isLive;
  const _ClassItem({required this.subject,
    required this.time, required this.isLive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(width: 6, height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLive
              ? AppColors.primary
              : Colors.grey.shade400)),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subject,
              style: const TextStyle(fontSize: 11,
                color: AppColors.textPrimary)),
            Text(time,
              style: const TextStyle(fontSize: 10,
                color: AppColors.textSecondary)),
          ])),
        if (isLive)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5EE),
              borderRadius: BorderRadius.circular(4)),
            child: const Text('EN VIVO',
              style: TextStyle(fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDark))),
      ]),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String text;
  final String due;
  final bool done;
  const _TaskItem({required this.text,
    required this.due, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
          width: 14, height: 14,
          decoration: BoxDecoration(
            color: done ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: done
                ? AppColors.primary
                : Colors.grey.shade400),
            borderRadius: BorderRadius.circular(3)),
          child: done
            ? const Icon(Icons.check, size: 10, color: Colors.white)
            : null),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text,
              style: TextStyle(fontSize: 11,
                color: done
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
                decoration: done
                  ? TextDecoration.lineThrough
                  : TextDecoration.none)),
            Text(due,
              style: const TextStyle(fontSize: 10,
                color: AppColors.textSecondary)),
          ])),
      ]),
    );
  }
}