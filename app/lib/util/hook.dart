import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:app/util/keyboard_handler.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart';

SendPort? _sp;

// https://github.com/flutter/engine/blob/main/shell/platform/windows/flutter_key_map.g.cc
Map<int, int> _windowsToPhysicalMap = {
  0x00000001: 0x00070029, // escape
  0x00000002: 0x0007001e, // digit1
  0x00000003: 0x0007001f, // digit2
  0x00000004: 0x00070020, // digit3
  0x00000005: 0x00070021, // digit4
  0x00000006: 0x00070022, // digit5
  0x00000007: 0x00070023, // digit6
  0x00000008: 0x00070024, // digit7
  0x00000009: 0x00070025, // digit8
  0x0000000a: 0x00070026, // digit9
  0x0000000b: 0x00070027, // digit0
  0x0000000c: 0x0007002d, // minus
  0x0000000d: 0x0007002e, // equal
  0x0000000e: 0x0007002a, // backspace
  0x0000000f: 0x0007002b, // tab
  0x00000010: 0x00070014, // keyQ
  0x00000011: 0x0007001a, // keyW
  0x00000012: 0x00070008, // keyE
  0x00000013: 0x00070015, // keyR
  0x00000014: 0x00070017, // keyT
  0x00000015: 0x0007001c, // keyY
  0x00000016: 0x00070018, // keyU
  0x00000017: 0x0007000c, // keyI
  0x00000018: 0x00070012, // keyO
  0x00000019: 0x00070013, // keyP
  0x0000001a: 0x0007002f, // bracketLeft
  0x0000001b: 0x00070030, // bracketRight
  0x0000001c: 0x00070028, // enter
  0x0000001d: 0x000700e0, // controlLeft
  0x0000001e: 0x00070004, // keyA
  0x0000001f: 0x00070016, // keyS
  0x00000020: 0x00070007, // keyD
  0x00000021: 0x00070009, // keyF
  0x00000022: 0x0007000a, // keyG
  0x00000023: 0x0007000b, // keyH
  0x00000024: 0x0007000d, // keyJ
  0x00000025: 0x0007000e, // keyK
  0x00000026: 0x0007000f, // keyL
  0x00000027: 0x00070033, // semicolon
  0x00000028: 0x00070034, // quote
  0x00000029: 0x00070035, // backquote
  0x0000002a: 0x000700e1, // shiftLeft
  0x0000002b: 0x00070031, // backslash
  0x0000002c: 0x0007001d, // keyZ
  0x0000002d: 0x0007001b, // keyX
  0x0000002e: 0x00070006, // keyC
  0x0000002f: 0x00070019, // keyV
  0x00000030: 0x00070005, // keyB
  0x00000031: 0x00070011, // keyN
  0x00000032: 0x00070010, // keyM
  0x00000033: 0x00070036, // comma
  0x00000034: 0x00070037, // period
  0x00000035: 0x00070038, // slash
  0x00000036: 0x000700e5, // shiftRight
  0x00000037: 0x00070055, // numpadMultiply
  0x00000038: 0x000700e2, // altLeft
  0x00000039: 0x0007002c, // space
  0x0000003a: 0x00070039, // capsLock
  0x0000003b: 0x0007003a, // f1
  0x0000003c: 0x0007003b, // f2
  0x0000003d: 0x0007003c, // f3
  0x0000003e: 0x0007003d, // f4
  0x0000003f: 0x0007003e, // f5
  0x00000040: 0x0007003f, // f6
  0x00000041: 0x00070040, // f7
  0x00000042: 0x00070041, // f8
  0x00000043: 0x00070042, // f9
  0x00000044: 0x00070043, // f10
  0x00000045: 0x00070048, // pause
  0x00000046: 0x00070047, // scrollLock
  0x00000047: 0x0007005f, // numpad7
  0x00000048: 0x00070060, // numpad8
  0x00000049: 0x00070061, // numpad9
  0x0000004a: 0x00070056, // numpadSubtract
  0x0000004b: 0x0007005c, // numpad4
  0x0000004c: 0x0007005d, // numpad5
  0x0000004d: 0x0007005e, // numpad6
  0x0000004e: 0x00070057, // numpadAdd
  0x0000004f: 0x00070059, // numpad1
  0x00000050: 0x0007005a, // numpad2
  0x00000051: 0x0007005b, // numpad3
  0x00000052: 0x00070062, // numpad0
  0x00000053: 0x00070063, // numpadDecimal
  0x00000056: 0x00070064, // intlBackslash
  0x00000057: 0x00070044, // f11
  0x00000058: 0x00070045, // f12
  0x00000059: 0x00070067, // numpadEqual
  0x00000064: 0x00070068, // f13
  0x00000065: 0x00070069, // f14
  0x00000066: 0x0007006a, // f15
  0x00000067: 0x0007006b, // f16
  0x00000068: 0x0007006c, // f17
  0x00000069: 0x0007006d, // f18
  0x0000006a: 0x0007006e, // f19
  0x0000006b: 0x0007006f, // f20
  0x0000006c: 0x00070070, // f21
  0x0000006d: 0x00070071, // f22
  0x0000006e: 0x00070072, // f23
  0x00000070: 0x00070088, // kanaMode
  0x00000071: 0x00070091, // lang2
  0x00000072: 0x00070090, // lang1
  0x00000073: 0x00070087, // intlRo
  0x00000076: 0x00070073, // f24
  0x00000077: 0x00070093, // lang4
  0x00000078: 0x00070092, // lang3
  0x00000079: 0x0007008a, // convert
  0x0000007b: 0x0007008b, // nonConvert
  0x0000007d: 0x00070089, // intlYen
  0x0000007e: 0x00070085, // numpadComma
  0x000000fc: 0x00070002, // usbPostFail
  0x000000ff: 0x00070001, // usbErrorRollOver
  0x0000e008: 0x0007007a, // undo
  0x0000e00a: 0x0007007d, // paste
  0x0000e010: 0x000c00b6, // mediaTrackPrevious
  0x0000e017: 0x0007007b, // cut
  0x0000e018: 0x0007007c, // copy
  0x0000e019: 0x000c00b5, // mediaTrackNext
  0x0000e01c: 0x00070058, // numpadEnter
  0x0000e01d: 0x000700e4, // controlRight
  0x0000e020: 0x0007007f, // audioVolumeMute
  0x0000e021: 0x000c0192, // launchApp2
  0x0000e022: 0x000c00cd, // mediaPlayPause
  0x0000e024: 0x000c00b7, // mediaStop
  0x0000e02c: 0x000c00b8, // eject
  0x0000e02e: 0x00070081, // audioVolumeDown
  0x0000e030: 0x00070080, // audioVolumeUp
  0x0000e032: 0x000c0223, // browserHome
  0x0000e035: 0x00070054, // numpadDivide
  0x0000e037: 0x00070046, // printScreen
  0x0000e038: 0x000700e6, // altRight
  0x0000e03b: 0x00070075, // help
  0x0000e045: 0x00070053, // numLock
  0x0000e047: 0x0007004a, // home
  0x0000e048: 0x00070052, // arrowUp
  0x0000e049: 0x0007004b, // pageUp
  0x0000e04b: 0x00070050, // arrowLeft
  0x0000e04d: 0x0007004f, // arrowRight
  0x0000e04f: 0x0007004d, // end
  0x0000e050: 0x00070051, // arrowDown
  0x0000e051: 0x0007004e, // pageDown
  0x0000e052: 0x00070049, // insert
  0x0000e053: 0x0007004c, // delete
  0x0000e05b: 0x000700e3, // metaLeft
  0x0000e05c: 0x000700e7, // metaRight
  0x0000e05d: 0x00070065, // contextMenu
  0x0000e05e: 0x00070066, // power
  0x0000e05f: 0x00010082, // sleep
  0x0000e063: 0x00010083, // wakeUp
  0x0000e065: 0x000c0221, // browserSearch
  0x0000e066: 0x000c022a, // browserFavorites
  0x0000e067: 0x000c0227, // browserRefresh
  0x0000e068: 0x000c0226, // browserStop
  0x0000e069: 0x000c0225, // browserForward
  0x0000e06a: 0x000c0224, // browserBack
  0x0000e06b: 0x000c0194, // launchApp1
  0x0000e06c: 0x000c018a, // launchMail
  0x0000e06d: 0x000c0183, // mediaSelect
};

