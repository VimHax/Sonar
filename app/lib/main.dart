import 'package:app/page/initial/page.dart';
import 'package:app/util/background.dart';
import 'package:app/util/titlebar.dart';
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
        splashFactory: NoSplash.splashFactory,
      ),
      builder: (context, child) => Material(
        child: Stack(
          children: child == null
              ? [const Background(), const TitleBar()]
              : [const Background(), child, const TitleBar()],
        ),
      ),
      initialRoute: '/',
      routes: {'/': (context) => const InitialPage()},
    );
  }
}
