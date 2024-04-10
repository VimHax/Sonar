import 'package:app/main.dart';
import 'package:app/models/members.dart';
import 'package:app/models/sounds.dart';
import 'package:app/util/colors.dart';
import 'package:app/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SoundButton extends StatelessWidget {
  const SoundButton(
      {super.key,
      required this.sound,
      required this.members,
      required this.onPressed});

  final Sound sound;
  final List<Member> members;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                color: BrandColors.blackA,
                borderRadius: BorderRadius.circular(borderRadius),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(getThumbnail(sound)))),
          ),
          Container(
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius - 2),
              gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [
                    0.1,
                    0.9,
                  ],
                  colors: [
                    BrandColors.black,
                    Colors.transparent
                  ]),
            ),
            child: Text(sound.name,
                style: GoogleFonts.montserrat(
                  textStyle: const TextStyle(
                      color: BrandColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 0.9),
                )),
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(16),
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 5,
              children: members
                  .map((e) => CircleAvatar(
                        radius: 15,
                        backgroundColor: BrandColors.black,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundImage: NetworkImage(e.avatar),
                        ),
                      ))
                  .toList(),
            ),
          ),
          TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                padding: MaterialStateProperty.all(const EdgeInsets.all(0))),
            onPressed: onPressed,
            child: Container(),
          ),
        ],
      ),
    );
  }
}
