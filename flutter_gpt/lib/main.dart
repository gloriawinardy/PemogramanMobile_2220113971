import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'theme_notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

/* ================= APP ================= */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeNotifier>().isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}

/* ================= SPLASH ================= */

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeNotifier>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFF4FD8),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ChatGPT',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 6,
              backgroundColor: isDark ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= WELCOME ================= */

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget button({
    required String text,
    required Color bg,
    required Color textColor,
    VoidCallback? onTap,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    final isDark = theme.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFF4FD8),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'ChatGPT',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : Colors.black,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    button(
                      text: 'Continue with Google',
                      bg: Colors.white,
                      textColor: Colors.black,
                      icon: Icons.g_mobiledata,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    button(
                      text: 'Sign up',
                      bg: Colors.white,
                      textColor: Colors.black,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    button(
                      text: 'Log in',
                      bg: Colors.black, // ❗ TIDAK DIUBAH
                      textColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ===== DARK MODE BUTTON (POSISI ASLI) =====
          Positioned(
            top: 48,
            left: 16,
            child: GestureDetector(
              onTap: theme.toggleTheme,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
