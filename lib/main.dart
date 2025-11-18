import 'dart:io';

import 'package:chess_timer/screens/home_screen_ios.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(const ChessClockApp());
}

class ChessClockApp extends StatelessWidget {
  const ChessClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // For web, you usually default to MaterialApp
      return MaterialApp(
        title: 'Advanced Chess Clock',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(), // Or a Web-specific screen
      );
    }
    if (Platform.isIOS) {
      return const CupertinoApp(
        title: 'Advanced Chess Clock',
        theme: CupertinoThemeData(
          brightness: Brightness.light,
        ),
        debugShowCheckedModeBanner: false,
        home: HomeScreenIos(),
      );
    } else {
      return MaterialApp(
        title: 'Advanced Chess Clock',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      );
    }
  }
}
