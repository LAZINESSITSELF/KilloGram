import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:killogram/config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:killogram/layout.dart';
import 'package:killogram/pages/home/home.dart';
import 'package:killogram/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Menyimpan token di secure storage
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Mengambil token dari secure storage
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Menghapus token (logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  // Login request
  Future<Map<String, dynamic>> login(
      BuildContext context, String email, String password) async {
    final Map<String, dynamic> requestData = {
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String token = responseData['token'];
        await saveToken(token);

        // Navigasi ke halaman Home setelah login berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Layout()),
        );

        return {'success': true, 'message': 'Login berhasil'};
      } else {
        final responseData = jsonDecode(response.body);
        return {'success': false, 'message': responseData['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan saat login'};
    }
  }

  Future<Map<String, dynamic>> checkSession() async {
    String? token = await getToken();
    if (token == null) {
      return {'success': false, 'message': 'Tidak ada token ditemukan'};
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/checkSession'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Kirim token dalam header
        },
      );

      print(
          'Response body: ${response.body}'); // Log response body untuk debugging

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Session valid'};
      } else {
        final responseData = jsonDecode(response.body);
        return {'success': false, 'message': responseData['message']};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat memeriksa sesi'
      };
    }
  }

  // Periksa apakah token valid (tidak perlu pengecekan sesi di sisi aplikasi)
  Future<Map<String, dynamic>> getUserData() async {
    final token = await _storage.read(
        key: 'jwt_token'); // Ambil token dari secure storage

    if (token == null) {
      return {'success': false, 'message': 'User not authenticated'};
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'user': data}; // Mengembalikan data pengguna
      } else {
        return {'success': false, 'message': 'Failed to fetch user data'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
    String username,
    String nickname,
    String location,
    List<String> interests,
    String profilePict,
  ) async {
    String? token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      return {'success': false, 'message': 'No token found'};
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Kirim token di header
      },
      body: jsonEncode({
        'username': username,
        'nickname': nickname,
        'location': location,
        'interest': interests,
        'profilePict': profilePict, // URL atau path gambar profil
      }),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': 'Profile updated successfully',
        'user': jsonDecode(response.body)
      };
    } else {
      return {'success': false, 'message': 'Failed to update profile'};
    }
  }

  Future<void> logout() async {
    try {
      // Menghapus token dari FlutterSecureStorage (untuk penyimpanan aman)
      await _storage.delete(key: 'jwt_token');
      
      // Menghapus data terkait login di SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');  // Jika ada data pengguna lain yang disimpan di SharedPreferences

      print("User logged out successfully");

      // Jika ada pengalihan route ke halaman login, bisa diproses di sini
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  // Fungsi untuk memeriksa apakah pengguna sudah login (token ada)
  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }
}
