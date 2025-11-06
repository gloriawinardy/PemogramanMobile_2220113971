import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discord Login Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: const DiscordLoginPage(),
    );
  }
}

class DiscordLoginPage extends StatelessWidget {
  const DiscordLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Base gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0A3C),
                  Color(0xFF181B7A),
                ],
              ),
            ),
          ),

          // Blended background image (blur blob)
          Positioned.fill(
            child: Opacity(
              opacity: 0.14,
              child: Image.asset(
                'assets/background/blur_blob.png',
                fit: BoxFit.cover,
                alignment: Alignment(-0.4, -0.6),
              ),
            ),
          ),

          // Additional subtle overlay blobs for depth
          Positioned(
            left: -120,
            top: -80,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/background/blur_blob.png',
                width: 700,
                height: 700,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: -100,
            bottom: -120,
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(
                'assets/background/blur_blob.png',
                width: 600,
                height: 600,
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.lighten,
              ),
            ),
          ),

          // Tiny pixel stars using CustomPaint
          Positioned.fill(
            child: CustomPaint(
              painter: TinySquaresPainter(),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/logo/discord_logo.png',
                    width: width * 0.25,
                  ),
                  SizedBox(height: height * 0.03),

                  // Title
                  Text(
                    "WELCOME TO\nDISCORD",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: width * 0.08,
                      fontWeight: FontWeight.w900,
                      height: 1.02,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: height * 0.01),

                  // Subtitle
                  Text(
                    "Hang out, play games or just talk. Tap below to get started!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      color: Colors.white70,
                      fontSize: width * 0.038,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: height * 0.16),

                  // Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: Text(
                            "Register",
                            style: GoogleFonts.montserrat(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E33E0),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: Text(
                            "Log In",
                            style: GoogleFonts.montserrat(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Home indicator mimic
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Center(
              child: Container(
                width: width * 0.18,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter drawing tiny squares and faint particles across the screen.
class TinySquaresPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    // Draw a bunch of small squares distributed pseudo-randomly
    const int count = 70;
    final rand = _FastRandom(42);
    for (int i = 0; i < count; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      final side = 2.0 + rand.nextDouble() * 3.0;
      canvas.drawRect(Rect.fromLTWH(dx, dy, side, side), paint);
    }

    // Draw some faint larger sparkles
    final paint2 = Paint()..color = Colors.white.withOpacity(0.03);
    for (int i = 0; i < 8; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      canvas.drawCircle(Offset(dx, dy), 1.2 + rand.nextDouble() * 3.0, paint2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple pseudo random generator (fast)
class _FastRandom {
  int _seed;
  _FastRandom(this._seed);

  double nextDouble() {
    _seed = 1664525 * _seed + 1013904223;
    final v = (_seed & 0x7fffffff) / 0x7fffffff;
    return v;
  }
}