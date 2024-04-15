import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

final Map<PhysicalKeyboardKey, String> _overrides =
    <PhysicalKeyboardKey, String>{
  PhysicalKeyboardKey.enter: 'Enter',
  PhysicalKeyboardKey.escape: 'Esc',
  PhysicalKeyboardKey.backspace: 'Backspace',
  PhysicalKeyboardKey.tab: 'Tab',
  PhysicalKeyboardKey.space: 'Space',
  PhysicalKeyboardKey.capsLock: 'CapsLock',
  PhysicalKeyboardKey.home: 'Home',
  PhysicalKeyboardKey.pageUp: 'PgUp',
  PhysicalKeyboardKey.delete: 'Del',
  PhysicalKeyboardKey.end: 'End',
  PhysicalKeyboardKey.pageDown: 'PgDn',
  PhysicalKeyboardKey.arrowRight: 'Right',
  PhysicalKeyboardKey.arrowLeft: 'Left',
  PhysicalKeyboardKey.arrowDown: 'Up',
  PhysicalKeyboardKey.arrowUp: 'Down',
  PhysicalKeyboardKey.controlLeft: 'Ctrl',
  PhysicalKeyboardKey.shiftLeft: 'Shift',
  PhysicalKeyboardKey.altLeft: 'Alt',
  PhysicalKeyboardKey.metaLeft: 'Meta',
  PhysicalKeyboardKey.controlRight: 'Right Ctrl',
  PhysicalKeyboardKey.shiftRight: 'Right Shift',
  PhysicalKeyboardKey.altRight: 'Right Alt',
  PhysicalKeyboardKey.metaRight: 'Right Meta',
  PhysicalKeyboardKey.fn: 'Fn',
};

class KeyView extends StatelessWidget {
  const KeyView({super.key, required this.physicalKey});

  final PhysicalKeyboardKey physicalKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: BrandColors.whiteA),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child:
          Text((_overrides[physicalKey] ?? physicalKey.keyLabel).toUpperCase(),
              style: GoogleFonts.montserrat(
                textStyle: const TextStyle(
                    color: BrandColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              )),
    );
  }
}

class HotKeyView extends StatelessWidget {
  const HotKeyView({super.key, required this.hotKey});

  final HotKey hotKey;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (HotKeyModifier modifier in hotKey.modifiers ?? [])
          KeyView(
            physicalKey: modifier.physicalKeys.first,
          ),
        KeyView(
          physicalKey: hotKey.physicalKey,
        ),
      ],
    );
  }
}
