import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Widget loginButton({
    required String text,
    required IconData icon,
    required bool isDark,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.black),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.transparent,
          side: BorderSide(
            color: isDark ? Colors.white : Colors.black12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    final isDark = theme.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  Text(
                    'ChatGPT',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Log in or sign up',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'You\'ll get smarter responses and can upload files, images, and more.',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white54 : Colors.black26,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // ❗ TIDAK DIUBAH
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Continue'),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  loginButton(
                    text: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  loginButton(
                    text: 'Continue with Apple',
                    icon: Icons.apple,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  loginButton(
                    text: 'Continue with Microsoft',
                    icon: Icons.window,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  loginButton(
                    text: 'Continue with phone',
                    icon: Icons.phone,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 40),

                  Center(
                    child: Text(
                      'Terms of Use | Privacy Policy',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ===== DARK MODE BUTTON (KANAN ATAS) =====
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: theme.toggleTheme,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
      ),
    );
  }
}
