// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/ocr_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Split Bill App',
      theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Directly showing OCR screen as home
      home: const OCRScreen(),
      routes: {
      // Login and register routes commented out for now
      // '/login': (_) => const LoginScreen(),
      // '/register': (_) => const RegisterScreen(),
      // '/home': (_) => const HomeScreen(),
      '/ocr': (_) => const OCRScreen(),
      },
    );
  }
}
