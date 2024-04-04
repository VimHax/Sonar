import 'package:app/main.dart';
import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';

// https://images.pexels.com/photos/2156881/pexels-photo-2156881.jpeg

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   decoration: const BoxDecoration(
    //       color: Colors.black,
    //       borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
    // );
    return Container(
      decoration: const BoxDecoration(
          // color: BrandColors.red,
          image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                  "https://images.pexels.com/photos/2156881/pexels-photo-2156881.jpeg")),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
    );
  }
}