// ignore: non_constant_identifier_names
int _HookProcedure(int code, int wParam, int lParam) {
  if (code >= 0) {
    late final KeyState state;
    if (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN) {
      state = KeyState.down;
    } else if (wParam == WM_KEYUP || wParam == WM_SYSKEYUP) {
      state = KeyState.up;
    }
    final x = Pointer<KBDLLHOOKSTRUCT>.fromAddress(lParam);
    _sp!.send({
      'state': state,
      'scanCode': x.ref.scanCode,
      'extended': x.ref.flags & KBDLLHOOKSTRUCT_FLAGS.LLKHF_EXTENDED == 0x01
    });
  }

  return CallNextHookEx(0, code, wParam, lParam);
}

void _registerHook(SendPort sendPort) async {
  stdout.writeln("Registering hook...");

  _sp = sendPort;

  final receivePort = ReceivePort();
  int res = SetWindowsHookEx(WINDOWS_HOOK_ID.WH_KEYBOARD_LL,
      Pointer.fromFunction(_HookProcedure, 0), GetModuleHandle(nullptr), 0);

  if (res == 0) {
    stdout.writeln("Failed to register hook!");
    sendPort.send({'registered': false});
    return;
  } else {
    stdout.writeln("Registered hook!");
    sendPort.send({'registered': true, 'sendPort': receivePort.sendPort});
  }

  while (true) {
    try {
      await receivePort.first.timeout(const Duration(milliseconds: 50));
      stdout.writeln("Unregistering hook!");
      break;
    } catch (_) {}

    final msg = calloc<MSG>();
    if (PeekMessage(msg, NULL, 0, 0, PEEK_MESSAGE_REMOVE_TYPE.PM_REMOVE) ==
        0x01) {
      TranslateMessage(msg);
      DispatchMessage(msg);
    }
  }

  UnhookWindowsHookEx(res);
  stdout.writeln("Unregistered hook!");
}

typedef UnregisterHook = void Function();

Future<UnregisterHook?> registerHook() async {
  var receivePort = ReceivePort();
  await Isolate.spawn(_registerHook, receivePort.sendPort);

  var first = true;
  var completer = Completer<UnregisterHook?>();
  var subscription = receivePort.listen(null);

  subscription.onData((message) {
    Map<String, dynamic> map = message;
    if (first) {
      first = false;
      bool registered = map['registered'];
      if (registered) {
        SendPort sendPort = map['sendPort'];
        keyboardHandler.setHooked(true);
        completer.complete(() => sendPort.send(null));
      } else {
        subscription.cancel();
        keyboardHandler.setHooked(false);
        completer.complete(null);
      }
    } else {
      KeyState state = map['state'];
      int scanCode = map['scanCode'];
      bool extended = map['extended'];
      int chromiumScancode = (scanCode & 0xff) | (extended ? 0xe000 : 0);
      int? usbHID = _windowsToPhysicalMap[chromiumScancode];
      if (usbHID != null) {
        var key = PhysicalKeyboardKey.findKeyByCode(usbHID);
        if (key != null) {
          keyboardHandler.processKey(state, key);
        }
      }
    }
  });

  return completer.future;
}
