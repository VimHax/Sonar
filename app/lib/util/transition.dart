import 'package:flutter/material.dart';

class CustomTransitionBuilder extends PageTransitionsBuilder {
  const CustomTransitionBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    final tween = Tween(begin: 1.0, end: 0.0)
        .chain(CurveTween(curve: Curves.easeOutQuad));
    return FadeTransition(
        opacity: secondaryAnimation.drive(tween), child: child);
  }
}
