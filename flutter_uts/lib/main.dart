// lib/main.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FrontPage(),
    );
  }
}

class FrontPage extends StatefulWidget {
  const FrontPage({super.key});

  @override
  State<FrontPage> createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  static const _bgImageUrl =
      'https://storage.googleapis.com/tagjs-prod.appspot.com/v1/W7E6W2YHJp/t7y2kkgy_expires_30_days.png';
  static const _logoUrl =
      'https://storage.googleapis.com/tagjs-prod.appspot.com/v1/W7E6W2YHJp/i1oh4lcz_expires_30_days.png';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen colorful blue background
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_bgImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Foreground content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top content: logo + title
                  LayoutBuilder(builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final titleFont = math.min(38.0, w * 0.085);
                    final logoWidth = math.min(160.0, w * 0.32);
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 28.0, horizontal: w * 0.08),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: logoWidth,
                            height: logoWidth * 1.25,
                            child: Image.network(
                              _logoUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'WELCOME TO\nDISCORD',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFont,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Intro text (white for contrast)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                    child: Text(
                      'Hang out, play games or just talk. Tap below to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color.fromRGBO(255, 255, 255, 0.95),
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.transparent),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              // TODO: navigate to register
                              // ignore: avoid_print
                              print('Register pressed');
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * 0.05,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF161CBB),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              // TODO: navigate to login
                              // ignore: avoid_print
                              print('Log In pressed');
                            },
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.05,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}