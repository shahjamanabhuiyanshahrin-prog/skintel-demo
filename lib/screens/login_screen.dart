import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            children: [
              const SizedBox(height: 24),
              const Text(
                'Log in',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 28),
              const Text(
                'Email',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              _field(hint: 'Enter email'),
              const SizedBox(height: 16),
              const Text(
                'Password',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              _field(
                hint: 'Enter password',
                obscure: obscure,
                suffix: IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _blackButton('Log in', () {
                // Login logic goes here later
              }),
              const SizedBox(height: 24),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Or Login with',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialBox(Icons.facebook, Colors.blue),
                  const SizedBox(width: 14),
                  _socialBox(Icons.g_mobiledata, Colors.red),
                  const SizedBox(width: 14),
                  _socialBox(Icons.apple, Colors.black),
                ],
              ),
              const SizedBox(height: 28),
              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    children: [
                      TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({required String hint, bool obscure = false, Widget? suffix}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _blackButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _socialBox(IconData icon, Color color) {
    return Container(
      width: 60,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }
}