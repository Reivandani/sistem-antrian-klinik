import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color warna;
    IconData icon;

    switch (status) {
      case 'Menunggu':
        warna = AppColors.warning;
        icon = Icons.access_time;

        break;

      case 'Dipanggil':
        warna = AppColors.primary;
        icon = Icons.campaign;

        break;

      case 'Selesai':
        warna = AppColors.success;
        icon = Icons.check_circle;

        break;

      case 'Dibatalkan':
        warna = AppColors.danger;
        icon = Icons.cancel;

        break;

      default:
        warna = Colors.grey;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.1),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 16, color: warna),

          const SizedBox(width: 5),

          Text(
            status,

            style: TextStyle(
              color: warna,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
