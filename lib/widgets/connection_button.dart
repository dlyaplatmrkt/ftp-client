import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/proxy_config.dart';
import '../utils/colors.dart';

class ConnectionButton extends StatelessWidget {
  final ConnectionStatus status;
  final VoidCallback onTap;

  const ConnectionButton({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = status == ConnectionStatus.connected;
    final isConnecting = status == ConnectionStatus.connecting;

    return GestureDetector(
      onTap: isConnecting ? null : onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isConnected || isConnecting)
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isConnected
                    ? AppColors.success.withOpacity(0.08)
                    : AppColors.primary.withOpacity(0.08),
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.3, 1.3),
                  duration: 2.seconds,
                )
                .fadeOut(duration: 2.seconds),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isConnected
                    ? [AppColors.success, const Color(0xFF2E7D52)]
                    : isConnecting
                        ? [AppColors.primary, AppColors.primaryDark]
                        : [AppColors.card, AppColors.surfaceLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: isConnected
                      ? AppColors.success.withOpacity(0.4)
                      : isConnecting
                          ? AppColors.primary.withOpacity(0.4)
                          : Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: isConnecting
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  )
                : Icon(
                    isConnected ? Icons.power_settings_new : Icons.power_settings_new,
                    color: isConnected
                        ? Colors.white
                        : AppColors.textSecondary,
                    size: 48,
                  ),
          ),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final ConnectionStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ConnectionStatus.connected => ('Connected', AppColors.success),
      ConnectionStatus.connecting => ('Connecting...', AppColors.primary),
      ConnectionStatus.error => ('Error', AppColors.error),
      ConnectionStatus.disconnected => ('Disconnected', AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          )
              .animate(
                  onPlay: status == ConnectionStatus.connected
                      ? (c) => c.repeat()
                      : null)
              .fadeOut(duration: 1.seconds)
              .then()
              .fadeIn(duration: 1.seconds),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
