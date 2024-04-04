import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const fadeStagger = 100;

class AccountDialog extends StatelessWidget {
  const AccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: FadeIn(
            duration: Durations.medium1,
            delay: const Duration(milliseconds: fadeStagger),
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
                      FadeIn(
                        duration: Durations.medium1,
                        delay: const Duration(milliseconds: fadeStagger * 2),
                        child: AspectRatio(
                          aspectRatio: 3,
                          child: Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(borderRadius)),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        "https://images.pexels.com/photos/20708115/pexels-photo-20708115/free-photo-of-freja.jpeg"))),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(32, 16 + 65, 32, 32),
                        child: FadeIn(
                          duration: Durations.medium1,
                          delay: const Duration(milliseconds: fadeStagger * 4),
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
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("vimhax",
                                          style: GoogleFonts.montserrat(
                                            textStyle: const TextStyle(
                                                color: BrandColors.white,
                                                fontSize: 16),
                                          )),
                                      Text("VimHax",
                                          style: GoogleFonts.montserrat(
                                            textStyle: const TextStyle(
                                                color: BrandColors.white,
                                                fontSize: 32,
                                                fontWeight: FontWeight.w600,
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
                        ),
                      )
                    ],
                  ),
                  Positioned(
                      left: 32,
                      top: 550 / 3 - 65,
                      child: FadeIn(
                        duration: Durations.medium1,
                        delay: const Duration(milliseconds: fadeStagger * 3),
                        child: const CircleAvatar(
                          backgroundColor: BrandColors.grey,
                          radius: 65.0,
                          child: CircleAvatar(
                            radius: 55,
                            backgroundImage: NetworkImage(
                              "https://cdn.discordapp.com/avatars/242674430566858753/b6e7d53e222626bd84df16cf8607a3e8.png",
                            ),
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
