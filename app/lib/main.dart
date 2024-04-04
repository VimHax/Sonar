import 'dart:io';

import 'package:app/page/initial/page.dart';
import 'package:app/page/login/page.dart';
import 'package:app/page/main/page.dart';
import 'package:app/util/background.dart';
import 'package:app/util/colors.dart';
import 'package:app/util/titlebar.dart';
import 'package:app/util/transition.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:win32_registry/win32_registry.dart';

final supabase = Supabase.instance.client;
const borderWidth = 10.0;
const borderRadius = 10.0;

Future<void> registerSchemeWindows(String scheme) async {
  String appPath = Platform.resolvedExecutable;

  String protocolRegKey = 'Software\\Classes\\$scheme';
  RegistryValue protocolRegValue = const RegistryValue(
    'URL Protocol',
    RegistryValueType.string,
    '',
  );
  String protocolCmdRegKey = 'shell\\open\\command';
  RegistryValue protocolCmdRegValue = RegistryValue(
    '',
    RegistryValueType.string,
    '"$appPath" "%1"',
  );

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  regKey.createValue(protocolRegValue);
  regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment("SUPABASE_URL"),
    anonKey: const String.fromEnvironment("SUPABASE_ANON_KEY"),
  );

  supabase.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    final Session? session = data.session;
    if (event == AuthChangeEvent.signedIn) {
      // handle signIn event
    }
    if (session != null) {
      stdout.writeln(session.user.identities!.elementAt(0).id);
    }
  });

  runApp(const Sonar());

  doWhenWindowReady(() {
    const initialSize = Size(1280, 720);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class Sonar extends StatelessWidget {
  const Sonar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // splashFactory: NoSplash.splashFactory,
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(BrandColors.whiteA),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                )),
                padding: MaterialStateProperty.all(const EdgeInsets.all(25)),
                side: MaterialStateProperty.all(
                    const BorderSide(color: BrandColors.whiteA)),
                backgroundColor: MaterialStateProperty.all(BrandColors.whiteAA),
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  return states.contains(MaterialState.disabled)
                      ? BrandColors.whiteA
                      : BrandColors.white;
                })),
          ),
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.grey, brightness: Brightness.dark),
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            for (var element in TargetPlatform.values)
              element: const CustomTransitionBuilder()
          })),
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: child == null
              ? [const Background(), const TitleBar()]
              : [
                  const Background(),
                  Column(
                    children: [const TitleBar(), Expanded(child: child)],
                  )
                ],
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const InitialPage(),
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainPage()
      },
      // home: Background(),
    );
  }
}
