import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'services/xray_service.dart';
import 'services/config_storage.dart';
import 'screens/home_screen.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(900, 620),
    minimumSize: Size(800, 560),
    center: true,
    backgroundColor: AppColors.background,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'FTP VPN Client',
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const FtpVpnApp());
}

class FtpVpnApp extends StatelessWidget {
  const FtpVpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => XrayService()),
        ChangeNotifierProvider(create: (_) {
          final storage = ConfigStorage();
          storage.load();
          return storage;
        }),
      ],
      child: MaterialApp(
        title: 'FTP VPN Client',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.surface,
            error: AppColors.error,
          ),
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Inter',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: AppColors.textPrimary),
            bodySmall: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        home: const AppFrame(),
      ),
    );
  }
}

class AppFrame extends StatelessWidget with WindowListener {
  const AppFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _TitleBar(),
          const Expanded(child: HomeScreen()),
        ],
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 38,
        color: AppColors.surface,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.shield, size: 13, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              'FTP VPN Client',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _WindowButton(
              icon: Icons.remove,
              onTap: () => windowManager.minimize(),
            ),
            _WindowButton(
              icon: Icons.crop_square,
              onTap: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
            ),
            _WindowButton(
              icon: Icons.close,
              onTap: () => windowManager.close(),
              isClose: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onTap,
    this.isClose = false,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 46,
          height: 38,
          color: _hovered
              ? (widget.isClose ? AppColors.error : AppColors.card)
              : Colors.transparent,
          child: Icon(
            widget.icon,
            size: 16,
            color: _hovered ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
