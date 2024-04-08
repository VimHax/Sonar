import 'dart:async';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:app/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    _sub = supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        Navigator.pushReplacementNamed(context, "/main");
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
                child: FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  delay: const Duration(milliseconds: 200),
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
                  delay: const Duration(milliseconds: 400),
                  child: _loading
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(),
                        )
                      : TextButton(
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
                                            'https://sonar-xi.vercel.app/');
                                    stdout.writeln("Signed In!");
                                  } catch (e) {
                                    setState(() {
                                      _loading = false;
                                    });
                                    if (context.mounted) {
                                      showErrorSnackBar(
                                          context, 'Failed to login.');
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
