import 'package:flutter/material.dart';
import 'package:killogram/pages/home/home.dart';
import 'package:killogram/pages/login.dart';
import 'package:killogram/pages/post/post.dart';
import 'package:killogram/pages/profile/profile.dart';
import 'package:killogram/services/authController.dart';

class Layout extends StatefulWidget {
  const Layout({Key? key}) : super(key: key);

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final AuthController _authController = AuthController();
  int _selectedIndex = 0; // Menetapkan tab pertama sebagai Home
  late Future<bool> _sessionCheck; // Tambahkan Future untuk pengecekan sesi
  final List<Widget> _pages = [
    const HomePage(),
    const PostPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _sessionCheck = _authController.checkSession().then((result) {
      if (!result['success']) {
        // Jika sesi tidak valid, redirect ke LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        return false;
      }
      return true; // Sesi valid
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // Loading indikator
          );
        }

        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return const Scaffold(
            body: Center(child: Text("Terjadi kesalahan!")), // Error handling
          );
        }

        // Render halaman utama setelah sesi valid
        return Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
