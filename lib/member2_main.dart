import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color kBackground = Color(0xFFF8F8F6);
const Color kRed = Color(0xFFD94A4A);
const Color kBoxBorder = Color(0xFFD9D9D9);

class AuthorizeAccountScreen extends StatefulWidget {
  final String email;

  const AuthorizeAccountScreen({
    super.key,
    required this.email,
  });

  @override
  State<AuthorizeAccountScreen> createState() =>
      _AuthorizeAccountScreenState();
}

class _AuthorizeAccountScreenState
    extends State<AuthorizeAccountScreen> {
  // OTP length = 6
  static const int _length = 6;

  static const int _startSeconds = 34;

  final TextEditingController _controller =
      TextEditingController();

  final FocusNode _focus = FocusNode();

  String _code = '';

  bool _isLoading = false;
  bool _hasError = false;

  int _seconds = _startSeconds;

  bool get _isComplete => _code.length == _length;

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onTextChanged);

    _focus.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _startTimer();
  }

  void _onTextChanged() {
    final value = _controller.text;

    if (value == _code) return;

    setState(() {
      _code = value;

      if (_hasError) {
        _hasError = false;
      }
    });
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(
        const Duration(seconds: 1),
      );

      if (!mounted) return false;

      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });

        return true;
      }

      return false;
    });
  }

  Future<void> _resendCode() async {
    if (_seconds > 0) return;

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      await Supabase.instance.client.auth
          .resend(
        type: OtpType.signup,
        email: widget.email,
      );

      if (!mounted) return;

      _controller.clear();

      setState(() {
        _code = '';
        _seconds = _startSeconds;
        _isLoading = false;
      });

      _focus.requestFocus();

      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A new 6-digit code has been sent to your email.',
          ),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not resend the code. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _verifyCode() async {
    FocusScope.of(context).unfocus();

    if (_code.length != _length) {
      setState(() {
        _hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the 6-digit verification code.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // REAL SUPABASE OTP VERIFICATION
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        token: _code,
        email: widget.email,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account verified successfully!',
          ),
        ),
      );

      // Go to Home after successful verification
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid or expired verification code.',
          ),
        ),
      );
    }
  }

  Widget _buildCodeBoxes() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_hasError) {
          _controller.clear();

          setState(() {
            _hasError = false;
          });
        }

        _focus.requestFocus();
      },
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _length; i++) ...[
                if (i > 0)
                  const SizedBox(width: 10),
                _buildBox(i),
              ],
            ],
          ),

          // Hidden TextField
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    _length,
                  ),
                ],
                onSubmitted: (_) {
                  if (_isComplete) {
                    _verifyCode();
                  }
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
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

    final Color borderColor = _hasError
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
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  String _formatTimer() {
    final minutes =
        (_seconds ~/ 60).toString().padLeft(2, '0');

    final seconds =
        (_seconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                Text(
                  'Authorize Account',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'Enter the 6-digit verification code sent to',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 40),

                _buildCodeBoxes(),

                const SizedBox(height: 14),

                if (_hasError)
                  Text(
                    'Invalid verification code',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: kRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                const SizedBox(height: 30),

                Text(
                  _seconds > 0
                      ? 'Resend code in ${_formatTimer()}'
                      : 'Didn’t receive the code?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed:
                      _seconds == 0 && !_isLoading
                          ? _resendCode
                          : null,
                  child: Text(
                    'Resend Code',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _seconds == 0
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Verify Account',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Back',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}