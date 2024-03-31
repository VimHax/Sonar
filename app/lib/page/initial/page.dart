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
          alignment: Alignment.center,
          child: FittedBox(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                      text: TextSpan(
                          style: GoogleFonts.robotoMono(
                              textStyle: const TextStyle(
                                  color: BrandColors.red,
                                  fontSize: 15,
                                  letterSpacing: 10,
                                  fontWeight: FontWeight.w500)),
                          children: const [
                        TextSpan(text: "V1.0.0 "),
                        TextSpan(
                            text: "-",
                            style: TextStyle(color: BrandColors.dimBlue)),
                        TextSpan(text: " BY VIMHAX")
                      ])),
                  Text("SONAR",
                      style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                              color: BrandColors.white,
                              fontSize: 100,
                              letterSpacing: 50,
                              fontWeight: FontWeight.w600))),
                  const SizedBox(height: 10),
                ]),
          ),
        )
      ],
    );
  }
}
