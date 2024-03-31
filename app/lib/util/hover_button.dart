import 'package:flutter/material.dart';

class HoverButton extends StatefulWidget {
  const HoverButton(
      {required this.onPressed, this.style, required this.child, super.key});

  final void Function() onPressed;
  final Widget Function(bool) child;
  final ButtonStyle? style;

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      onHover: (hovering) => setState(() => isHovering = hovering),
      style: widget.style,
      child: widget.child(isHovering),
    );
  }
}
