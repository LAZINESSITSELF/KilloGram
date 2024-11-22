import 'package:flutter/material.dart';
import 'package:killogram/pages/login.dart';
import 'package:killogram/services/authController.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthController _authController = AuthController();

  final List<Map<String, String>> dummyPosts = [
    {
      "username": "user1",
      "profilePic": "https://via.placeholder.com/50",
      "postImage": "https://via.placeholder.com/300",
      "caption": "Ini adalah caption pertama.",
    },
    {
      "username": "user2",
      "profilePic": "https://via.placeholder.com/50",
      "postImage": "https://via.placeholder.com/300",
      "caption": "Caption yang kedua nih.",
    },
    {
      "username": "user3",
      "profilePic": "https://via.placeholder.com/50",
      "postImage": "https://via.placeholder.com/300",
      "caption": "Halo dunia, ini postingan ketiga.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  // Fungsi untuk memeriksa sesi
  Future<void> _checkSession() async {
    var result = await _authController.checkSession();
    if (!result['success']) {
      debugPrint('Session check failed: ${result['message']}');
      _redirectToLogin();
    } else {
      debugPrint('Session valid: ${result['message']}');
    }
  }

  // Navigasi ke halaman Login jika sesi tidak valid
  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KilloGram"),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              // Tambahkan navigasi ke chat/messaging
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: dummyPosts.length,
        itemBuilder: (context, index) {
          final post = dummyPosts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian atas (Username & Foto Profil)
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(post['profilePic']!),
                  ),
                  title: Text(post['username']!),
                  trailing: const Icon(Icons.more_vert),
                ),
                // Gambar Postingan
                Image.network(
                  post['postImage']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                ),
                // Bagian Bawah (Like, Comment, Caption)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: const [
                      SizedBox(width: 13),
                      Icon(Icons.favorite_border),
                      SizedBox(width: 16),
                      Icon(Icons.comment_outlined),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    post['caption']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}