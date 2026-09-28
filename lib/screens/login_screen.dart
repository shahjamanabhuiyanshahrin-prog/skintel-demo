import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';
import 'forgot_password_screen.dart';
import 'verify_code_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _email.text.trim();
    final password = _password.text;

    if (!isValidEmail(email)) {
      showAuthMessage(context, 'Enter a valid email');
      return;
    }

    if (password.isEmpty) {
      showAuthMessage(context, 'Enter your password');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await AuthService.signIn(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Login successful
      showAuthMessage(
        context,
        'Login successful!',
        error: false,
      );

      // Temporary screen until Home Screen is created
      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginSuccessScreen(),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      if (e.message
          .toLowerCase()
          .contains('email not confirmed')) {
        try {
          await AuthService.resendSignupCode(email);
        } catch (_) {}

        if (!mounted) return;

        showAuthMessage(
          context,
          'Please verify your email first. We sent you a code.',
          error: false,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyCodeScreen(
              email: email,
              purpose: CodePurpose.signup,
            ),
          ),
        );
      } else {
        showAuthMessage(
          context,
          AuthService.friendlyError(e),
        );
      }
    } catch (e) {
      if (!mounted) return;

      showAuthMessage(
        context,
        AuthService.friendlyError(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      title: 'Log in',
      subtitle: 'Welcome back! Please enter your details.',
      showBack: Navigator.of(context).canPop(),
      children: [
        AuthTextField(
          label: 'Email',
          hint: 'example@gmail.com',
          controller: _email,
          enabled: !_loading,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 16),

        AuthTextField(
          label: 'Password',
          hint: 'Enter your password',
          controller: _password,
          isPassword: true,
          enabled: !_loading,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _login(),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _loading
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ForgotPasswordScreen(
                          initialEmail:
                              _email.text.trim(),
                        ),
                      ),
                    );
                  },
            child: const Text(
              'Forgot password?',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        AuthButton(
          label: 'Log in',
          loading: _loading,
          onPressed: _login,
        ),

        const SizedBox(height: 20),

        AuthFooterLink(
          text: "Don't have an account? ",
          action: 'Sign up',
          onTap: () =>
              Navigator.pushReplacementNamed(
            context,
            '/signup',
          ),
        ),
      ],
    );
  }
}


// --------------------------------------------------
// TEMPORARY LOGIN SUCCESS SCREEN
// --------------------------------------------------

class LoginSuccessScreen extends StatelessWidget {
  const LoginSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 70,
                color: Colors.black,
              ),

              const SizedBox(height: 20),

              const Text(
                'Login Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your Skintel account has been logged in successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
