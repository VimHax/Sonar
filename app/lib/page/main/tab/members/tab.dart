import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MembersTab extends StatefulWidget {
  const MembersTab({super.key});

  @override
  State<MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> {
  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Container(
        decoration: const BoxDecoration(
            color: BrandColors.grey,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        padding: const EdgeInsets.all(64.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 73,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeIn(
                      delay: const Duration(milliseconds: 200),
                      child: Text("Members",
                          style: GoogleFonts.bebasNeue(
                            textStyle: const TextStyle(
                                color: BrandColors.white,
                                fontSize: 100,
                                height: 0.84),
                          ))),
                  FadeIn(
                      delay: const Duration(milliseconds: 400),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: TextButton(
                            onPressed: () {},
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(0))),
                            child: const Icon(
                              Icons.add_sharp,
                              size: 35,
                            )),
                      )),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: FadeIn(
                    delay: const Duration(milliseconds: 600),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                                Radius.circular(borderRadius)),
                            border: Border.all(color: BrandColors.whiteA)))))
          ],
        ),
      ),
    );
  }
}
