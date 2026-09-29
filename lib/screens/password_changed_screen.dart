import 'package:flutter/material.dart';

import '../widgets/auth_widgets.dart';

class PasswordChangedScreen extends StatelessWidget {
  const PasswordChangedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Password changed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your password has been changed successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                  ),
                  const SizedBox(height: 32),
                  AuthButton(
                    label: 'Back to Log in',
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}