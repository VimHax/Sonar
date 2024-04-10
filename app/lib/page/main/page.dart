import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/models/hotkeys.dart';
import 'package:app/models/sounds.dart';
import 'package:app/page/main/tab/members/tab.dart';
import 'package:app/page/main/tab/soundboard/tab.dart';
import 'package:app/page/main/tab/sounds/tab.dart';
import 'package:app/page/main/tabs.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final HotKeysModel _hotKeysProvider;
  StreamSubscription? _sub;
  TabType _tab = TabType.soundboard;

  @override
  void initState() {
    _hotKeysProvider = context.read<HotKeysModel>();
    _hotKeysProvider.addListener(_onHotKeysUpdate);
    _onHotKeysUpdate();

    _sub = supabase.auth.onAuthStateChange.listen((data) {
      if (data.session == null) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _hotKeysProvider.removeListener(_onHotKeysUpdate);
    hotKeyManager.unregisterAll();

    _sub?.cancel();
    super.dispose();
  }

  void _onHotKeysUpdate() {
    var hotKeys = _hotKeysProvider.all;
    if (hotKeys == null) return;
    hotKeyManager.unregisterAll();
    hotKeys.forEach((key, value) {
      hotKeyManager.register(value, keyDownHandler: (hotKey) {
        Provider.of<SoundsModel>(context, listen: false).play(key);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                borderWidth, 0, borderWidth, borderWidth),
            child: FadeInLeft(
              duration: const Duration(milliseconds: 300),
              child: Tabs(
                selected: _tab,
                onSelected: (selected) => setState(() => _tab = selected),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(0, 0, borderWidth, borderWidth),
              child: switch (_tab) {
                TabType.soundboard => const SoundboardTab(),
                TabType.sounds => const SoundsTab(),
                TabType.members => const MembersTab()
              },
            ),
          ),
        ],
      ),
    );
  }
}
