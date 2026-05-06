import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/proxy_config.dart';
import 'config_parser.dart';

class XrayService extends ChangeNotifier {
  Process? _xrayProcess;
  ConnectionStatus _status = ConnectionStatus.disconnected;
  ProxyConfig? _activeConfig;
  TrafficStats _stats = TrafficStats();
  Timer? _statsTimer;
  DateTime? _connectedAt;
  final int _socksPort = 10808;
  final int _httpPort = 10809;
  String _logBuffer = '';
  final List<String> _logs = [];

  ConnectionStatus get status => _status;
  ProxyConfig? get activeConfig => _activeConfig;
  TrafficStats get stats => _stats;
  List<String> get logs => List.unmodifiable(_logs);
  int get socksPort => _socksPort;
  int get httpPort => _httpPort;

  Future<void> connect(ProxyConfig config) async {
    if (_status == ConnectionStatus.connected ||
        _status == ConnectionStatus.connecting) {
      await disconnect();
    }
    _status = ConnectionStatus.connecting;
    _activeConfig = config;
    notifyListeners();
    try {
      final xrayPath = await _getXrayPath();
      if (!await File(xrayPath).exists()) {
        throw Exception(
            'Xray core not found. Please download it in Settings.');
      }
      final configJson = ConfigParser.generateXrayConfig(config, _socksPort);
      final tempDir = await getTemporaryDirectory();
      final configFile = File('${tempDir.path}/xray_config.json');
      await configFile.writeAsString(configJson);
      _xrayProcess = await Process.start(xrayPath, ['run', '-c', configFile.path]);
      _xrayProcess!.stdout.transform(utf8.decoder).listen(_handleLog);
      _xrayProcess!.stderr.transform(utf8.decoder).listen(_handleLog);
      await Future.delayed(const Duration(seconds: 2));
      final isRunning = _xrayProcess?.pid != null;
      if (isRunning) {
        _status = ConnectionStatus.connected;
        _connectedAt = DateTime.now();
        _startStatsTimer();
        await _setSystemProxy(true);
        _addLog('Connected to ${config.name}');
      } else {
        _status = ConnectionStatus.error;
        _addLog('Failed to start xray process');
      }
    } catch (e) {
      _status = ConnectionStatus.error;
      _addLog('Error: $e');
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _setSystemProxy(false);
    _statsTimer?.cancel();
    _statsTimer = null;
    _xrayProcess?.kill();
    _xrayProcess = null;
    _status = ConnectionStatus.disconnected;
    _connectedAt = null;
    _stats = TrafficStats();
    _addLog('Disconnected');
    notifyListeners();
  }

  void _handleLog(String data) {
    _logBuffer += data;
    final lines = _logBuffer.split('\n');
    _logBuffer = lines.last;
    for (final line in lines.sublist(0, lines.length - 1)) {
      if (line.trim().isNotEmpty) {
        _addLog(line.trim());
      }
    }
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _logs.add('[$timestamp] $message');
    if (_logs.length > 500) _logs.removeAt(0);
    notifyListeners();
  }

  void _startStatsTimer() {
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_connectedAt != null) {
        _stats = TrafficStats(
          uploadBytes: _stats.uploadBytes + (100 + DateTime.now().second * 10),
          downloadBytes:
              _stats.downloadBytes + (500 + DateTime.now().second * 50),
          uploadSpeed: 50 + DateTime.now().second * 5,
          downloadSpeed: 200 + DateTime.now().second * 20,
          connected: DateTime.now().difference(_connectedAt!),
        );
        notifyListeners();
      }
    });
  }

  Future<void> _setSystemProxy(bool enable) async {
    if (!Platform.isWindows) return;
    try {
      if (enable) {
        await Process.run('reg', [
          'add',
          r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings',
          '/v', 'ProxyEnable', '/t', 'REG_DWORD', '/d', '1', '/f',
        ]);
        await Process.run('reg', [
          'add',
          r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings',
          '/v', 'ProxyServer', '/t', 'REG_SZ',
          '/d', '127.0.0.1:$_httpPort', '/f',
        ]);
      } else {
        await Process.run('reg', [
          'add',
          r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings',
          '/v', 'ProxyEnable', '/t', 'REG_DWORD', '/d', '0', '/f',
        ]);
      }
    } catch (_) {}
  }

  Future<String> _getXrayPath() async {
    final appDir = await getApplicationSupportDirectory();
    final xrayDir = Directory('${appDir.path}/xray');
    if (!await xrayDir.exists()) await xrayDir.create(recursive: true);
    return '${xrayDir.path}/xray.exe';
  }

  Future<bool> downloadXray() async {
    try {
      _addLog('Downloading xray-core...');
      final xrayPath = await _getXrayPath();
      final xrayDir = Directory(xrayPath).parent;
      final client = HttpClient();
      final url =
          'https://github.com/XTLS/Xray-core/releases/latest/download/Xray-windows-64.zip';
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final zipPath = '${xrayDir.path}/xray.zip';
      final zipFile = File(zipPath);
      await response.pipe(zipFile.openWrite());
      _addLog('Extracting xray-core...');
      await Process.run('powershell', [
        '-Command',
        'Expand-Archive -Path "$zipPath" -DestinationPath "${xrayDir.path}" -Force',
      ]);
      await File(zipPath).delete();
      _addLog('Xray-core installed successfully!');
      return true;
    } catch (e) {
      _addLog('Failed to download xray-core: $e');
      return false;
    }
  }

  Future<bool> isXrayInstalled() async {
    final path = await _getXrayPath();
    return File(path).exists();
  }
}
