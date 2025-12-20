import 'dart:io';

import 'package:flutter/material.dart';
import 'package:news_app/view_models/db_view_model.dart';
import 'package:news_app/view_models/index_view_model.dart';
import 'package:news_app/view_models/news_view_model.dart';
import 'package:news_app/view_models/theme_view_model.dart';
import 'package:news_app/views/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  // Required for async operations (like SharedPreferences) to run before the UI starts
  WidgetsFlutterBinding.ensureInitialized();

  // Fix for "HandshakeException" on some older devices or emulators
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    // Dependency Injection:
    // We wrap the entire app in MultiProvider so that these ViewModels (State)
    // are accessible from ANY widget in the tree using context.read or Consumer.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => NewsViewModel()),
        ChangeNotifierProvider(create: (_) => DbViewModel()),
        ChangeNotifierProvider(create: (_) => IndexViewModel()),
      ],
      child: const NewsApp(),
    ),
  );
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap MaterialApp in a Consumer to listen for theme changes.
    // When ThemeViewModel calls notifyListeners(), this builder re-runs,
    // switching the app between Light and Dark mode instantly.
    return Consumer<ThemeViewModel>(
      builder: (context, themeVM, child) {
        return MaterialApp(
          title: 'News App',
          debugShowCheckedModeBanner: false,

          // Current active theme mode (Light, Dark, or System)
          themeMode: themeVM.themeMode,

          // --- LIGHT THEME CONFIGURATION ---
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Colors.indigo,
            useMaterial3: true,

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 10,
              // 'surfaceTintColor: transparent' prevents Material 3 from
              // adding a slight purple/primary tint to the AppBar on scroll.
              surfaceTintColor: Colors.transparent,
              iconTheme: IconThemeData(color: Colors.black, size: 27),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),

            // Customizing text selection handles (the "water drops")
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.indigo,
              selectionColor: Colors.indigo.shade100,
              selectionHandleColor: Colors.indigo,
            ),

            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.grey.shade300,
              selectedItemColor: Colors.indigo,
              unselectedItemColor: Colors.grey.shade600,
              type: BottomNavigationBarType.fixed,
              elevation: 3,
            ),

            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Colors.blueAccent,
              circularTrackColor: Colors.grey,
            ),
          ),

          // --- DARK THEME CONFIGURATION ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            // Using a very dark grey (#111111) instead of pure black (#000000)
            // is often softer on the eyes and reduces OLED smearing on scrolling.
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

            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.white,
              selectionColor: Colors.white30,
              selectionHandleColor: Colors.white,
            ),

            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.grey.shade900,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey.shade500,
              type: BottomNavigationBarType.fixed,
              elevation: 3,
            ),

            progressIndicatorTheme: const ProgressIndicatorThemeData(
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

/// Helper to bypass SSL certificate errors during development.
/// SECURITY WARNING: Do not include this class in the Production/Release build.
/// It allows Man-In-The-Middle (MITM) attacks by trusting all certificates.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
