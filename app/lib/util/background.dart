import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: BrandColors.black,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
    );
  }
}
