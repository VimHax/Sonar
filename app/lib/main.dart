import 'dart:io';

import 'package:app/models/intros.dart';
import 'package:app/models/sounds.dart';
import 'package:app/page/initial/page.dart';
import 'package:app/page/login/page.dart';
import 'package:app/models/members.dart';
import 'package:app/page/main/page.dart';
import 'package:app/util/background.dart';
import 'package:app/util/colors.dart';
import 'package:app/util/titlebar.dart';
import 'package:app/util/transition.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:win32_registry/win32_registry.dart';
import 'package:window_manager/window_manager.dart';

final supabase = Supabase.instance.client;
const supabaseURL = String.fromEnvironment("SUPABASE_URL");
const supabaseAnonKey = String.fromEnvironment("SUPABASE_ANON_KEY");
const supabaseFunctionsURL = '$supabaseURL/functions/v1';
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
  await windowManager.ensureInitialized();

  await Supabase.initialize(
    url: supabaseURL,
    anonKey: supabaseAnonKey,
  );

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => MembersModel()),
    ChangeNotifierProvider(create: (context) => SoundsModel()),
    ChangeNotifierProvider(create: (context) => IntrosModel())
  ], child: const Sonar()));

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
                backgroundColor: MaterialStateProperty.all(BrandColors.whiteAA),
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  return states.contains(MaterialState.disabled)
                      ? BrandColors.whiteA
                      : BrandColors.white;
                })),
          ),
          textTheme: GoogleFonts.montserratTextTheme(ThemeData(
                  colorScheme: ColorScheme.fromSwatch(
                      primarySwatch: Colors.grey, brightness: Brightness.dark))
              .textTheme),
          inputDecorationTheme: const InputDecorationTheme(
              contentPadding: EdgeInsets.only(left: 15),
              filled: true,
              fillColor: BrandColors.blackA,
              floatingLabelStyle: TextStyle(color: BrandColors.white),
              hoverColor: BrandColors.whiteA,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                borderSide: BorderSide(width: 1, color: BrandColors.white),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              )),
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
