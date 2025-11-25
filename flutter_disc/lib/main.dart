import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DiscordWelcomeScreen(),
    );
  }
}

class DiscordWelcomeScreen extends StatelessWidget {
  const DiscordWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF232C5D),
                  Color(0xFF3A45A1),
                  Color(0xFF5865F2),
                ],
              ),
            ),
          ),
          // Stars and blurred shapes
          Positioned.fill(
            child: CustomPaint(
              painter: _DiscordBackgroundPainter(),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 36),
                // Discord logo
                Image.asset(
                  'assets/discord_logo.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 32),
                // Welcome text
                Text(
                  'WELCOME TO\nDISCORD',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Hang out, play games or just talk. Tap below to get started!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Spacer(),
                // Register and Log In buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Register',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A45A1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Log In',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscordBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Blurred blobs (simulate planets/nebulae)
    paint.color = const Color(0xFFB388FF).withOpacity(0.18);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.25), 60, paint);

    paint.color = const Color(0xFF8C9EFF).withOpacity(0.15);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.18), 50, paint);

    paint.color = const Color(0xFF7C4DFF).withOpacity(0.12);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 70, paint);

    paint.color = Colors.white.withOpacity(0.10);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.8), 40, paint);

    // Stars (small squares and dots)
    paint.color = Colors.white.withOpacity(0.25);
    for (var i = 0; i < 40; i++) {
      final dx = (size.width * (0.05 + 0.9 * (i % 10) / 10));
      final dy = (size.height * (0.05 + 0.9 * (i ~/ 10) / 4));
      if (i % 3 == 0) {
        canvas.drawCircle(Offset(dx, dy), 1.5, paint);
      } else {
        canvas.drawRect(Rect.fromCenter(center: Offset(dx, dy), width: 3, height: 3), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}