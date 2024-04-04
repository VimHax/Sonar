import 'dart:ui';

import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';

class Blur extends StatelessWidget {
  const Blur({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: BrandColors.whiteA),
          borderRadius: const BorderRadius.all(Radius.circular(borderRadius))),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32), child: child)),
    );
  }
}
