import 'dart:convert';
import '../models/proxy_config.dart';

class ConfigParser {
  static ProxyConfig? parseUri(String uri) {
    uri = uri.trim();
    if (uri.startsWith('vless://')) return _parseVless(uri);
    if (uri.startsWith('vmess://')) return _parseVmess(uri);
    if (uri.startsWith('ss://')) return _parseShadowsocks(uri);
    if (uri.startsWith('trojan://')) return _parseTrojan(uri);
    if (uri.startsWith('hysteria2://') || uri.startsWith('hy2://')) {
      return _parseHysteria2(uri);
    }
    return null;
  }

  static ProxyConfig? _parseVless(String uri) {
    try {
      final withoutScheme = uri.substring(8);
      final hashIndex = withoutScheme.lastIndexOf('#');
      String name = 'VLESS Server';
      String rest = withoutScheme;
      if (hashIndex >= 0) {
        name = Uri.decodeComponent(withoutScheme.substring(hashIndex + 1));
        rest = withoutScheme.substring(0, hashIndex);
      }
      final atIndex = rest.lastIndexOf('@');
      final uuid = rest.substring(0, atIndex);
      final hostPart = rest.substring(atIndex + 1);
      final queryIndex = hostPart.indexOf('?');
      String hostPort = queryIndex >= 0
          ? hostPart.substring(0, queryIndex)
          : hostPart;
      final query = queryIndex >= 0 ? hostPart.substring(queryIndex + 1) : '';
      final lastColon = hostPort.lastIndexOf(':');
      final host = hostPort.substring(0, lastColon);
      final port = int.parse(hostPort.substring(lastColon + 1));
      final params = Uri.splitQueryString(query);
      return ProxyConfig(
        name: name,
        type: ProxyType.vless,
        address: host,
        port: port,
        uuid: uuid,
        rawUri: uri,
        extra: {
          'type': params['type'] ?? 'tcp',
          'security': params['security'] ?? 'none',
          'sni': params['sni'] ?? '',
          'pbk': params['pbk'] ?? '',
          'sid': params['sid'] ?? '',
          'fp': params['fp'] ?? '',
          'flow': params['flow'] ?? '',
          'encryption': params['encryption'] ?? 'none',
        },
      );
    } catch (_) {
      return null;
    }
  }

  static ProxyConfig? _parseVmess(String uri) {
    try {
      final base64Part = uri.substring(8);
      final decoded = utf8.decode(base64.decode(base64.normalize(base64Part)));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return ProxyConfig(
        name: json['ps'] ?? json['add'] ?? 'VMess Server',
        type: ProxyType.vmess,
        address: json['add'] ?? '',
        port: int.tryParse(json['port'].toString()) ?? 443,
        uuid: json['id'] ?? '',
        rawUri: uri,
        extra: {
          'net': json['net'] ?? 'tcp',
          'tls': json['tls'] ?? '',
          'sni': json['sni'] ?? '',
          'path': json['path'] ?? '',
          'host': json['host'] ?? '',
        },
      );
    } catch (_) {
      return null;
    }
  }

  static ProxyConfig? _parseShadowsocks(String uri) {
    try {
      final withoutScheme = uri.substring(5);
      final hashIndex = withoutScheme.lastIndexOf('#');
      String name = 'Shadowsocks Server';
      String rest = withoutScheme;
      if (hashIndex >= 0) {
        name = Uri.decodeComponent(withoutScheme.substring(hashIndex + 1));
        rest = withoutScheme.substring(0, hashIndex);
      }
      final atIndex = rest.lastIndexOf('@');
      String methodPass = rest.substring(0, atIndex);
      try {
        methodPass = utf8.decode(base64.decode(base64.normalize(methodPass)));
      } catch (_) {}
      final hostPort = rest.substring(atIndex + 1);
      final lastColon = hostPort.lastIndexOf(':');
      final host = hostPort.substring(0, lastColon);
      final port = int.parse(hostPort.substring(lastColon + 1));
      final colonIdx = methodPass.indexOf(':');
      final method = methodPass.substring(0, colonIdx);
      final password = methodPass.substring(colonIdx + 1);
      return ProxyConfig(
        name: name,
        type: ProxyType.shadowsocks,
        address: host,
        port: port,
        uuid: password,
        rawUri: uri,
        extra: {'method': method},
      );
    } catch (_) {
      return null;
    }
  }

  static ProxyConfig? _parseTrojan(String uri) {
    try {
      final withoutScheme = uri.substring(9);
      final hashIndex = withoutScheme.lastIndexOf('#');
      String name = 'Trojan Server';
      String rest = withoutScheme;
      if (hashIndex >= 0) {
        name = Uri.decodeComponent(withoutScheme.substring(hashIndex + 1));
        rest = withoutScheme.substring(0, hashIndex);
      }
      final atIndex = rest.lastIndexOf('@');
      final password = rest.substring(0, atIndex);
      final hostPort = rest.substring(atIndex + 1).split('?')[0];
      final lastColon = hostPort.lastIndexOf(':');
      final host = hostPort.substring(0, lastColon);
      final port = int.parse(hostPort.substring(lastColon + 1));
      return ProxyConfig(
        name: name,
        type: ProxyType.trojan,
        address: host,
        port: port,
        uuid: password,
        rawUri: uri,
        extra: {},
      );
    } catch (_) {
      return null;
    }
  }

