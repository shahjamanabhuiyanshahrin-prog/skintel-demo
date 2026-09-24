import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Splash screen background color
  static const Color splashColor = Color(0xFF9BC5B9);

  @override
  void initState() {
    super.initState();

    // Make status bar and navigation bar match the splash background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: splashColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: splashColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Show splash screen for 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/login-signup',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: splashColor,

      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skintel logo
              Image.asset(
                'assets/images/logo.png',
                width: 180,
                height: 100,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 20),

              // Tagline
              const Text(
                'Your Skin Deserve Care',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF183D36),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}