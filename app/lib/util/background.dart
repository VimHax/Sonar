import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          // color: BrandColors.red,
          image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                  "https://images.pexels.com/photos/355747/pexels-photo-355747.jpeg")),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
    );
  }
}
