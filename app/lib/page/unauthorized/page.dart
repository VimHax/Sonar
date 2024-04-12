import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/models/members.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UnauthorizedPage extends StatefulWidget {
  const UnauthorizedPage({super.key});

  @override
  State<UnauthorizedPage> createState() => _UnauthorizedPageState();
}

class _UnauthorizedPageState extends State<UnauthorizedPage> {
  late final MembersModel _membersProvider;

  @override
  void initState() {
    _membersProvider = context.read<MembersModel>();
    _membersProvider.addListener(_onMembersUpdate);
    _onMembersUpdate();
    super.initState();
  }

  @override
  void dispose() {
    _membersProvider.removeListener(_onMembersUpdate);
    super.dispose();
  }

  void _onMembersUpdate() {
    var members = _membersProvider.all;
    if (members == null) return;
    var me = _membersProvider.me;
    if (me != null && me.joined) {
      Navigator.pushReplacementNamed(context, "/main");
    }
  }

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
                        child: Text("Unauthorized".toUpperCase(),
                            style: GoogleFonts.bebasNeue(
                              textStyle: const TextStyle(
                                  color: BrandColors.white,
                                  fontSize: 195,
                                  height: 0.65),
                            ))),
                    const SizedBox(
                      height: 25,
                    ),
                    FadeIn(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                          "Join the Discord server to continue".toUpperCase(),
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
                padding: const EdgeInsets.only(bottom: 100),
                child: FadeIn(
                  delay: const Duration(milliseconds: 600),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
