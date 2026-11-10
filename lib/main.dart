import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_options_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/login_signup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'welcome_screen.dart';
import 'screens/home_screen.dart';

import 'member2_main.dart' as member2;
import 'member3_main.dart' as member3;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

 
  // Supabase initialize করবে শুধু একবার
  await Supabase.initialize(
    url: 'https://roiycijynzjavcpmpgzk.supabase.co',
    publishableKey: 'sb_publishable_ul4HIi-HVkEOk1CGs7Wtwg_92CvAcw8',
  );

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skintel',

      initialRoute: '/',

      routes: {
        // Splash
        '/': (context) => const SplashScreen(),

        // Login / Signup
        '/login-signup': (context) => const LoginSignupScreen(),

        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),

        // Signup options
        '/signup-options': (context) => const SignupOptionsScreen(),

        // Signup
        '/signup': (context) => const SignupScreen(),

        // Member 2 - OTP verification
        '/authorize': (context) {
          final email =
              ModalRoute.of(context)!.settings.arguments as String;

          return member2.AuthorizeAccountScreen(
            email: email,
          );
        },

        // Password reset
        '/reset-password': (context) => const ResetPasswordScreen(),

        // Welcome
        '/welcome': (context) => const WelcomeScreen(),

        // Onboarding
        '/onboarding': (context) => const OnboardingScreen(),

        // Member 3
        '/member3-login': (context) => member3.PhoneFrame(
              child: const SignupOptionsScreen(),
            ),

        // Home
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}