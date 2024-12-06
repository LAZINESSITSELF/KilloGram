import 'package:flutter/material.dart';
import 'package:killogram/components/primarybutton.dart';
import 'package:killogram/components/textfield.dart';
import 'package:killogram/layout.dart';
import 'package:killogram/pages/register.dart';
import 'package:killogram/services/authController.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = AuthController();

  // Fungsi untuk login
  Future<void> _login(BuildContext context) async {
    final result = await authController.login(
      context,
      emailController.text,
      passwordController.text,
    );

    if (result['success']) {
      // Jika login berhasil, arahkan ke HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Layout()),
      );
    } else {
      // Jika login gagal, tampilkan SnackBar dengan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: emailController,
              placeholder: 'Email',
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: passwordController,
              placeholder: 'Password',
              isPassword: true,
            ),
            SizedBox(height: 20),
            CustomButton(
              label: 'Login',
              onPressed: () => _login(context),  // Panggil fungsi login di sini
            ),
            TextButton(
              onPressed: () {
                // Navigasi ke halaman RegisterPage jika belum punya akun
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Belum punya akun? Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}