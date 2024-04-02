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
        decoration: BoxDecoration(
            color: BrandColors.black.withAlpha(50),
            border: Border(
                bottom: BorderSide(
                    color: BrandColors.white.withAlpha(50), width: 1))),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 13),
                  child: Text("SONAR",
                      style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                              color: BrandColors.white,
                              fontSize: 10,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w600))),
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
            ),
          ),
        ));
  }
}
