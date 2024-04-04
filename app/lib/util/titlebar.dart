import 'dart:ui';

import 'package:app/main.dart';
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
            // overlayColor: MaterialStateProperty.all(BrandColors.blackA),
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
        height: 35 + 2 * borderWidth,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius))),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(borderWidth),
              child: Container(
                constraints: const BoxConstraints.expand(width: 75),
                decoration: const BoxDecoration(
                    color: BrandColors.black,
                    borderRadius:
                        BorderRadius.all(Radius.circular(borderRadius))),
                alignment: Alignment.center,
                child: Text("SONAR",
                    style: GoogleFonts.montserrat(
                        textStyle: const TextStyle(
                            color: BrandColors.white,
                            fontSize: 10,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600))),
              ),
            ),
            Row(
              children: [
                Expanded(child: MoveWindow()),
                Padding(
                  padding: const EdgeInsets.all(borderWidth),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: BrandColors.black,
                        borderRadius:
                            BorderRadius.all(Radius.circular(borderRadius))),
                    child: Row(
                      children: [
                        WindowButton(
                          icon: SvgPicture.asset(
                            "images/titlebar/minimize.svg",
                            colorFilter: const ColorFilter.mode(
                                BrandColors.white, BlendMode.srcIn),
                            width: 17,
                            height: 17,
                          ),
                          onPressed: () => appWindow.minimize(),
                        ),
                        WindowButton(
                          icon: SvgPicture.asset(
                            "images/titlebar/maximize.svg",
                            colorFilter: const ColorFilter.mode(
                                BrandColors.white, BlendMode.srcIn),
                            width: 17,
                            height: 17,
                          ),
                          onPressed: () => appWindow.maximizeOrRestore(),
                        ),
                        WindowButton(
                          icon: SvgPicture.asset(
                            "images/titlebar/close.svg",
                            colorFilter: const ColorFilter.mode(
                                BrandColors.white, BlendMode.srcIn),
                            width: 17,
                            height: 17,
                          ),
                          onPressed: () => appWindow.close(),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
