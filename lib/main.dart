import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'utils/app_colors.dart';

void main() async {
  // 1. Memastikan binding framework Flutter siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase dengan konfigurasi sesuai platform yang aktif
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Jalankan Aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceNews Core',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(), // Membaca tema dari app_colors.dart
      home:
          const SplashScreen(), // Menuju halaman splash screen saat pertama buka
    );
  }
}
