import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TabButton extends StatelessWidget {
  const TabButton({super.key, required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TextButton(
          onPressed: () {},
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              )),
              side: MaterialStateProperty.all(BorderSide.none),
              padding: MaterialStateProperty.all(const EdgeInsets.all(0))),
          child: Icon(
            icon,
            size: 35,
          )),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final User _user = supabase.auth.currentSession!.user;
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    // stdout.writeln(_user);
    _sub = supabase.auth.onAuthStateChange.listen((data) {
      if (data.session == null) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                borderWidth, 0, borderWidth, borderWidth),
            child: FadeInLeft(
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 75,
                decoration: const BoxDecoration(
                    color: BrandColors.grey,
                    borderRadius:
                        BorderRadius.all(Radius.circular(borderRadius))),
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FadeIn(
                              delay: const Duration(milliseconds: 200),
                              child: const TabButton(
                                icon: Icons.play_arrow_sharp,
                              )),
                          FadeIn(
                              delay: const Duration(milliseconds: 400),
                              child: const TabButton(
                                icon: Icons.library_music_sharp,
                              )),
                          FadeIn(
                              delay: const Duration(milliseconds: 600),
                              child: const TabButton(
                                icon: Icons.group_sharp,
                              )),
                        ],
                      ),
                    ),
                    Container(
                        alignment: Alignment.bottomRight,
                        child: FadeIn(
                          delay: const Duration(milliseconds: 800),
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
                        ))
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(0, 0, borderWidth, borderWidth),
              child: FadeIn(
                child: Container(
                  decoration: const BoxDecoration(
                      color: BrandColors.grey,
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius))),
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
                                child: Text("Sounds",
                                    style: GoogleFonts.bebasNeue(
                                      textStyle: const TextStyle(
                                          color: BrandColors.white,
                                          fontSize: 100,
                                          height: 0.84,
                                          letterSpacing: 0),
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
                                      border: Border.all(
                                          color: BrandColors.whiteA)))))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
