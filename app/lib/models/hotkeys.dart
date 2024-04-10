import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotKeysModel extends ChangeNotifier {
  Map<String, HotKey>? _hotKeys;
  late final SharedPreferences _prefs;

  UnmodifiableMapView<String, HotKey>? get all =>
      _hotKeys == null ? null : UnmodifiableMapView(_hotKeys!);

  HotKeysModel() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    String? json = _prefs.getString("hotkeys");
    if (json == null) {
      _hotKeys = {};
    } else {
      try {
        Map<String, dynamic> data = jsonDecode(json);
        Map<String, HotKey> hotkeys =
            data.map((key, value) => MapEntry(key, HotKey.fromJson(value)));
        _hotKeys = hotkeys;
      } catch (e) {
        _hotKeys = {};
      }
    }
    notifyListeners();
  }

  HotKey? get(String id) {
    return _hotKeys![id];
  }

  void set(String id, HotKey? hotKey) {
    if (hotKey == null) {
      _hotKeys!.remove(id);
    } else {
      _hotKeys![id] = hotKey;
    }
    var data = _hotKeys!.map((key, value) => MapEntry(key, value.toJson()));
    _prefs.setString("hotkeys", jsonEncode(data));
    notifyListeners();
  }
}
