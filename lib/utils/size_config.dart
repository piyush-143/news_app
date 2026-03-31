import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  // Typical mobile design dimensions (e.g., iPhone X/11/12 Pro)
  static const double _designWidth = 375.0;
  static const double _designHeight = 812.0;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
  }
}

extension SizeExtension on num {
  /// Responsive width relative to design width
  double get w => (this / SizeConfig._designWidth) * SizeConfig.screenWidth;

  /// Responsive height relative to design height
  double get h => (this / SizeConfig._designHeight) * SizeConfig.screenHeight;

  /// Responsive font size relative to screen width (adjust multiplier if needed)
  double get sp => this * (SizeConfig.screenWidth / SizeConfig._designWidth);
}
