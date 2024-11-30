import 'package:flutter/cupertino.dart';

class IosAppTheme {
  static CupertinoThemeData get lightTheme {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: CupertinoColors.activeBlue,
      scaffoldBackgroundColor: CupertinoColors.systemBackground,
      barBackgroundColor: CupertinoColors.secondarySystemBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        navTitleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
      ),
      primaryContrastingColor: CupertinoColors.white,
    );
  }

  static CupertinoThemeData get darkTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: CupertinoColors.activeBlue,
      scaffoldBackgroundColor: CupertinoColors.black,
      barBackgroundColor: CupertinoColors.darkBackgroundGray,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        navTitleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
      ),
      primaryContrastingColor: CupertinoColors.white,
    );
  }
}
