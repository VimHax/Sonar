import 'dart:io';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  bool _loading = false;
  final User _user = supabase.auth.currentSession!.user;

  @override
  void initState() {
    stdout.writeln(_user);
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.session == null) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.transparent,
        ),
        Container(
          alignment: Alignment.topCenter,
          padding:
              const EdgeInsets.symmetric(vertical: 32 + 35, horizontal: 32),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Image(
                    width: 40,
                    height: 40,
                    image: NetworkImage(
                      "https://cdn.discordapp.com/avatars/242674430566858753/b6e7d53e222626bd84df16cf8607a3e8.png",
                    )),
                Container(
                  decoration: BoxDecoration(
                      border: Border.symmetric(
                          horizontal: BorderSide(
                              color: BrandColors.white.withAlpha(50)))),
                  padding: const EdgeInsets.fromLTRB(20, 7, 20, 8),
                  child: const Text(
                    "VimHax",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 20))),
                    child: const Icon(
                      Icons.logout,
                      size: 16,
                    ))
              ],
            ),
          ),
        )
      ],
    );
  }
}
