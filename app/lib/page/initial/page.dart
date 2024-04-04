import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(borderWidth, 0, borderWidth, borderWidth),
      child: Container(
        decoration: const BoxDecoration(
            color: BrandColors.black,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                      duration: Durations.medium1,
                      delay: Durations.medium1,
                      child: Text("Sonar".toUpperCase(),
                          style: GoogleFonts.bebasNeue(
                            textStyle: const TextStyle(
                                color: BrandColors.white,
                                fontSize: 195,
                                height: 0.65,
                                letterSpacing: 20),
                          ))),
                  const SizedBox(
                    height: 25,
                  ),
                  FadeIn(
                    delay: Durations.long1,
                    child: Text("By VimHax".toUpperCase(),
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                              color: BrandColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              height: 0.65,
                              letterSpacing: 5),
                        )),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 50),
              child: FadeIn(
                delay: Durations.long4,
                child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    child: Text("Continue".toUpperCase(),
                        style: GoogleFonts.montserrat(
                            textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2)))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
