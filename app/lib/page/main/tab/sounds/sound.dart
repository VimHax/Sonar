import 'dart:async';

import 'package:app/models/members.dart';
import 'package:app/models/sounds.dart';
import 'package:app/page/main/tab/members/member_dialog.dart';
import 'package:app/page/main/tab/sounds/edit_sound_dialog.dart';
import 'package:app/page/main/tab/sounds/hotkey_view.dart';
import 'package:app/util/colors.dart';
import 'package:app/util/storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

enum SoundState { none, loading, playing }

class SoundRow extends StatefulWidget {
  const SoundRow({super.key, required this.sound, required this.member});

  final Sound sound;
  final Member member;

  @override
  State<SoundRow> createState() => _SoundRowState();
}

class _SoundRowState extends State<SoundRow> {
  late final AudioPlayer _player;
  SoundState _state = SoundState.none;
  StreamSubscription? _sub;

  @override
  void initState() {
    _player = AudioPlayer();
    _player.setVolume(0.1);
    _sub = _player.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        setState(() => _state = SoundState.playing);
      } else if (event == PlayerState.stopped) {
        setState(() => _state = SoundState.none);
      } else if (event == PlayerState.completed) {
        setState(() => _state = SoundState.none);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: TextButton(
        style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(0))),
        onPressed: () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => EditSoundDialog(
                    sound: widget.sound,
                  ));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(getThumbnail(widget.sound)),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 50,
                    width: 1,
                    color: BrandColors.whiteA,
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.sound.name,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                              color: BrandColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 0.9),
                        ))
                  ],
                )
              ],
            ),
            Row(
              children: [
                Text("shortcut:",
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                          color: BrandColors.whiteA, fontSize: 16),
                    )),
                const SizedBox(
                  width: 15,
                ),
                HotKeyView(
                    hotKey: HotKey(
                  key: PhysicalKeyboardKey.keyA,
                  modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
                  scope: HotKeyScope.system,
                ))
              ],
            ),
            Row(
              children: [
                Text("creator:",
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                          color: BrandColors.whiteA, fontSize: 16),
                    )),
                const SizedBox(
                  width: 15,
                ),
                TextButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36),
                        )),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.fromLTRB(4, 11, 15, 11))),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            MemberDialog(member: widget.member),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(widget.member.avatar),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                            widget.member.global_name ?? widget.member.username,
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                  color: BrandColors.white, fontSize: 14),
                            ))
                      ],
                    ))
              ],
            ),
            Row(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(0))),
                        onPressed: _state == SoundState.loading
                            ? null
                            : () async {
                                if (_state == SoundState.none) {
                                  setState(() => _state = SoundState.loading);
                                  _player
                                      .play(UrlSource(getAudio(widget.sound)));
                                } else if (_state == SoundState.playing) {
                                  _player.stop();
                                }
                              },
                        child: switch (_state) {
                          SoundState.none => const Icon(Icons.play_arrow_sharp),
                          SoundState.loading => const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(),
                            ),
                          SoundState.playing => const Icon(Icons.stop_sharp),
                        }),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
