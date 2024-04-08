import 'package:app/page/main/members.dart';
import 'package:app/page/main/tab/members/member_dialog.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberRow extends StatefulWidget {
  const MemberRow({super.key, required this.member});

  final Member member;

  @override
  State<MemberRow> createState() => _MemberRowState();
}

class _MemberRowState extends State<MemberRow> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          TextButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(0))),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => MemberDialog(member: widget.member),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(widget.member.avatar),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Center(
                  child: Container(
                    height: 50,
                    width: 1,
                    color: BrandColors.whiteA,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.member.global_name == null
                      ? [
                          Text(widget.member.username,
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                    color: BrandColors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    height: 0.9),
                              ))
                        ]
                      : [
                          Text(widget.member.username,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: BrandColors.white.withAlpha(100),
                                    fontSize: 12),
                              )),
                          Text(widget.member.global_name!,
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                    color: BrandColors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    height: 0.9),
                              ))
                        ],
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 25),
            child: DropdownButton(
                value: "None",
                onChanged: (value) {},
                // requestFocusOnTap: false,
                items: const [
                  DropdownMenuItem(value: "None", child: Text("None")),
                  DropdownMenuItem(value: "Sound 1", child: Text("Sound 1"))
                ]),
          )
        ],
      ),
    );
  }
}
