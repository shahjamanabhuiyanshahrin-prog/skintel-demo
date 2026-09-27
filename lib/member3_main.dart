import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  static const double phoneWidth = 393;
  static const double phoneHeight = 852;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (size.width <= phoneWidth) {
      return child;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Center(
        child: Container(
          width: phoneWidth,
          height: phoneHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.black, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: const Size(phoneWidth, phoneHeight),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}