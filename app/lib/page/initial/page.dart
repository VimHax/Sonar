import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding:
          const EdgeInsets.fromLTRB(borderWidth, 0, borderWidth, borderWidth),
      child: FadeIn(
        child: Container(
          decoration: const BoxDecoration(
              color: BrandColors.grey,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeInDown(
                        duration: const Duration(milliseconds: 300),
                        delay: const Duration(milliseconds: 200),
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
                      delay: const Duration(milliseconds: 400),
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
                  delay: const Duration(milliseconds: 600),
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
      ),
    );
  }
}
