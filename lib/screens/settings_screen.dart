import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/xray_service.dart';
import '../services/config_storage.dart';
import '../utils/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    final xray = context.watch<XrayService>();
    final storage = context.watch<ConfigStorage>();

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
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SectionHeader('Core'),
                _SettingsCard(
                  children: [
                    FutureBuilder<bool>(
                      future: xray.isXrayInstalled(),
                      builder: (context, snap) {
                        final installed = snap.data ?? false;
                        return _SettingsTile(
                          icon: installed
                              ? Icons.check_circle
                              : Icons.download_rounded,
                          iconColor:
                              installed ? AppColors.success : AppColors.primary,
                          title: 'Xray Core',
                          subtitle: installed
                              ? 'Installed and ready'
                              : 'Required for VPN connections',
                          trailing: _downloading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : installed
                                  ? const Icon(Icons.check,
                                      color: AppColors.success)
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: _downloadXray,
                                      child: const Text('Download'),
                                    ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionHeader('Data'),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.delete_forever,
                      iconColor: AppColors.error,
                      title: 'Clear All Configurations',
                      subtitle:
                          '${storage.configs.length} configurations stored',
                      trailing: TextButton(
                        onPressed: () => _showClearConfirm(storage),
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionHeader('About'),
                _SettingsCard(
                  children: [
                    const _SettingsTile(
                      icon: Icons.info_outline,
                      iconColor: AppColors.primary,
                      title: 'FTP VPN Client',
                      subtitle: 'Version 1.0.0',
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    const _SettingsTile(
                      icon: Icons.shield,
                      iconColor: AppColors.accent,
                      title: 'Powered by Xray-core',
                      subtitle: 'XTLS/Xray-core',
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    const _SettingsTile(
                      icon: Icons.language,
                      iconColor: AppColors.primary,
                      title: 'Website',
                      subtitle: 'ftpvpn.lol',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadXray() async {
    setState(() => _downloading = true);
    final xray = context.read<XrayService>();
    final success = await xray.downloadXray();
    setState(() => _downloading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Xray core installed!' : 'Failed to download xray core'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _showClearConfirm(ConfigStorage storage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Configurations',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will delete all saved configurations. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              storage.clearAll();
            },
            child: const Text('Clear All',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    )),
                Text(subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
