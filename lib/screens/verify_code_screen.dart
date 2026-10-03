import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';
import 'new_password_screen.dart';

enum CodePurpose { signup, recovery }

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({
    super.key,
    required this.email,
    required this.purpose,
  });

  final String email;
  final CodePurpose purpose;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  // 6 OTP boxes
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  final List<FocusNode> _keyboardFocusNodes =
      List.generate(6, (_) => FocusNode());

  Timer? _timer;

  int _secondsLeft = 60;

  bool _loading = false;
  bool _resending = false;

  bool get _isSignup => widget.purpose == CodePurpose.signup;

  @override
  void initState() {
    super.initState();
    _runTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final node in _focusNodes) {
      node.dispose();
    }

    for (final node in _keyboardFocusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  // Resend timer
  void _runTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        if (!mounted) {
          t.cancel();
          return;
        }

        if (_secondsLeft <= 1) {
          t.cancel();

          setState(() {
            _secondsLeft = 0;
          });
        } else {
          setState(() {
            _secondsLeft--;
          });
        }
      },
    );
  }

  // Combine all 6 boxes into one OTP code
  String get _enteredCode {
    return _controllers
        .map((controller) => controller.text)
        .join();
  }

  // Move to next box after entering a digit
  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_enteredCode.length == 6) {
      FocusScope.of(context).unfocus();
    }
  }

  // Backspace moves to previous box
  KeyEventResult _handleKeyEvent(
    KeyEvent event,
    int index,
  ) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();

      _controllers[index - 1].selection =
          TextSelection.fromPosition(
        TextPosition(
          offset: _controllers[index - 1].text.length,
        ),
      );

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // Verify OTP
  Future<void> _verify() async {
    FocusScope.of(context).unfocus();

    final code = _enteredCode;

    if (code.length != 6) {
      showAuthMessage(
        context,
        'Please enter the 6-digit code',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // SIGNUP OTP
      if (_isSignup) {
        await AuthService.verifySignupCode(
          email: widget.email,
          code: code,
        );

        if (!mounted) return;

        showAuthMessage(
          context,
          'Email verified. Welcome!',
          error: false,
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }

      // PASSWORD RECOVERY OTP
      else {
        await AuthService.verifyResetCode(
          email: widget.email,
          code: code,
        );

        if (!mounted) return;

        // OTP verified successfully.
        // Now open Create New Password screen.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const NewPasswordScreen(),
          ),
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

  // Resend OTP
  Future<void> _resend() async {
    if (_secondsLeft > 0 || _resending) {
      return;
    }

    setState(() {
      _resending = true;
    });

    try {
      if (_isSignup) {
        await AuthService.resendSignupCode(
          widget.email,
        );
      } else {
        await AuthService.sendResetCode(
          widget.email,
        );
      }

      if (!mounted) return;

      // Clear previous OTP
      for (final controller in _controllers) {
        controller.clear();
      }

      _focusNodes[0].requestFocus();

      showAuthMessage(
        context,
        'New 6-digit code sent',
        error: false,
      );

      setState(() {
        _secondsLeft = 60;
      });

      _runTimer();
    } catch (e) {
      if (!mounted) return;

      showAuthMessage(
        context,
        AuthService.friendlyError(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          _resending = false;
        });
      }
    }
  }

  // Single OTP box
  Widget _otpBox(int index) {
    return SizedBox(
      width: 48,
      height: 54,
      child: KeyboardListener(
        focusNode: _keyboardFocusNodes[index],
        onKeyEvent: (event) {
          _handleKeyEvent(event, index);
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: !_loading,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE5E5E5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1.5,
              ),
            ),
          ),
          onChanged: (value) {
            _onDigitChanged(value, index);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      title: _isSignup
          ? 'Verify your email'
          : 'Enter reset code',
      subtitle:
          'We sent a 6-digit code to ${widget.email}. Enter it below.',
      children: [
        const Text(
          'Verification code',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 10),

        // 6 OTP BOXES
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _otpBox(0),
            _otpBox(1),
            _otpBox(2),
            _otpBox(3),
            _otpBox(4),
            _otpBox(5),
          ],
        ),

        const SizedBox(height: 28),

        AuthButton(
          label: _isSignup ? 'Verify' : 'Verify code',
          loading: _loading,
          onPressed: _verify,
        ),

        const SizedBox(height: 16),

        Center(
          child: _secondsLeft > 0
              ? Text(
                  'Resend code in ${_secondsLeft}s',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                  ),
                )
              : TextButton(
                  onPressed: _resending ? null : _resend,
                  child: Text(
                    _resending
                        ? 'Sending...'
                        : 'Resend code',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}