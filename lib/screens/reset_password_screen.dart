import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';

/// Code verify howar por notun password set korar screen.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    FocusScope.of(context).unfocus();

    final password = _password.text;
    if (password.length < 8) {
      showAuthMessage(context, 'Password must be at least 8 characters');
      return;
    }
    if (password != _confirm.text) {
      showAuthMessage(context, 'Passwords do not match');
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthService.updatePassword(password);
      await AuthService.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/password-changed',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      showAuthMessage(context, AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      title: 'Reset password',
      subtitle: 'Create a new password for your account.',
      showBack: false,
      children: [
        AuthTextField(
          label: 'New password',
          hint: 'must be 8 characters',
          controller: _password,
          isPassword: true,
          enabled: !_loading,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Confirm password',
          hint: 'repeat password',
          controller: _confirm,
          isPassword: true,
          enabled: !_loading,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _update(),
        ),
        const SizedBox(height: 28),
        AuthButton(
          label: 'Update password',
          loading: _loading,
          onPressed: _update,
        ),
      ],
    );
  }
}