  static ProxyConfig? _parseHysteria2(String uri) {
    try {
      final withoutScheme = uri.startsWith('hy2://')
          ? uri.substring(6)
          : uri.substring(12);
      final hashIndex = withoutScheme.lastIndexOf('#');
      String name = 'Hysteria2 Server';
      String rest = withoutScheme;
      if (hashIndex >= 0) {
        name = Uri.decodeComponent(withoutScheme.substring(hashIndex + 1));
        rest = withoutScheme.substring(0, hashIndex);
      }
      final atIndex = rest.lastIndexOf('@');
      final password = rest.substring(0, atIndex);
      final hostPort = rest.substring(atIndex + 1).split('?')[0];
      final lastColon = hostPort.lastIndexOf(':');
      final host = hostPort.substring(0, lastColon);
      final port = int.parse(hostPort.substring(lastColon + 1));
      return ProxyConfig(
        name: name,
        type: ProxyType.hysteria2,
        address: host,
        port: port,
        uuid: password,
        rawUri: uri,
        extra: {},
      );
    } catch (_) {
      return null;
    }
  }

  static String generateXrayConfig(ProxyConfig config, int localPort) {
    final Map<String, dynamic> outbound = _buildOutbound(config);
    return jsonEncode({
      'log': {'loglevel': 'warning'},
      'inbounds': [
        {
          'port': localPort,
          'listen': '127.0.0.1',
          'protocol': 'socks',
          'settings': {'udp': true},
          'tag': 'socks-in',
        },
        {
          'port': localPort + 1,
          'listen': '127.0.0.1',
          'protocol': 'http',
          'tag': 'http-in',
        },
      ],
      'outbounds': [
        outbound,
        {
          'protocol': 'freedom',
          'tag': 'direct',
        },
        {
          'protocol': 'blackhole',
          'tag': 'blocked',
        },
      ],
      'routing': {
        'domainStrategy': 'IPIfNonMatch',
        'rules': [
          {
            'type': 'field',
            'ip': ['geoip:private'],
            'outboundTag': 'direct',
          },
        ],
      },
    });
  }

  static Map<String, dynamic> _buildOutbound(ProxyConfig config) {
    switch (config.type) {
      case ProxyType.vless:
        return {
          'protocol': 'vless',
          'settings': {
            'vnext': [
              {
                'address': config.address,
                'port': config.port,
                'users': [
                  {
                    'id': config.uuid,
                    'encryption': config.extra['encryption'] ?? 'none',
                    'flow': config.extra['flow'] ?? '',
                  }
                ],
              }
            ],
          },
          'streamSettings': _buildStreamSettings(config),
          'tag': 'proxy',
        };
      case ProxyType.vmess:
        return {
          'protocol': 'vmess',
          'settings': {
            'vnext': [
              {
                'address': config.address,
                'port': config.port,
                'users': [
                  {'id': config.uuid, 'alterId': 0}
                ],
              }
            ],
          },
          'streamSettings': _buildStreamSettings(config),
          'tag': 'proxy',
        };
      case ProxyType.trojan:
        return {
          'protocol': 'trojan',
          'settings': {
            'servers': [
              {
                'address': config.address,
                'port': config.port,
                'password': config.uuid,
              }
            ],
          },
          'streamSettings': _buildStreamSettings(config),
          'tag': 'proxy',
        };
      default:
        return {
          'protocol': 'freedom',
          'tag': 'proxy',
        };
    }
  }

  static Map<String, dynamic> _buildStreamSettings(ProxyConfig config) {
    final security = config.extra['security'] ?? 'none';
    final network = config.extra['type'] ?? config.extra['net'] ?? 'tcp';
    final Map<String, dynamic> settings = {
      'network': network,
      'security': security,
    };
    if (security == 'reality') {
      settings['realitySettings'] = {
        'serverName': config.extra['sni'] ?? '',
        'fingerprint': config.extra['fp'] ?? 'chrome',
        'publicKey': config.extra['pbk'] ?? '',
        'shortId': config.extra['sid'] ?? '',
      };
    } else if (security == 'tls') {
      settings['tlsSettings'] = {
        'serverName': config.extra['sni'] ?? config.address,
        'allowInsecure': false,
      };
    }
    if (network == 'ws') {
      settings['wsSettings'] = {
        'path': config.extra['path'] ?? '/',
        'headers': {'Host': config.extra['host'] ?? config.address},
      };
    }
    return settings;
  }
}
