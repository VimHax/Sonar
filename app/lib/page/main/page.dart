import 'dart:io';

import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
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
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 35, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 75,
            decoration: const BoxDecoration(
                color: BrandColors.blackA,
                border: Border(right: BorderSide(color: BrandColors.whiteA))),
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // const Divider(
                      //   height: 1,
                      //   color: BrandColors.whiteA,
                      // ),
                      AspectRatio(
                        aspectRatio: 1,
                        child: TextButton(
                            onPressed: () {},
                            style: ButtonStyle(
                                side:
                                    MaterialStateProperty.all(BorderSide.none),
                                maximumSize: null,
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(0))),
                            child: const Icon(
                              Icons.play_arrow_sharp,
                              size: 35,
                            )),
                      ),
                      AspectRatio(
                        aspectRatio: 1,
                        child: TextButton(
                            onPressed: () {},
                            style: ButtonStyle(
                                side:
                                    MaterialStateProperty.all(BorderSide.none),
                                maximumSize: null,
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(0))),
                            child: const Icon(
                              Icons.library_music_sharp,
                              size: 35,
                            )),
                      ),
                      AspectRatio(
                        aspectRatio: 1,
                        child: TextButton(
                            onPressed: () {},
                            style: ButtonStyle(
                                side:
                                    MaterialStateProperty.all(BorderSide.none),
                                maximumSize: null,
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(0))),
                            child: const Icon(
                              Icons.group_sharp,
                              size: 35,
                            )),
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          "https://cdn.discordapp.com/avatars/242674430566858753/b6e7d53e222626bd84df16cf8607a3e8.png",
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Colors.transparent,
                ),
                Padding(
                  padding: const EdgeInsets.all(64.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sounds",
                              style: GoogleFonts.bebasNeue(
                                textStyle: const TextStyle(
                                    color: BrandColors.white,
                                    fontSize: 100,
                                    height: 0.84,
                                    letterSpacing: 0),
                              )),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.all(30))),
                                  child: const Icon(
                                    Icons.add_sharp,
                                    size: 30,
                                  ))
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: BrandColors.blackA,
                                  border:
                                      Border.all(color: BrandColors.whiteA))))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
