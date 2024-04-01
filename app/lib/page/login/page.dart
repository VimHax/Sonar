import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: FadeInDown(
            duration: Durations.medium1,
            delay: Durations.medium1,
            child: Text("Login".toUpperCase(),
                style: GoogleFonts.bebasNeue(
                  textStyle: const TextStyle(
                      color: BrandColors.white,
                      fontSize: 195,
                      height: 0.65,
                      letterSpacing: 20),
                )),
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
                child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/");
                    },
                    child: Text("Login with Discord".toUpperCase(),
                        style: GoogleFonts.montserrat(
                            textStyle: const TextStyle(
                                color: BrandColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2)))),
              ),
            ),
          ),
        )
      ],
    );
  }
}
