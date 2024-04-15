import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:uni_platform/uni_platform.dart';

enum KeyState { up, down }

class KeyboardHandler {
  static final KeyboardHandler instance = KeyboardHandler();

  bool? _hooked;
  final List<HotKey> _hotKeyList = [];
  final Map<String, HotKeyHandler> _keyDownHandlerMap = {};
  final Set<PhysicalKeyboardKey> _keysPressed = {};

  void setHooked(bool value) {
    _hooked = value;
  }

  Future<void> register(HotKey hotKey, HotKeyHandler keyDownHandler) async {
    if (_hooked!) {
      _keyDownHandlerMap[hotKey.identifier] = keyDownHandler;
      _hotKeyList.add(hotKey);
    } else {
      await hotKeyManager.register(hotKey, keyDownHandler: keyDownHandler);
    }
  }

  Future<void> unregisterAll() async {
    if (_hooked!) {
      _keyDownHandlerMap.clear();
      _hotKeyList.clear();
    } else {
      await hotKeyManager.unregisterAll();
    }
  }

  void processKey(KeyState state, PhysicalKeyboardKey key) {
    switch (state) {
      case KeyState.up:
        _keysPressed.remove(key);
        break;
      case KeyState.down:
        _keysPressed.add(key);
        break;
    }

    if (state != KeyState.down) return;

    HotKey? hotKey = _hotKeyList.firstWhereOrNull(
      (e) {
        List<HotKeyModifier> modifiers = HotKeyModifier.values
            .where((e) => e.physicalKeys.any(_keysPressed.contains))
            .toList();
        return key.logicalKey! == e.logicalKey &&
            modifiers.length == (e.modifiers?.length ?? 0) &&
            modifiers.every((e.modifiers ?? []).contains);
      },
    );

    if (hotKey != null) {
      HotKeyHandler? handler = _keyDownHandlerMap[hotKey.identifier];
      if (handler != null) handler(hotKey);
    }
  }
}

final keyboardHandler = KeyboardHandler.instance;
