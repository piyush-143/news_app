import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../view_models/firebase_auth_view_model.dart';
import 'auth/login_screen.dart';
import 'home/main_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the initialization process as soon as the widget mounts
    _checkAuthAndNavigate();
  }

  /// Handles the startup logic: checks for a logged-in user while showing the splash animation.
  Future<void> _checkAuthAndNavigate() async {
    // 1. Show Splash for at least 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // 2. Check if widget is still valid
    if (!mounted) return;

    // 3. Check Auth State
    // We check *after* the delay to ensure we have the latest state if init took a moment.
    final authViewModel = context.read<FirebaseAuthViewModel>();
    final isLoggedIn = authViewModel.isLoggedIn;

    // 4. Navigate
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainController()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background gives a more polished, modern look than a flat color
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo, // Start color
              Color(0xFF3F51B5), // Slightly lighter indigo
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Logo Section ---
              Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white, // White background makes the logo pop
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(70),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  "assets/logo.png",
                  fit: BoxFit.contain,
                  // Fallback icon in case the asset is missing
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.newspaper_rounded,
                      size: 80,
                      color: Colors.indigo,
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // --- App Name ---
              const Text(
                "News App",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4.0,
                      color: Color.fromARGB(60, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // --- Tagline ---
              const Text(
                "Discover the Future",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 60),

              // --- Loading Indicator ---
              // 'SpinKitCubeGrid' fits the blocky nature of news layouts well
              const SpinKitCubeGrid(
                color: Colors.white,
                size: 45.0,
                duration: Durations.extralong2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
