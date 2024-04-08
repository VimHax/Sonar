import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/page/main/members.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberDialog extends StatelessWidget {
  const MemberDialog({super.key, required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: FadeInDown(
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: const BoxDecoration(
                color: BrandColors.grey,
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              ),
              width: 550,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: 3,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: member.accent_color == null
                                  ? BrandColors.blackA
                                  : Color(0xFF000000 + member.accent_color!),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(borderRadius)),
                              image: member.banner == null
                                  ? null
                                  : DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          "${member.banner!}?size=4096"))),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(32, 16 + 65, 32, 32),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: BrandColors.blackA,
                            borderRadius:
                                BorderRadius.all(Radius.circular(borderRadius)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: member.global_name == null
                                      ? [
                                          Text(member.username,
                                              style: GoogleFonts.montserrat(
                                                textStyle: const TextStyle(
                                                    color: BrandColors.white,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w600,
                                                    height: 0.9),
                                              ))
                                        ]
                                      : [
                                          Text(member.username,
                                              style: GoogleFonts.montserrat(
                                                textStyle: const TextStyle(
                                                    color: BrandColors.white,
                                                    fontSize: 16),
                                              )),
                                          Text(member.global_name!,
                                              style: GoogleFonts.montserrat(
                                                textStyle: const TextStyle(
                                                    color: BrandColors.white,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w600,
                                                    height: 0.9),
                                              ))
                                        ],
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Positioned(
                      left: 32,
                      top: 550 / 3 - 65,
                      child: CircleAvatar(
                        backgroundColor: BrandColors.grey,
                        radius: 65.0,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: BrandColors.blackA,
                          backgroundImage: NetworkImage(
                            member.avatar,
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
