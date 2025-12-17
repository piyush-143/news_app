import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoader extends StatelessWidget {
  final Color? color;
  final double size;

  const CustomLoader({super.key, this.color, this.size = 35.0});

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).primaryColor;

    // Using SpinKitThreeBounce for a modern look that fits buttons and lists
    return SpinKitThreeBounce(color: themeColor, size: size);
  }
}
