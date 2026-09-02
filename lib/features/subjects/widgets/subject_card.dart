import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SubjectCard extends StatelessWidget {
  final String icon;
  final String name;
  final double progress;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.icon,
    required this.name,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(name,
              style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: const Color(0xFFF5F5F5),
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.primary))),
            const SizedBox(height: 2),
            Text('${(progress * 100).toInt()}% completado',
              style: const TextStyle(fontSize: 9,
                color: AppColors.textSecondary)),
          ]),
      ),
    );
  }
}
