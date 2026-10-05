import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  // true hole Continue chaple Home e jabe, false hole onboarding e jabe
  final bool fromLogin;
  const WelcomeScreen({super.key, this.fromLogin = false});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Image will cover around 65% of the screen
    final imageHeight = screenHeight * 0.66;

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),

      body: SafeArea(
        child: Center(
          child: Container(
            width: screenWidth > 430 ? 430 : screenWidth,
            height: screenHeight > 850 ? 850 : screenHeight,
            color: Colors.white,

            child: Stack(
              children: [

                // TOP IMAGE
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: imageHeight,

                  child: ClipPath(
                    clipper: ImageWaveClipper(),

                    child: Image.asset(
                      'assets/images/welcome.jpeg',

                      width: double.infinity,
                      height: imageHeight,
                      fit: BoxFit.cover,

                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF8E9A80),
                          alignment: Alignment.center,
                          child: const Text(
                            'Welcome image not found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // TEXT SECTION
                Positioned(
                  left: 40,
                  right: 30,
                  top: imageHeight + 35,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        'Welcome To',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF333333),
                          height: 1.05,
                        ),
                      ),

                      const Text(
                        'Skintel',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF333333),
                          height: 1.05,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Skincare Has No Gender.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF355C52),
                          letterSpacing: 0.2,
                        ),
                      ),

                      const SizedBox(height: 9),

                      const Text(
                        'Start your\nskincare journey\nwith us!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF999999),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                // CONTINUE BUTTON
                Positioned(
                  left: 0,
                  right: 15,
                  bottom: 38,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF777777),
                        ),
                      ),

                      const SizedBox(width: 10),

                      GestureDetector(
                        onTap: () {
                          if (fromLogin) {
                            // Login er por: Welcome -> Home
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                            );
                          } else {
                            // Signup er por: Welcome -> Onboarding
                            Navigator.pushReplacementNamed(
                              context,
                              '/onboarding',
                            );
                          }
                        },

                        child: Container(
                          width: 34,
                          height: 34,

                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // BOTTOM HOME INDICATOR
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,

                  child: Center(
                    child: Container(
                      width: 100,
                      height: 4,

                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
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


// CURVED BOTTOM OF IMAGE
class ImageWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height * 0.92);

    path.cubicTo(
      size.width * 0.18,
      size.height * 0.87,
      size.width * 0.32,
      size.height * 0.91,
      size.width * 0.47,
      size.height * 0.96,
    );

    path.cubicTo(
      size.width * 0.63,
      size.height * 1.01,
      size.width * 0.78,
      size.height * 0.99,
      size.width,
      size.height * 0.92,
    );

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}