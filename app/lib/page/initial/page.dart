import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.transparent,
        ),
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
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
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
              ),
            ),
          ),
        )
      ],
    );
  }
}
