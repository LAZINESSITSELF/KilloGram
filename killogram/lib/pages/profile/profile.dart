import 'package:flutter/material.dart';
import 'package:killogram/pages/login.dart';
import 'package:killogram/pages/profile/curency.dart';
import 'package:killogram/pages/profile/edit.dart';
import 'package:killogram/services/authController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fungsi untuk mengambil data pengguna
  _loadUserData() async {
    final result = await AuthController().getUserData();
    if (result['success']) {
      setState(() {
        userData = result['user'];
      });
    } else {
      // Tampilkan pesan kesalahan jika gagal
      print(result['message']);
    }
  }

  // Fungsi untuk logout
  _logout() async {
    // Proses logout yang melibatkan penghapusan token JWT dan data lainnya.
    await AuthController()
        .logout(); // Pastikan AuthController memiliki metode logout yang benar
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.currency_exchange),
            onPressed: () {
              // Navigasi ke halaman konversi mata uang
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CurrencyConversionPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: userData.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Loading indicator jika data belum ada
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Avatar + Username Section
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: (userData['profilePict'] != null &&
                              userData['profilePict'].isNotEmpty)
                          ? NetworkImage(userData['profilePict'])
                          : const AssetImage(
                                  'assets/images/default/default-profile.png')
                              as ImageProvider,
                    ),

                    SizedBox(height: 16),
                    Text(
                      userData['nickname'] ?? 'Nickname Not Found',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),

                    // User Details Section in Cards
                    Card(
                      elevation: 5,
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: Icon(Icons.email),
                              title: Text('Email'),
                              subtitle: Text(userData['email'] ?? 'Not Set'),
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.location_on),
                              title: Text('Location'),
                              subtitle: Text(userData['location'] ?? 'Not Set'),
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.star),
                              title: Text('Interests'),
                              subtitle: Text(userData['interest']?.join(', ') ??
                                  'Not Set'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfilePage(userData: userData)),
                            );
                          },
                          child: Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _logout, // Panggil fungsi logout di sini
                          child: Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
