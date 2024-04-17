import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/models/intros.dart';
import 'package:app/models/members.dart';
import 'package:app/models/sounds.dart';
import 'package:app/util/colors.dart';
import 'package:app/util/snackbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MemberDialog extends StatefulWidget {
  const MemberDialog({super.key, required this.id});

  final String id;

  @override
  State<MemberDialog> createState() => _MemberDialogState();
}

class _MemberDialogState extends State<MemberDialog> {
  bool _loading = false;
  bool _intros = false;
  String? _selected;
  late final IntrosModel _introProvider;

  @override
  void initState() {
    _introProvider = context.read<IntrosModel>();
    _introProvider.addListener(_onIntrosUpdate);
    _onIntrosUpdate();
    super.initState();
  }

  @override
  void dispose() {
    _introProvider.removeListener(_onIntrosUpdate);
    super.dispose();
  }

  void _onIntrosUpdate() {
    setState(() {
      _intros = _introProvider.all != null;
      if (!_intros) return;
      Intro? intro = _introProvider.get(widget.id);
      _selected = intro == null
          ? null
          : Provider.of<SoundsModel>(context, listen: false)
              .get(intro.sound)!
              .id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: FadeInDown(
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: const BoxDecoration(
                color: BrandColors.grey,
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              ),
              width: 550,
              child: Consumer<MembersModel>(builder: (context, members, child) {
                var member = members.get(widget.id);
                return Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: 3,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: member.accent_color == null
                                    ? BrandColors.blackA
                                    : Color(0xFF000000 + member.accent_color!),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(borderRadius)),
                                image: member.banner == null
                                    ? null
                                    : DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            "${member.banner!}?size=4096"))),
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(32, 16 + 65, 32, 32),
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
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: member.global_name == null
                                          ? [
                                              Text(member.username,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                        color:
                                                            BrandColors.white,
                                                        fontSize: 32,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 0.9),
                                                  ))
                                            ]
                                          : [
                                              Text(member.username,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                        color:
                                                            BrandColors.white,
                                                        fontSize: 16),
                                                  )),
                                              Text(member.global_name!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: const TextStyle(
                                                        color:
                                                            BrandColors.white,
                                                        fontSize: 32,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 0.9),
                                                  ))
                                            ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text("intro:",
                                          style: GoogleFonts.montserrat(
                                            textStyle: const TextStyle(
                                                color: BrandColors.whiteA,
                                                fontSize: 16),
                                          )),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Consumer<SoundsModel>(
                                        builder: (context, sounds, child) =>
                                            !_intros || sounds.all == null
                                                ? const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 15),
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  )
                                                : DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton2<String>(
                                                      isExpanded: true,
                                                      items: [
                                                        const DropdownMenuItem<
                                                            String>(
                                                          value: null,
                                                          child: Text(
                                                            "None",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                        ...sounds.all!.map((Sound
                                                                item) =>
                                                            DropdownMenuItem<
                                                                String>(
                                                              value: item.id,
                                                              child: Text(
                                                                item.name,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                softWrap: false,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ))
                                                      ],
                                                      value: _selected,
                                                      onChanged: _loading
                                                          ? null
                                                          : (String?
                                                              value) async {
                                                              setState(() {
                                                                _loading = true;
                                                                _selected =
                                                                    value;
                                                              });
                                                              try {
                                                                if (value ==
                                                                    null) {
                                                                  await supabase
                                                                      .from(
                                                                          "intros")
                                                                      .delete()
                                                                      .eq(
                                                                          "id",
                                                                          member
                                                                              .id);
                                                                } else {
                                                                  await supabase
                                                                      .from(
                                                                          "intros")
                                                                      .upsert({
                                                                    'id': member
                                                                        .id,
                                                                    'sound':
                                                                        value
                                                                  });
                                                                }
                                                                setState(() =>
                                                                    _loading =
                                                                        false);
                                                              } catch (e) {
                                                                setState(() =>
                                                                    _loading =
                                                                        false);
                                                                if (context
                                                                    .mounted) {
                                                                  showErrorSnackBar(
                                                                      context,
                                                                      "Error occurred when setting intro.");
                                                                }
                                                              }
                                                            },
                                                      buttonStyleData: ButtonStyleData(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16),
                                                          height: 40,
                                                          width: 140,
                                                          decoration: BoxDecoration(
                                                              color: BrandColors
                                                                  .whiteA,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          borderRadius))),
                                                      menuItemStyleData:
                                                          const MenuItemStyleData(
                                                              height: 40),
                                                      iconStyleData: _loading
                                                          ? const IconStyleData(
                                                              icon: Center(
                                                              child: SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                            ))
                                                          : const IconStyleData(),
                                                      dropdownStyleData:
                                                          DropdownStyleData(
                                                              decoration:
                                                                  BoxDecoration(
                                                        color: BrandColors.grey,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                borderRadius),
                                                      )),
                                                    ),
                                                  ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Positioned(
                        left: 32,
                        top: 550 / 3 - 65,
                        child: CircleAvatar(
                          backgroundColor: BrandColors.grey,
                          radius: 65.0,
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: BrandColors.blackA,
                            backgroundImage: NetworkImage(
                              member.avatar,
                            ),
                          ),
                        ))
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
