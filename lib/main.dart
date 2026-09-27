import 'package:flutter/material.dart';

// Your screens
import 'screens/splash_screen.dart';
import 'screens/login_signup_screen.dart';
import 'screens/signup_options_screen.dart';
import 'screens/signup_screen.dart';

// Member 2
import 'member2_main.dart' as member2;

// Member 3
import 'member3_main.dart' as member3;
import 'screens/login_screen.dart';

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
        // -------------------------------------------------
        // YOUR PART
        // -------------------------------------------------

        '/': (context) => const SplashScreen(),

        '/login-signup': (context) =>
            const LoginSignupScreen(),

        '/signup-options': (context) =>
            const SignupOptionsScreen(),

        '/signup': (context) =>
            const SignupScreen(),

        // -------------------------------------------------
        // MEMBER 2
        // -------------------------------------------------

        '/authorize': (context) =>
            const member2.AuthorizeAccountScreen(),

        // -------------------------------------------------
        // MEMBER 3
        // -------------------------------------------------

        '/member3-login': (context) =>
            member3.PhoneFrame(
              child: const LoginScreen(),
            ),
      },
    );
  }
}