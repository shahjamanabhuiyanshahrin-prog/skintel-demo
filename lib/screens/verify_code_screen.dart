import 'dart:async';
import 'package:flutter/material.dart';
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});
  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<String> code = ['', '', '', ''];
  int secondsLeft = 20;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    secondsLeft = 20;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _tap(String v) {
    setState(() {
      final i = code.indexOf('');
      if (i != -1) code[i] = v;
    });
  }

  void _back() {
    setState(() {
      for (int i = code.length - 1; i >= 0; i--) {
        if (code[i].isNotEmpty) {
          code[i] = '';
          break;
        }
      }
    });
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
              'Please check your email',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black54),
                children: [
                  const TextSpan(text: "We've sent a code to "),
                  TextSpan(
                    text: widget.email,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) {
                return Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: code[i].isNotEmpty
                          ? Colors.black
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    code[i],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResetPasswordScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: GestureDetector(
                onTap: () {
                  if (secondsLeft == 0) {
                    setState(() {
                      code[0] = code[1] = code[2] = code[3] = '';
                    });
                    _startTimer();
                  }
                },
                child: Text(
                  secondsLeft > 0
                      ? 'Send code again  00:${secondsLeft.toString().padLeft(2, '0')}'
                      : 'Send code again',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ),
            const Spacer(),
            _keypad(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _keypad() {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['+*#', '0', 'back'],
    ];
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((k) {
              if (k == 'back') {
                return IconButton(
                  icon: const Icon(Icons.backspace_outlined, size: 20),
                  onPressed: _back,
                );
              }
              if (k == '+*#') {
                return const Text(
                  '+ * #',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                );
              }
              return SizedBox(
                width: 60,
                height: 44,
                child: TextButton(
                  onPressed: () => _tap(k),
                  child: Text(k, style: const TextStyle(fontSize: 17)),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}