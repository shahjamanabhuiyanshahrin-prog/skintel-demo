import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showAuthMessage(BuildContext context, String text, {bool error = true}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor:
          error ? const Color(0xFFB3261E) : const Color(0xFF222222),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

bool isValidEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
}

/// Shob auth screen er common layout: title, subtitle, tarpor children.
class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showBack
          ? AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            )
          : null,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, showBack ? 8 : 48, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.maxLength,
    this.inputFormatters,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _hidden = true;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: widget.isPassword && _hidden,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          autocorrect: false,
          enableSuggestions: !widget.isPassword,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            counterText: '',
            hintText: widget.hint,
            hintStyle:
                const TextStyle(fontSize: 14, color: Color(0xFF9A9A9A)),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: _border(const Color(0xFFE5E5E5)),
            disabledBorder: _border(const Color(0xFFE5E5E5)),
            focusedBorder: _border(Colors.black),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _hidden = !_hidden),
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: const Color(0xFF8E8E93),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.black,
          disabledForegroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// "Already have an account? Log in" type footer
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}