import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/models/sounds.dart';
import 'package:app/page/main/tab/sounds/add_sound_dialog.dart';
import 'package:app/page/main/tab/sounds/sound.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SoundsTab extends StatelessWidget {
  const SoundsTab({super.key});

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
            FadeIn(
              delay: const Duration(milliseconds: 200),
              child: SizedBox(
                height: 73,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Sounds",
                        style: GoogleFonts.bebasNeue(
                          textStyle: const TextStyle(
                              color: BrandColors.white,
                              fontSize: 100,
                              height: 0.84),
                        )),
                    AspectRatio(
                      aspectRatio: 1,
                      child: TextButton(
                          onPressed: () {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => const AddSoundDialog());
                          },
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(0))),
                          child: const Icon(
                            Icons.add_sharp,
                            size: 35,
                          )),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: FadeIn(
                    delay: const Duration(milliseconds: 400),
                    child: Consumer<SoundsModel>(
                      builder: (context, sounds, child) => sounds.all == null
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
                                    columnSizes: [1.fr],
                                    rowSizes: List.filled(
                                        (sounds.all!.length / 1.0).ceil(),
                                        auto),
                                    columnGap: 10,
                                    rowGap: 10,
                                    children: sounds.all!
                                        .map((e) => SoundRow(sound: e))
                                        .indexed
                                        .map((e) => FadeIn(
                                            delay: Duration(
                                                milliseconds: 150 * e.$1),
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
