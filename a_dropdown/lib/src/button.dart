import 'package:flutter/material.dart';

class AButton extends StatelessWidget {
  const AButton({
    super.key,
    // this.height = 48,
    // this.width,
    this.onTap,
    this.textStyle = const TextStyle(),
    this.decoration = const BoxDecoration(),
    this.child,
  });

  // final double height;
  // final double? width;
  final VoidCallback? onTap;
  final Widget? child;

  final TextStyle textStyle;
  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      decoration: decoration,      
      child: Material(
        textStyle: textStyle,
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: child,
        ),
      ),
    );
  }
}
