import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_options_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/reset_password_screen.dart';
import 'welcome_screen.dart';
import 'member2_main.dart' as member2;
import 'member3_main.dart' as member3;
import 'screens/login_signup_screen.dart';
import 'screens/onboarding_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://roiycijynzjavcpmpgzk.supabase.co',
    anonKey: 'sb_publishable_ul4HIi-HVkEOk1CGs7Wtwg_92CvAcw8',
  );

  runApp(const SkintelApp());
}

class SkintelApp extends StatelessWidget {
  const SkintelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skintel',

      // App starts from Splash Screen
      initialRoute: '/',

      routes: {
        // ==========================================
        // SPLASH SCREEN
        // ==========================================
        '/': (context) => const SplashScreen(),

        // ==========================================
        // LOGIN / SIGNUP

        // Splash-এর 3 seconds পরে এখানে আসবে
        // ==========================================
        '/login-signup': (context) =>
    const LoginSignupScreen(),
    '/login': (context) =>
    const LoginScreen(),

        // ==========================================
        // SIGNUP OPTIONS
        // ==========================================
        '/signup-options': (context) =>
            const SignupOptionsScreen(),

        // ==========================================
        // SIGNUP
        // ==========================================
        '/signup': (context) =>
            const SignupScreen(),

        // ==========================================
        // OTP / AUTHORIZE
        // ==========================================
        '/authorize': (context) {
          final email =
              ModalRoute.of(context)!.settings.arguments as String;

          return member2.AuthorizeAccountScreen(
            email: email,
          );
        },

        // ==========================================
        // PASSWORD RESET
        // ==========================================
        '/reset-password': (context) =>
            const ResetPasswordScreen(),

        // ==========================================
        // WELCOME SCREEN
        // OTP successfully verified হলে এখানে আসবে
        // ==========================================
        '/welcome': (context) =>
            const WelcomeScreen(),
            '/onboarding': (context) =>
    const OnboardingScreen(),

        // ==========================================
        // MEMBER 3
        // ==========================================
        '/member3-login': (context) =>
            member3.PhoneFrame(
              child: const SignupOptionsScreen(),
            ),

        // ==========================================
        // TEMPORARY HOME
        // ==========================================
        '/home': (context) =>
            const HomeScreen(),
      },
    );
  }
}


// =====================================================
// TEMPORARY HOME SCREEN
// =====================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'Skintel',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),

      body: const Center(
        child: Text(
          'Welcome to Skintel! 💚',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}