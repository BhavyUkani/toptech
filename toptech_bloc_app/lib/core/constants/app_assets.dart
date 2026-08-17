import 'package:flutter/material.dart';

class AppAssets {
  AppAssets._();

  static const String logo = 'assets/logo.png';
  static const String logoDark = 'assets/logo-dark.png';
  static const String logoLight = 'assets/logo-light.png';
  static const String logoSquare = 'assets/logo-square.jpg';

  static String getThemeLogo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? logoDark : logoLight;
  }
}
