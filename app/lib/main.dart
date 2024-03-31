import 'package:app/page/initial/page.dart';
import 'package:app/util/background.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Sonar());
}

class Sonar extends StatelessWidget {
  const Sonar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonar',
      theme: ThemeData(splashFactory: NoSplash.splashFactory),
      builder: (context, child) => Material(
        child: Stack(
          children: child == null
              ? [const Background()]
              : [const Background(), child],
        ),
      ),
      initialRoute: '/',
      routes: {'/': (context) => const InitialPage()},
    );
  }
}
