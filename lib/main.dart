import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_signup_screen.dart';
import 'screens/signup_options_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(const SkintelApp());
}

class SkintelApp extends StatelessWidget {
  const SkintelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skintel',

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),

        '/login-signup': (context) =>
            const LoginSignupScreen(),

        '/signup-options': (context) =>
            const SignupOptionsScreen(),

        '/signup': (context) =>
            SignupScreen(),
      },
    );
  }
}