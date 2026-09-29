import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),

              blurRadius: 10,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,

              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(icon, color: AppColors.primary),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,

                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
