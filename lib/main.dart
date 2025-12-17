import 'dart:io';

import 'package:flutter/material.dart';
import 'package:news_app/view_models/db_view_model.dart';
// Note: Ensure these files exist in your project structure
import 'package:news_app/view_models/news_view_model.dart';
import 'package:news_app/view_models/theme_view_model.dart';
import 'package:news_app/views/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  // Overrides for development (e.g., handling self-signed certificates)
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => NewsViewModel()),
        ChangeNotifierProvider(create: (_) => DbViewModel()),
      ],
      child: const NewsApp(),
    ),
  );
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeVM, child) {
        return MaterialApp(
          title: 'News App',
          debugShowCheckedModeBanner: false,
          themeMode: themeVM.themeMode,

          // --- LIGHT THEME ---
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Colors.indigo,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 10,
              surfaceTintColor: Colors.transparent,
              iconTheme: IconThemeData(color: Colors.black, size: 27),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.indigo,
              selectionColor: Colors.indigo.shade100,
              selectionHandleColor:
                  Colors.indigo, // Changes the "water drop" color
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.grey.shade300,
              selectedItemColor: Colors.indigo,
              unselectedItemColor: Colors.grey.shade600,
              type: BottomNavigationBarType.fixed,
              elevation: 3,
            ),
            progressIndicatorTheme: ProgressIndicatorThemeData(
              color: Colors.blueAccent,
              circularTrackColor: Colors.grey,
            ),
          ),

          // --- DARK THEME ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF111111),
            primaryColor: Colors.white,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF111111),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.white,
              selectionColor: Colors.white30,
              selectionHandleColor:
                  Colors.white, // Changes the "water drop" color
            ),

            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.grey.shade900,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey.shade500,
              type: BottomNavigationBarType.fixed,
              elevation: 3,
            ),
            progressIndicatorTheme: ProgressIndicatorThemeData(
              color: Colors.blueAccent,
              circularTrackColor: Colors.white60,
            ),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}

// Development-only HTTP overrides to bypass bad certificate errors.
// WARNING: Do not use this in production as it bypasses security checks.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
