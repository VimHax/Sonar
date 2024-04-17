import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/models/members.dart';
import 'package:app/page/main/tab/members/member.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MembersTab extends StatelessWidget {
  const MembersTab({super.key});

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
                  child: Text("Members",
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
                    child: Consumer<MembersModel>(
                      builder: (context, members, child) => members.all == null
                          ? const Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : members.all!.isEmpty
                              ? Center(
                                  child: Text("No members.",
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
                                    columnSizes: [1.fr, 1.fr],
                                    rowSizes: List.filled(
                                        (members.all!.length / 2.0).ceil(),
                                        auto),
                                    columnGap: borderWidth,
                                    rowGap: borderWidth,
                                    children: members.all!
                                        .map((e) => MemberRow(member: e))
                                        .indexed
                                        .map((e) => FadeIn(
                                            delay: Duration(
                                                milliseconds: 75 * e.$1),
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
