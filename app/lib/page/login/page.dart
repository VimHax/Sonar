import 'dart:io';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _loading = false;

  @override
  void initState() {
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        Navigator.pushReplacementNamed(context, "/main");
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
        Center(
          child: FadeInDown(
            duration: Durations.medium1,
            delay: Durations.medium1,
            child: Text("Login".toUpperCase(),
                style: GoogleFonts.bebasNeue(
                  textStyle: const TextStyle(
                      color: BrandColors.white,
                      fontSize: 195,
                      height: 0.65,
                      letterSpacing: 20),
                )),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: _loading ? 100 : 50),
          child: FadeIn(
            delay: Durations.long4,
            child: _loading
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  )
                : ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                      child: TextButton(
                          onPressed: _loading
                              ? null
                              : () async {
                                  setState(() {
                                    _loading = true;
                                  });
                                  try {
                                    stdout.writeln("Signing In!");
                                    await supabase.auth.signInWithOAuth(
                                        OAuthProvider.discord,
                                        redirectTo:
                                            'com.vimhax.sonar://login-callback');
                                    stdout.writeln("Signed In!");
                                  } catch (e) {
                                    setState(() {
                                      _loading = false;
                                    });
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('Login failed'),
                                        backgroundColor: BrandColors.red,
                                      ));
                                    }
                                  }
                                },
                          child: Text("Login with Discord".toUpperCase(),
                              style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2)))),
                    ),
                  ),
          ),
        )
      ],
    );
  }
}
