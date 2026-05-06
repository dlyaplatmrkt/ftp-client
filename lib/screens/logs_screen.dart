import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/xray_service.dart';
import '../utils/colors.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_autoScroll && _scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final xray = context.watch<XrayService>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                const Text(
                  'Logs',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text('Auto-scroll',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                    Switch(
                      value: _autoScroll,
                      onChanged: (v) => setState(() => _autoScroll = v),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.textMuted),
                  tooltip: 'Copy logs',
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: xray.logs.join('\n')));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logs copied to clipboard'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF080812),
              child: xray.logs.isEmpty
                  ? const Center(
                      child: Text(
                        'No logs yet. Connect to see logs.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: xray.logs.length,
                      itemBuilder: (_, i) {
                        final log = xray.logs[i];
                        final color = _getLogColor(log);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLogColor(String log) {
    final lower = log.toLowerCase();
    if (lower.contains('error') || lower.contains('failed')) {
      return AppColors.error;
    }
    if (lower.contains('warn')) return AppColors.warning;
    if (lower.contains('connected') || lower.contains('success')) {
      return AppColors.success;
    }
    if (lower.contains('connecting') || lower.contains('download')) {
      return AppColors.primary;
    }
    return AppColors.textSecondary;
  }
}
