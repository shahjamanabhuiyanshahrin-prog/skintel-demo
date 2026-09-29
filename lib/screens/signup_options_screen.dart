import 'package:flutter/material.dart';

import '../widgets/auth_widgets.dart';

class SignupOptionsScreen extends StatelessWidget {
  const SignupOptionsScreen({super.key});

  // Pill shape button (Apple / Email / Google)
  Widget _socialButton({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
    bool dark = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? Colors.black : Colors.white,
          foregroundColor: dark ? Colors.white : Colors.black,
          surfaceTintColor: Colors.transparent,
          elevation: dark ? 0 : 3,
          shadowColor: Colors.black38,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Upore photo + "Skintel" writing
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/hero_face.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: const Color(0xFFD9B8A6)),
                  ),
                  const Align(
                    alignment: Alignment(0, 0.75),
                    child: Text(
                      'Skintel',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontFamilyFallback: ['Georgia'],
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2A2018),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Neeche buttons
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your Skin Deserves Care',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  _socialButton(
                    label: 'Sign Up with Apple',
                    dark: true,
                    icon: const Icon(Icons.apple, size: 20),
                    onTap: () =>
                        showAuthMessage(context, 'Apple sign in coming soon'),
                  ),
                  const SizedBox(height: 12),

                  _socialButton(
                    label: 'Sign Up with Email',
                    icon: const Icon(Icons.mail, size: 16),
                    onTap: () => Navigator.pushNamed(context, '/signup'),
                  ),
                  const SizedBox(height: 12),

                  _socialButton(
                    label: 'Sign Up with Google',
                    icon: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                    onTap: () =>
                        showAuthMessage(context, 'Google sign in coming soon'),
                  ),
                  const SizedBox(height: 16),

                  AuthFooterLink(
                    text: 'Already have an account? ',
                    action: 'Log in',
                    onTap: () => Navigator.pushNamed(context, '/login'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}