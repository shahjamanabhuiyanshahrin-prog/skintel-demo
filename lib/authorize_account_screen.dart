import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
const Color kRed = Color(0xFFF21313);
const Color kBoxBorder = Color(0xFFEDEDED);
const Color kRed = Color(0xFFF21313);
const Color kBoxBorder = Color(0xFFEDEDED);

const String kDemoValidCode = '12345';
const bool kAcceptAnyCode = false;

Future<bool> verifyCodeAndCreateAccount(String code) async {
  await Future.delayed(const Duration(milliseconds: 900));

  if (kAcceptAnyCode) return true;

  return code == kDemoValidCode;
}


class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          disabledBackgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// TODO:
// নিচের 3টা জিনিস তোমার existing project-এর যে file-এ আছে,
// সেখান থেকে import করতে হবে:
// 1. verifyCodeAndCreateAccount
// 2. AccountCreatedScreen
// 3. kBoxBorder এবং kRed
//
// আপাতত এগুলো কোথায় আছে সেটা আগে দেখি।


class AuthorizeAccountScreen extends StatefulWidget {
  const AuthorizeAccountScreen({super.key});

  @override
  State<AuthorizeAccountScreen> createState() => _AuthorizeAccountScreenState();
}

class _AuthorizeAccountScreenState extends State<AuthorizeAccountScreen> {
  static const int _length = 5;
  static const int _startSeconds = 34;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _timer;
  int _seconds = _startSeconds;
  bool _hasError = false;
  bool _verifying = false;

  String get _code => _controller.text;
  bool get _isComplete => _code.length == _length;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = _startSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      if (_seconds <= 0) {
        t.cancel();
        return;
      }

      setState(() => _seconds--);
    });
  }

  void _resend() {
    _controller.clear();

    setState(() {
      _hasError = false;
      _startTimer();
    });

    _focus.requestFocus();
  }

  Future<void> _verify() async {
    if (!_isComplete || _verifying) return;

    setState(() => _verifying = true);

    final ok = await verifyCodeAndCreateAccount(_code);

    if (!mounted) return;

    if (ok) {
      FocusScope.of(context).unfocus();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AccountCreatedScreen(),
        ),
      );
    } else {
      setState(() {
        _verifying = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showVerify = _isComplete && !_hasError;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                _buildHeader(context),

                const SizedBox(height: 56),

                Text(
                  'Enter your code',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),

                _buildCodeBoxes(),

                const SizedBox(height: 24),

                _buildStatusLine(),

                const Spacer(),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: showVerify
                      ? Padding(
                          key: const ValueKey('verify'),
                          padding: const EdgeInsets.only(bottom: 28),
                          child: PrimaryButton(
                            label: 'Verify',
                            loading: _verifying,
                            onPressed: _verify,
                          ),
                        )
                      : Padding(
                          key: const ValueKey('timer'),
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _buildTimerLabel(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBoxBorder),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: Colors.black,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Text(
          'Authorize Account',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeBoxes() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_hasError) {
          _controller.clear();

          setState(() => _hasError = false);
        }

        _focus.requestFocus();
      },
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                _buildBox(i),
              ],
            ],
          ),

          Positioned(
            left: 0,
            top: 0,
            width: 1,
            height: 1,
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                autofocus: true,
                showCursor: false,
                enableInteractiveSelection: false,
                keyboardType: TextInputType.number,
                autofillHints: const [
                  AutofillHints.oneTimeCode,
                ],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_length),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) {
                  setState(() => _hasError = false);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(int index) {
    final hasDigit = index < _code.length;

    final isActive =
        _focus.hasFocus &&
        !_isComplete &&
        index == _code.length;

    final Color borderColor =
        _hasError
            ? kRed
            : (isActive ? Colors.black : kBoxBorder);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 64,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Text(
        hasDigit ? _code[index] : '',
        style: GoogleFonts.inter(
          fontSize: 28,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildStatusLine() {
    Widget? child;

    if (_hasError) {
      child = Text(
        'Wrong code, please try again',
        style: GoogleFonts.inter(
          fontSize: 16,
          color: kRed,
        ),
      );
    } else if (_isComplete) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'I didn’t receive a code',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: _resend,
            child: Text(
              'Resend',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 22,
      child: Center(
        child: child,
      ),
    );
  }

  Widget _buildTimerLabel() {
    final canResend = _seconds == 0;

    final label = canResend
        ? 'Send code again'
        : 'Send code again 00:${_seconds.toString().padLeft(2, '0')}';

    return SizedBox(
      width: double.infinity,
      child: Center(
        child: GestureDetector(
          onTap: canResend ? _resend : null,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}