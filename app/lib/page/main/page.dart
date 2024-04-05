import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/page/main/member.dart';
import 'package:app/page/main/tab/audit_log/tab.dart';
import 'package:app/page/main/tab/members/tab.dart';
import 'package:app/page/main/tab/soundboard/tab.dart';
import 'package:app/page/main/tab/sounds/tab.dart';
import 'package:app/page/main/tabs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  StreamSubscription<AuthState>? _sub;
  TabType _tab = TabType.sounds;

  @override
  void initState() {
    getMember();
    _sub = supabase.auth.onAuthStateChange.listen((data) {
      if (data.session == null) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  Future<void> getMember() async {
    var res = await supabase.functions.invoke("get-member");
    if (res.status != 200) return;
    setState(() => Provider.of<MemberModel>(context, listen: false)
        .set(Member.fromJson(res.data)));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
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
                TabType.members => const MembersTab(),
                TabType.auditLog => const AuditLogTab(),
              },
            ),
          ),
        ],
      ),
    );
  }
}
