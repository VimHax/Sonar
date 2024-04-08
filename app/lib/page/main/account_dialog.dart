import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/models/members.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AccountDialog extends StatelessWidget {
  const AccountDialog({super.key});

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
              child: Consumer<MembersModel>(
                builder: (context, member, child) => Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: 3,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: member.me == null
                                    ? BrandColors.blackA
                                    : member.me!.accent_color == null
                                        ? BrandColors.blackA
                                        : Color(0xFF000000 +
                                            member.me!.accent_color!),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(borderRadius)),
                                image: member.me == null ||
                                        member.me!.banner == null
                                    ? null
                                    : DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            "${member.me!.banner!}?size=4096"))),
                            child: member.me == null
                                ? const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(),
                                  )
                                : null,
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(32, 16 + 65, 32, 32),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: BrandColors.blackA,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(borderRadius)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  member.me == null
                                      ? const AspectRatio(
                                          aspectRatio: 1,
                                          child: Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                        )
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: member.me!.global_name ==
                                                  null
                                              ? [
                                                  Text(member.me!.username,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle:
                                                            const TextStyle(
                                                                color:
                                                                    BrandColors
                                                                        .white,
                                                                fontSize: 32,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                height: 0.9),
                                                      ))
                                                ]
                                              : [
                                                  Text(member.me!.username,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle:
                                                            const TextStyle(
                                                                color:
                                                                    BrandColors
                                                                        .white,
                                                                fontSize: 16),
                                                      )),
                                                  Text(member.me!.global_name!,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle:
                                                            const TextStyle(
                                                                color:
                                                                    BrandColors
                                                                        .white,
                                                                fontSize: 32,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                height: 0.9),
                                                      ))
                                                ],
                                        ),
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: TextButton(
                                        onPressed: () {
                                          supabase.auth.signOut();
                                        },
                                        style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                const EdgeInsets.all(0))),
                                        child: const Icon(
                                          Icons.logout_sharp,
                                          size: 30,
                                        )),
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
                            backgroundImage: member.me == null
                                ? null
                                : NetworkImage(
                                    member.me!.avatar,
                                  ),
                            child: member.me != null
                                ? null
                                : const SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(),
                                  ),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
