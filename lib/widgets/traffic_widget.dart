import 'package:flutter/material.dart';
import '../models/proxy_config.dart';
import '../utils/colors.dart';

class TrafficWidget extends StatelessWidget {
  final TrafficStats stats;

  const TrafficWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.arrow_upward,
                  color: AppColors.primary,
                  label: 'Upload',
                  value: stats.uploadFormatted,
                  speed: stats.uploadSpeedFormatted,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.divider,
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.arrow_downward,
                  color: AppColors.accent,
                  label: 'Download',
                  value: stats.downloadFormatted,
                  speed: stats.downloadSpeedFormatted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, color: AppColors.textMuted, size: 16),
              const SizedBox(width: 6),
              Text(
                stats.connectedFormatted,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String speed;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          speed,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
