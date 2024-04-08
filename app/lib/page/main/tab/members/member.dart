import 'package:app/models/intros.dart';
import 'package:app/models/members.dart';
import 'package:app/models/sounds.dart';
import 'package:app/page/main/tab/members/member_dialog.dart';
import 'package:app/page/main/tab/sounds/edit_sound_dialog.dart';
import 'package:app/util/colors.dart';
import 'package:app/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MemberRow extends StatefulWidget {
  const MemberRow({super.key, required this.member});

  final Member member;

  @override
  State<MemberRow> createState() => _MemberRowState();
}

class _MemberRowState extends State<MemberRow> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: TextButton(
        style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(0))),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => MemberDialog(member: widget.member),
          );
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
                      backgroundImage: NetworkImage(widget.member.avatar),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 0,
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
                  children: widget.member.global_name == null
                      ? [
                          Text(widget.member.username,
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                    color: BrandColors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    height: 0.9),
                              ))
                        ]
                      : [
                          Text(widget.member.username,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: BrandColors.white.withAlpha(100),
                                    fontSize: 12),
                              )),
                          Text(widget.member.global_name!,
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                    color: BrandColors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    height: 0.9),
                              )),
                          const SizedBox(
                            height: 4,
                          )
                        ],
                ),
              ],
            ),
            Row(
              children: [
                Text("intro:",
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                          color: BrandColors.whiteA, fontSize: 16),
                    )),
                const SizedBox(
                  width: 15,
                ),
                Consumer2<SoundsModel, IntrosModel>(
                  builder: (context, sounds, intros, child) {
                    if (sounds.all == null || intros.all == null) {
                      return const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    Intro? intro = intros.get(widget.member.id);
                    if (intro == null) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Text("None",
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                  color: BrandColors.white, fontSize: 16),
                            )),
                      );
                    }
                    Sound sound = sounds.get(intro.sound)!;
                    return TextButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36),
                            )),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.fromLTRB(4, 11, 15, 11))),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => EditSoundDialog(sound: sound),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundImage:
                                  NetworkImage(getThumbnail(sound)),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(sound.name,
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                      color: BrandColors.white, fontSize: 14),
                                ))
                          ],
                        ));
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
