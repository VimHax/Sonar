import 'package:app/util/colors.dart';
import 'package:flutter/material.dart';

void showSuccessSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      text,
      style: const TextStyle(color: BrandColors.black),
    ),
    backgroundColor: BrandColors.lime,
  ));
}

void showErrorSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      text,
      style: const TextStyle(color: BrandColors.white),
    ),
    backgroundColor: BrandColors.red,
  ));
}
