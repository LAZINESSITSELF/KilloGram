import 'package:flutter/material.dart';
import 'package:killogram/layout.dart';
import 'package:killogram/pages/login.dart';
import 'package:killogram/services/authController.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KilloGram',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(), // SplashScreen untuk pengecekan session
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _checkSession();  // Mengecek session saat aplikasi pertama kali dibuka
  }

  Future<void> _checkSession() async {
    var result = await _authController.checkSession();
    if (result['success']) {
      // Jika session valid, arahkan ke Layout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Layout()),  // Halaman Layout dengan TabBar
      );
    } else {
      // Jika session tidak valid, arahkan ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),  // Tampilan loading saat pengecekan session
      ),
    );
  }
}
