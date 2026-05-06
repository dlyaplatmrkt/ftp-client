import 'dart:convert';
import 'package:uuid/uuid.dart';

enum ProxyType { vless, vmess, shadowsocks, trojan, hysteria2, unknown }

enum ConnectionStatus { disconnected, connecting, connected, error }

class ProxyConfig {
  final String id;
  final String name;
  final ProxyType type;
  final String address;
  final int port;
  final String uuid;
  final String rawUri;
  final Map<String, dynamic> extra;
  final DateTime addedAt;

  ProxyConfig({
    String? id,
    required this.name,
    required this.type,
    required this.address,
    required this.port,
    required this.uuid,
    required this.rawUri,
    this.extra = const {},
    DateTime? addedAt,
  })  : id = id ?? const Uuid().v4(),
        addedAt = addedAt ?? DateTime.now();

  String get typeString {
    switch (type) {
      case ProxyType.vless:
        return 'VLESS';
      case ProxyType.vmess:
        return 'VMess';
      case ProxyType.shadowsocks:
        return 'Shadowsocks';
      case ProxyType.trojan:
        return 'Trojan';
      case ProxyType.hysteria2:
        return 'Hysteria2';
      default:
        return 'Unknown';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'address': address,
        'port': port,
        'uuid': uuid,
        'rawUri': rawUri,
        'extra': extra,
        'addedAt': addedAt.toIso8601String(),
      };

  factory ProxyConfig.fromJson(Map<String, dynamic> json) {
    return ProxyConfig(
      id: json['id'],
      name: json['name'],
      type: ProxyType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProxyType.unknown,
      ),
      address: json['address'],
      port: json['port'],
      uuid: json['uuid'],
      rawUri: json['rawUri'],
      extra: Map<String, dynamic>.from(json['extra'] ?? {}),
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  ProxyConfig copyWith({String? name}) {
    return ProxyConfig(
      id: id,
      name: name ?? this.name,
      type: type,
      address: address,
      port: port,
      uuid: uuid,
      rawUri: rawUri,
      extra: extra,
      addedAt: addedAt,
    );
  }
}

class TrafficStats {
  final int uploadBytes;
  final int downloadBytes;
  final double uploadSpeed;
  final double downloadSpeed;
  final Duration connected;

  TrafficStats({
    this.uploadBytes = 0,
    this.downloadBytes = 0,
    this.uploadSpeed = 0,
    this.downloadSpeed = 0,
    this.connected = Duration.zero,
  });

  String get uploadFormatted => _formatBytes(uploadBytes);
  String get downloadFormatted => _formatBytes(downloadBytes);
  String get uploadSpeedFormatted => '${_formatBytes(uploadSpeed.toInt())}/s';
  String get downloadSpeedFormatted =>
      '${_formatBytes(downloadSpeed.toInt())}/s';

  String get connectedFormatted {
    final h = connected.inHours;
    final m = connected.inMinutes % 60;
    final s = connected.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
  }
}
