import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const DiscordCloneApp());
}

class DiscordCloneApp extends StatelessWidget {
  const DiscordCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Discord Clone',
      theme: ThemeData.dark(),
      home: const DiscordWelcomeScreen(),
    );
  }
}

class DiscordWelcomeScreen extends StatelessWidget {
  const DiscordWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A0A3F),
              Color(0xFF1C1C8C),
              Color(0xFF2B2BFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Efek partikel kecil seperti bintang
            Positioned.fill(
              child: CustomPaint(
                painter: StarBackgroundPainter(),
              ),
            ),

            // Efek blur (nebula)
            Positioned(
              top: 120,
              left: -40,
              child: BlurredCircle(
                size: 200,
                color: Colors.purpleAccent,
              ),
            ),
            Positioned(
              bottom: 80,
              right: -30,
              child: BlurredCircle(
                size: 180,
                color: Colors.blueAccent,
              ),
            ),

            // Konten utama
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 100),

                  // Logo dan teks
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/discord_logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 20),
                      Text(
                        "WELCOME TO DISCORD",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Hang out, play games or just talk. Tap below to get started!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  // Tombol
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () {},
                            child: Text(
                              "Register",
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1AFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () {},
                            child: Text(
                              "Log In",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter untuk partikel seperti bintang kecil di latar
class StarBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final randomOffsets = [
      const Offset(50, 100),
      const Offset(200, 300),
      const Offset(100, 500),
      const Offset(300, 150),
      const Offset(350, 600),
      const Offset(250, 700),
      const Offset(70, 400),
      const Offset(180, 250),
    ];

    for (final offset in randomOffsets) {
      canvas.drawCircle(offset, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Lingkaran blur lembut untuk efek nebula
class BlurredCircle extends StatelessWidget {
  final double size;
  final Color color;

  const BlurredCircle({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
