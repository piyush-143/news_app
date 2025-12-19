import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../view_models/db_view_model.dart';
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
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // 1. Check existing session
    final dbViewModel = context.read<DbViewModel>();
    final sessionCheck = dbViewModel.checkSession();
    final minSplashTime = Future.delayed(const Duration(seconds: 3));

    // 2. Wait for splash animation (optional branding time)
    // Changed back to 3 seconds for standard splash duration (300s is too long)
    await Future.wait([minSplashTime, sessionCheck]);

    if (!mounted) return;

    // 3. Navigate based on auth state
    if (dbViewModel.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainWrapper()),
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
      // Gradient background for a more modern look
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo,
              Color(0xFF3F51B5),
            ], // Indigo to slightly lighter shade
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              Container(
                width: 140, // Slightly larger for better visibility
                height: 140,
                padding: const EdgeInsets.all(
                  7,
                ), // Padding for the logo inside the white circle
                decoration: BoxDecoration(
                  color: Colors.white, // White background to pop against indigo
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
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.newspaper_rounded,
                      size: 80,
                      color: Colors.indigo,
                    );
                  }, // Contain ensures the logo isn't cropped awkwardly
                ),
              ),
              const SizedBox(height: 30),

              // App Name
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

              // Tagline
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

              // Loader
              const SpinKitCubeGrid(
                // Switched to CubeGrid for that 'news block' feel
                color: Colors.white,
                size: 45.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
