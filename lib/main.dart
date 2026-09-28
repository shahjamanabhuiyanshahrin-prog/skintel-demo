import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Your screens
import 'screens/splash_screen.dart';
import 'screens/login_signup_screen.dart';
import 'screens/signup_options_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/new_password_screen.dart';
import 'screens/password_changed_screen.dart';


// Member 2
import 'member2_main.dart' as member2;

// Member 3
import 'member3_main.dart' as member3;

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
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login-signup': (context) => const LoginSignupScreen(),
        '/signup-options': (context) => const SignupOptionsScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/new-password': (context) => const NewPasswordScreen(),
        '/reset-password': (context) => const NewPasswordScreen(),
        '/password-changed': (context) => const PasswordChangedScreen(),
        

        // Teammate der screens
        '/authorize': (context) {
  final email =
      ModalRoute.of(context)!.settings.arguments as String;

  return member2.AuthorizeAccountScreen(
    email: email,
  );
},
        '/member3-login': (context) => member3.PhoneFrame(
              child: const LoginScreen(),
            ),
      },
    );
  }
}