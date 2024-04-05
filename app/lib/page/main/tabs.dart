import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/page/main/account_dialog.dart';
import 'package:app/page/main/member.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const fadeStagger = 100;

enum TabType { soundboard, sounds, members, auditLog }

class TabButton extends StatelessWidget {
  const TabButton(
      {super.key,
      required this.icon,
      required this.selected,
      required this.onPressed});

  final IconData icon;
  final bool selected;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TextButton(
          onPressed: selected ? null : onPressed,
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                return states.contains(MaterialState.disabled)
                    ? BrandColors.white
                    : Colors.transparent;
              }),
              foregroundColor: MaterialStateProperty.resolveWith((states) {
                return states.contains(MaterialState.disabled)
                    ? BrandColors.black
                    : BrandColors.white;
              }),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              )),
              side: MaterialStateProperty.all(BorderSide.none),
              padding: MaterialStateProperty.all(const EdgeInsets.all(0))),
          child: Icon(
            icon,
            size: 35,
          )),
    );
  }
}

class Tabs extends StatelessWidget {
  const Tabs({super.key, required this.selected, required this.onSelected});

  final TabType selected;
  final void Function(TabType) onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      decoration: const BoxDecoration(
          color: BrandColors.grey,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeIn(
                    delay: const Duration(milliseconds: fadeStagger),
                    child: TabButton(
                      icon: Icons.play_arrow_sharp,
                      selected: selected == TabType.soundboard,
                      onPressed: () => onSelected(TabType.soundboard),
                    )),
                FadeIn(
                    delay: const Duration(milliseconds: fadeStagger * 2),
                    child: TabButton(
                      icon: Icons.library_music_sharp,
                      selected: selected == TabType.sounds,
                      onPressed: () => onSelected(TabType.sounds),
                    )),
                FadeIn(
                    delay: const Duration(milliseconds: fadeStagger * 3),
                    child: TabButton(
                      icon: Icons.group_sharp,
                      selected: selected == TabType.members,
                      onPressed: () => onSelected(TabType.members),
                    )),
                FadeIn(
                    delay: const Duration(milliseconds: fadeStagger * 4),
                    child: TabButton(
                      icon: Icons.list_sharp,
                      selected: selected == TabType.auditLog,
                      onPressed: () => onSelected(TabType.auditLog),
                    )),
              ],
            ),
          ),
          Container(
              alignment: Alignment.bottomRight,
              child: FadeIn(
                delay: const Duration(milliseconds: fadeStagger * 5),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => const AccountDialog());
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          shape: MaterialStateProperty.all(
                              const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(borderRadius),
                                bottomRight: Radius.circular(borderRadius)),
                          )),
                          side: MaterialStateProperty.all(BorderSide.none),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(0))),
                      child: Consumer<MemberModel>(
                        builder: (context, member, child) =>
                            member.value == null
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  )
                                : CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(
                                      member.value!.avatar,
                                    ),
                                  ),
                      )),
                ),
              ))
        ],
      ),
    );
  }
}
