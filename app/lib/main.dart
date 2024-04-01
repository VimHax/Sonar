import 'package:app/page/initial/page.dart';
import 'package:app/page/login/page.dart';
import 'package:app/util/background.dart';
import 'package:app/util/colors.dart';
import 'package:app/util/titlebar.dart';
import 'package:app/util/transition.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() {
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
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                )),
                padding: MaterialStateProperty.all(const EdgeInsets.all(25)),
                side: MaterialStateProperty.all(
                    BorderSide(color: BrandColors.white.withAlpha(50))),
                backgroundColor:
                    MaterialStateProperty.all(BrandColors.black.withAlpha(50))),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey),
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            for (var element in TargetPlatform.values)
              element: const CustomTransitionBuilder()
          })),
      builder: (context, child) => Material(
        child: Stack(
          children: child == null
              ? [const Background(), const TitleBar()]
              : [const Background(), child, const TitleBar()],
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const InitialPage(),
        '/login': (context) => const LoginPage()
      },
      // home: Background(),
    );
  }
}
