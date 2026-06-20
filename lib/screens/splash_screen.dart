import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../utils/app_colors.dart';
import 'auth/register_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleSession();
  }

  Future<void> _handleSession() async {
    // Delay wajib tepat 3 detik
    await Future.delayed(const Duration(seconds: 3));

    final prefs = PrefsService();
    final bool isLoggedInLocally = await prefs.isLoggedIn();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (isLoggedInLocally && currentUser != null) {
      // Sesi masih valid -> langsung ke Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Belum login -> ke halaman Daftar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/foto.jpg',
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.public,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SpaceNews Core',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
