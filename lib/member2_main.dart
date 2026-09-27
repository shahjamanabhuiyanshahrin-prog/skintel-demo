import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const String kDemoValidCode = '12345';
const bool kAcceptAnyCode = false;

const Color kRed = Color(0xFFF21313);
const Color kBoxBorder = Color(0xFFEDEDED);

const double kDesignWidth = 393;
const double kDesignHeight = 852;

Future<bool> verifyCodeAndCreateAccount(String code) async {
  await Future.delayed(const Duration(milliseconds: 900));

  if (kAcceptAnyCode) return true;

  return code == kDemoValidCode;
}

// ---------------------------------------------------------------------------
// Skintel App
// ---------------------------------------------------------------------------

class SkintelApp extends StatelessWidget {
  const SkintelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skintel',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final screenW = mq.size.width;
        final screenH = mq.size.height;

        final scale = math.min(
          screenW / kDesignWidth,
          screenH / kDesignHeight,
        );

        final frameH = kDesignHeight * scale;
        final frameTop = (screenH - frameH) / 2;

        final keyboardOverlap =
            math.max(
              0.0,
              frameTop + frameH - (screenH - mq.viewInsets.bottom),
            ) /
            scale;

        return ColoredBox(
          color: Colors.white,
          child: Center(
            child: Container(
              width: kDesignWidth * scale,
              height: frameH,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: kDesignWidth,
                  height: kDesignHeight,
                  child: MediaQuery(
                    data: mq.copyWith(
                      size: const Size(
                        kDesignWidth,
                        kDesignHeight,
                      ),
                      padding: const EdgeInsets.only(
                        top: 59,
                        bottom: 34,
                      ),
                      viewPadding: const EdgeInsets.only(
                        top: 59,
                        bottom: 34,
                      ),
                      viewInsets: EdgeInsets.only(
                        bottom: keyboardOverlap,
                      ),
                    ),
                    child: child!,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      home: const AuthorizeAccountScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared Widgets
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// 1. Authorize Account
// ---------------------------------------------------------------------------

class AuthorizeAccountScreen extends StatefulWidget {
  const AuthorizeAccountScreen({super.key});

  @override
  State<AuthorizeAccountScreen> createState() =>
      _AuthorizeAccountScreenState();
}

class _AuthorizeAccountScreenState
    extends State<AuthorizeAccountScreen> {
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

    _focus.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
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

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        if (!mounted) return;

        if (_seconds <= 0) {
          t.cancel();
          return;
        }

        setState(() {
          _seconds--;
        });
      },
    );
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

    setState(() {
      _verifying = true;
    });

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
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
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
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  child: showVerify
                      ? Padding(
                          key: const ValueKey('verify'),
                          padding: const EdgeInsets.only(
                            bottom: 28,
                          ),
                          child: PrimaryButton(
                            label: 'Verify',
                            loading: _verifying,
                            onPressed: _verify,
                          ),
                        )
                      : Padding(
                          key: const ValueKey('timer'),
                          padding: const EdgeInsets.only(
                            bottom: 24,
                          ),
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
          onTap: () {
            Navigator.of(context).maybePop();
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: kBoxBorder,
              ),
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
                  LengthLimitingTextInputFormatter(
                    _length,
                  ),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) {
                  setState(() {
                    _hasError = false;
                  });
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

    final Color borderColor = _hasError
        ? kRed
        : (isActive ? Colors.black : kBoxBorder);

    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 120,
      ),
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

// ---------------------------------------------------------------------------
// 2. Account Created
// ---------------------------------------------------------------------------

class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Align(
              alignment: const Alignment(0, 0.1),
              child: Text(
                'Account is created!',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  30,
                ),
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/member3-login',
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Welcome Screen
// ---------------------------------------------------------------------------

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    final artHeight = height * 0.655;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            ClipPath(
              clipper: _WaveClipper(),
              child: SizedBox(
                width: double.infinity,
                height: artHeight,
                child: const RepaintBoundary(
                  child: CustomPaint(
                    painter: _TopoPainter(),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                26,
                20,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome To\nSkintel',
                      style: GoogleFonts.rubik(
                        fontSize: 36,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2B2B2B),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Start your\nskincare journey\nwith us!',
                      style: GoogleFonts.rubik(
                        fontSize: 16,
                        height: 1.25,
                        color: const Color(0xFF6B6B6B),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 17,
                  bottom: 10,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // TODO:
                      // Connect this button to the next screen.
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          width: 12,
                          height: 2,
                          color: Colors.black,
                        ),

                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wave Clipper
// ---------------------------------------------------------------------------

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.968)
      ..quadraticBezierTo(
        w * 0.92,
        h,
        w * 0.814,
        h,
      )
      ..cubicTo(
        w * 0.62,
        h,
        w * 0.42,
        h * 0.82,
        w * 0.197,
        h * 0.819,
      )
      ..cubicTo(
        w * 0.12,
        h * 0.818,
        w * 0.05,
        h * 0.826,
        0,
        h * 0.837,
      )
      ..close();
  }

  @override
  bool shouldReclip(
    covariant CustomClipper<Path> oldClipper,
  ) {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Topographic Painter
// ---------------------------------------------------------------------------

class _TopoPainter extends CustomPainter {
  const _TopoPainter();

  static double _field(double u, double v) {
    return math.sin(
          u * 1.15 + math.sin(v * 0.75) * 1.2,
        ) +
        math.cos(
          v * 0.95 - math.sin(u * 0.6) * 1.1,
        ) +
        0.55 *
            math.sin(
              u * 0.55 +
                  v * 0.45 +
                  1.3,
            );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()..color = Colors.black,
    );

    const double cell = 4;

    final nx = (size.width / cell).ceil();
    final ny = (size.height / cell).ceil();

    final scale = 10 / size.width;

    final values = List<double>.filled(
      (nx + 1) * (ny + 1),
      0,
    );

    for (var j = 0; j <= ny; j++) {
      for (var i = 0; i <= nx; i++) {
        values[j * (nx + 1) + i] = _field(
          i * cell * scale,
          j * cell * scale,
        );
      }
    }

    final path = Path();

    void seg(Offset a, Offset b) {
      path
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy);
    }

    Offset edge(
      double x0,
      double y0,
      double v0,
      double x1,
      double y1,
      double v1,
      double level,
    ) {
      final t = (level - v0) / (v1 - v0);

      return Offset(
        x0 + (x1 - x0) * t,
        y0 + (y1 - y0) * t,
      );
    }

    for (
      var level = -2.2;
      level <= 2.2;
      level += 0.32
    ) {
      for (var j = 0; j < ny; j++) {
        for (var i = 0; i < nx; i++) {
          final v0 =
              values[j * (nx + 1) + i];

          final v1 =
              values[j * (nx + 1) + i + 1];

          final v2 =
              values[(j + 1) * (nx + 1) + i + 1];

          final v3 =
              values[(j + 1) * (nx + 1) + i];

          final a = v0 >= level;
          final b = v1 >= level;
          final c = v2 >= level;
          final d = v3 >= level;

          if (a == b && b == c && c == d) {
            continue;
          }

          final x0 = i * cell;
          final y0 = j * cell;

          final x1 = x0 + cell;
          final y1 = y0 + cell;

          final top = a != b
              ? edge(
                  x0,
                  y0,
                  v0,
                  x1,
                  y0,
                  v1,
                  level,
                )
              : null;

          final right = b != c
              ? edge(
                  x1,
                  y0,
                  v1,
                  x1,
                  y1,
                  v2,
                  level,
                )
              : null;

          final bottom = d != c
              ? edge(
                  x0,
                  y1,
                  v3,
                  x1,
                  y1,
                  v2,
                  level,
                )
              : null;

          final left = a != d
              ? edge(
                  x0,
                  y0,
                  v0,
                  x0,
                  y1,
                  v3,
                  level,
                )
              : null;

          final pts = [
            top,
            right,
            bottom,
            left,
          ].whereType<Offset>().toList();

          if (pts.length == 2) {
            seg(
              pts[0],
              pts[1],
            );
          } else if (pts.length == 4) {
            final centerIn =
                (v0 + v1 + v2 + v3) / 4 >=
                    level;

            if (a == centerIn) {
              seg(
                top!,
                right!,
              );

              seg(
                bottom!,
                left!,
              );
            } else {
              seg(
                top!,
                left!,
              );

              seg(
                right!,
                bottom!,
              );
            }
          }
        }
      }
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFB9BDB4),
          Color(0xFFFFFFFF),
          Color(0xFFD9D2DA),
        ],
      ).createShader(rect);

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}