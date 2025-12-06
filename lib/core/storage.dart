import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linksoap/core/prefill.dart';
import 'package:linksoap/detergent/model.dart';
import 'package:linksoap/softener/model.dart';

class Storage {
  static const _softenersKey = 'softeners';
  static const _detergentsKey = 'detergents';
  static const _historyKey = 'history';
  static const _historyEnabledKey = 'historyEnabled';
  static const _cleanedCountKey = 'cleanedCount';
  static const _tutorialExpandedKey = 'tutorialExpanded';
  static const _windowVisibleKey = 'windowVisible';

  final SharedPreferences _prefs;

  Storage(this._prefs);

  static Future<Storage> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = Storage(prefs);
    await storage._initializeDefaults();
    return storage;
  }

  Future<void> _initializeDefaults() async {
    if (!_prefs.containsKey(_softenersKey)) {
      await saveSofteners(storeboughtSofteners);
    }
    if (!_prefs.containsKey(_detergentsKey)) {
      await saveDetergents(storeboughtDetergents);
    }
  }

  List<Softener> loadSofteners() {
    final json = _prefs.getString(_softenersKey);
    if (json == null) return List.from(storeboughtSofteners);
    final list = jsonDecode(json) as List;
    return list
        .map((e) => Softener.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSofteners(List<Softener> softeners) async {
    final json = jsonEncode(softeners.map((e) => e.toJson()).toList());
    await _prefs.setString(_softenersKey, json);
  }

  List<Detergent> loadDetergents() {
    final json = _prefs.getString(_detergentsKey);
    if (json == null) return List.from(storeboughtDetergents);
    final list = jsonDecode(json) as List;
    return list
        .map((e) => Detergent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDetergents(List<Detergent> detergents) async {
    final json = jsonEncode(detergents.map((e) => e.toJson()).toList());
    await _prefs.setString(_detergentsKey, json);
  }

  List<Map<String, String>> loadHistory() {
    try {
      final json = _prefs.getString(_historyKey);
      if (json == null) return [];
      final list = jsonDecode(json) as List;
      return list.map((e) => Map<String, String>.from(e as Map)).toList();
    } catch (e) {
      _prefs.remove(_historyKey);
      return [];
    }
  }

  Future<void> addToHistory(String before, String after) async {
    final history = loadHistory();
    history.insert(0, {
      'before': before,
      'after': after,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    await _prefs.setString(_historyKey, jsonEncode(history));
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }

  bool isHistoryEnabled() {
    return _prefs.getBool(_historyEnabledKey) ?? true;
  }

  Future<void> setHistoryEnabled(bool enabled) async {
    await _prefs.setBool(_historyEnabledKey, enabled);
  }

  int getCleanedCount() {
    return _prefs.getInt(_cleanedCountKey) ?? 0;
  }

  Future<void> incrementCleanedCount() async {
    final count = getCleanedCount();
    await _prefs.setInt(_cleanedCountKey, count + 1);
  }

  Future<void> resetCleanedCount() async {
    await _prefs.setInt(_cleanedCountKey, 0);
  }

  bool isTutorialExpanded() {
    return _prefs.getBool(_tutorialExpandedKey) ?? true;
  }

  Future<void> setTutorialExpanded(bool expanded) async {
    await _prefs.setBool(_tutorialExpandedKey, expanded);
  }

  bool isWindowVisible() {
    return _prefs.getBool(_windowVisibleKey) ?? true;
  }

  Future<void> setWindowVisible(bool visible) async {
    await _prefs.setBool(_windowVisibleKey, visible);
  }
}
