import 'dart:ui';

import 'package:app/util/colors.dart';
import 'package:app/util/hover_button.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class WindowButton extends StatelessWidget {
  const WindowButton({required this.icon, required this.onPressed, super.key});

  final Widget icon;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
        onPressed: onPressed,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            minimumSize: MaterialStateProperty.all(const Size(30, 30)),
            padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
            side: MaterialStateProperty.all(BorderSide.none)),
        child: (hovering) {
          return Container(
            width: 35,
            height: 35,
            alignment: Alignment.center,
            color: const Color(0x00000000),
            child: icon,
          );
        });
  }
}

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 35,
        decoration: const BoxDecoration(
            color: BrandColors.blackA,
            border: Border(
                bottom: BorderSide(color: BrandColors.whiteA, width: 1))),
        child: Stack(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 11),
              // padding: const EdgeInsets.only(left: 8.5),
              child: Row(
                children: [
                  // Container(
                  //   width: 18,
                  //   height: 18,
                  //   alignment: Alignment.center,
                  //   decoration: BoxDecoration(
                  //       color: BrandColors.white,
                  //       borderRadius: BorderRadius.all(Radius.circular(5))),
                  //   child: const Icon(
                  //     Icons.music_note_sharp,
                  //     size: 16,
                  //     color: BrandColors.black,
                  //   ),
                  // ),
                  // const SizedBox(width: 8.5),
                  Text("SONAR",
                      style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                              color: BrandColors.white,
                              fontSize: 10,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w600)))
                ],
              ),
            ),
            Row(
              children: [
                Expanded(child: MoveWindow()),
                WindowButton(
                  icon: SvgPicture.asset(
                    "images/titlebar/minimize.svg",
                    width: 17,
                    height: 17,
                  ),
                  onPressed: () => appWindow.minimize(),
                ),
                WindowButton(
                  icon: SvgPicture.asset(
                    "images/titlebar/maximize.svg",
                    width: 17,
                    height: 17,
                  ),
                  onPressed: () => appWindow.maximizeOrRestore(),
                ),
                WindowButton(
                  icon: SvgPicture.asset(
                    "images/titlebar/close.svg",
                    width: 17,
                    height: 17,
                  ),
                  onPressed: () => appWindow.close(),
                ),
              ],
            )
          ],
        ));
  }
}
