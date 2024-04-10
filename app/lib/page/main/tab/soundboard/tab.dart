import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/models/members.dart';
import 'package:app/models/sounds.dart';
import 'package:app/page/main/tab/soundboard/sound.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SoundboardTab extends StatefulWidget {
  const SoundboardTab({super.key});

  @override
  State<SoundboardTab> createState() => _SoundboardTabState();
}

class _SoundboardTabState extends State<SoundboardTab> {
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
              child: FadeIn(
                  delay: const Duration(milliseconds: 200),
                  child: Text("Soundboard",
                      style: GoogleFonts.bebasNeue(
                        textStyle: const TextStyle(
                            color: BrandColors.white,
                            fontSize: 100,
                            height: 0.84),
                      ))),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: FadeIn(
                    delay: const Duration(milliseconds: 400),
                    child: Consumer2<MembersModel, SoundsModel>(
                      builder: (context, members, sounds, child) => members
                                      .all ==
                                  null ||
                              sounds.all == null
                          ? const Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : sounds.all!.isEmpty
                              ? Center(
                                  child: Text("No sounds.",
                                      style: GoogleFonts.montserrat(
                                        textStyle: const TextStyle(
                                            color: BrandColors.whiteA,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            height: 0.9),
                                      )),
                                )
                              : SingleChildScrollView(
                                  child: LayoutGrid(
                                    autoPlacement: AutoPlacement.rowSparse,
                                    gridFit: GridFit.loose,
                                    columnSizes: List.filled(5, 1.fr),
                                    rowSizes: List.filled(
                                        (sounds.all!.length / 1.0).ceil(),
                                        auto),
                                    columnGap: 10,
                                    rowGap: 10,
                                    children: sounds.all!
                                        .map((e) => SoundButton(
                                              sound: e,
                                              members: sounds.playing[e.id]
                                                      ?.map((e) => members
                                                          .getNullable(e))
                                                      .where((e) => e != null)
                                                      .map((e) => e as Member)
                                                      .toList() ??
                                                  [],
                                              onPressed: () {
                                                sounds.play(e.id);
                                              },
                                            ))
                                        .indexed
                                        .map((e) => FadeIn(
                                            delay: Duration(
                                                milliseconds: 100 * e.$1),
                                            child: e.$2))
                                        .toList(),
                                  ),
                                ),
                    )))
          ],
        ),
      ),
    );
  }
}
