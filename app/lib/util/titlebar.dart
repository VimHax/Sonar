import 'package:app/util/colors.dart';
import 'package:app/util/hover_button.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WindowButton extends StatelessWidget {
  const WindowButton({required this.icon, required this.onPressed, super.key});

  final Widget Function(Color) icon;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
        onPressed: onPressed,
        style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(const Size(30, 30)),
            padding: MaterialStateProperty.all(const EdgeInsets.all(0))),
        child: (hovering) {
          return Container(
            width: 35,
            height: 35,
            alignment: Alignment.center,
            color: hovering ? BrandColors.white : const Color(0x00000000),
            child: icon(hovering ? BrandColors.darkerBlue : BrandColors.white),
          );
        });
  }
}

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 35,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(child: MoveWindow()),
            WindowButton(
              icon: (color) {
                return SvgPicture.asset("images/titlebar/minimize.svg",
                    width: 17,
                    height: 17,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
              },
              onPressed: () => appWindow.minimize(),
            ),
            WindowButton(
              icon: (color) {
                return SvgPicture.asset("images/titlebar/maximize.svg",
                    width: 17,
                    height: 17,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
              },
              onPressed: () => appWindow.maximizeOrRestore(),
            ),
            WindowButton(
              icon: (color) {
                return SvgPicture.asset("images/titlebar/close.svg",
                    width: 17,
                    height: 17,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
              },
              onPressed: () => appWindow.close(),
            ),
          ],
        ));
  }
}
