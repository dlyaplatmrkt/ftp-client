import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/proxy_config.dart';

class ConfigStorage extends ChangeNotifier {
  static const _key = 'proxy_configs';
  static const _selectedKey = 'selected_config_id';

  List<ProxyConfig> _configs = [];
  String? _selectedId;

  List<ProxyConfig> get configs => List.unmodifiable(_configs);
  String? get selectedId => _selectedId;

  ProxyConfig? get selectedConfig {
    if (_selectedId == null) return null;
    try {
      return _configs.firstWhere((c) => c.id == _selectedId);
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _configs = raw.map((s) => ProxyConfig.fromJson(jsonDecode(s))).toList();
    _selectedId = prefs.getString(_selectedKey);
    notifyListeners();
  }

  Future<void> addConfig(ProxyConfig config) async {
    _configs.add(config);
    await _save();
    if (_configs.length == 1) await selectConfig(config.id);
    notifyListeners();
  }

  Future<void> removeConfig(String id) async {
    _configs.removeWhere((c) => c.id == id);
    if (_selectedId == id) {
      _selectedId = _configs.isNotEmpty ? _configs.first.id : null;
    }
    await _save();
    notifyListeners();
  }

  Future<void> selectConfig(String id) async {
    _selectedId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedKey, id);
    notifyListeners();
  }

  Future<void> updateConfig(ProxyConfig config) async {
    final idx = _configs.indexWhere((c) => c.id == config.id);
    if (idx >= 0) {
      _configs[idx] = config;
      await _save();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _configs.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }

  Future<void> clearAll() async {
    _configs.clear();
    _selectedId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_selectedKey);
    notifyListeners();
  }
}
