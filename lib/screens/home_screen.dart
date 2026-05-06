import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/proxy_config.dart';
import '../services/xray_service.dart';
import '../services/config_storage.dart';
import '../utils/colors.dart';
import '../widgets/connection_button.dart';
import '../widgets/traffic_widget.dart';
import 'configs_screen.dart';
import 'logs_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _SideNav(
            selectedIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                _DashboardTab(),
                ConfigsScreen(),
                LogsScreen(),
                SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _SideNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.list_alt_rounded, 'Configs'),
      (Icons.article_rounded, 'Logs'),
      (Icons.settings_rounded, 'Settings'),
    ];

    return Container(
      width: 72,
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'FP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          ...List.generate(items.length, (i) {
            final selected = i == selectedIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Tooltip(
                message: items[i].$2,
                preferBelow: false,
                child: GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      items[i].$1,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final xray = context.watch<XrayService>();
    final storage = context.watch<ConfigStorage>();
    final selected = storage.selectedConfig;
    final isConnected = xray.status == ConnectionStatus.connected;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Column(
        children: [
          _TopBar(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selected.name,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    ConnectionButton(
                      status: xray.status,
                      onTap: () async {
                        if (isConnected) {
                          await xray.disconnect();
                        } else if (selected != null) {
                          await xray.connect(selected);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please add and select a config first'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    StatusBadge(status: xray.status),
                    if (isConnected) ...[
                      const SizedBox(height: 32),
                      TrafficWidget(stats: xray.stats),
                    ],
                    if (!isConnected && selected == null) ...[
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.textMuted,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No configuration added',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Go to Configs tab to add a VLESS, VMess\nor Shadowsocks configuration',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (isConnected) ...[
                      const SizedBox(height: 16),
                      _ProxyInfoCard(xray: xray),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProxyInfoCard extends StatelessWidget {
  final XrayService xray;
  const _ProxyInfoCard({required this.xray});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proxy Info',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow('SOCKS5 Proxy', '127.0.0.1:${xray.socksPort}'),
          const SizedBox(height: 8),
          _InfoRow('HTTP Proxy', '127.0.0.1:${xray.httpPort}'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Text(value,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'monospace',
            )),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          const Text(
            'FTP VPN',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'v1.0',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
