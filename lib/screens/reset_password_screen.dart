import 'package:flutter/material.dart';
import 'password_changed_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool obscureNew = true;
  bool obscureConfirm = true;
  String? errorText;

  void _handleReset() {
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => errorText = 'Please fill in both fields');
      return;
    }

    if (newPass.length < 8) {
      setState(() => errorText = 'Password must be at least 8 characters');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => errorText = 'Passwords do not match');
      return;
    }

    setState(() => errorText = null);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PasswordChangedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please type something you'll remember",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            const Text(
              'New password',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: newPasswordController,
              obscureText: obscureNew,
              decoration: InputDecoration(
                hintText: 'must be 8 characters',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => obscureNew = !obscureNew),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Confirm new password',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: confirmPasswordController,
              obscureText: obscureConfirm,
              decoration: InputDecoration(
                hintText: 'repeat password',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => obscureConfirm = !obscureConfirm),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                errorText!,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _handleReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reset password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                  children: [
                    TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Log in',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}