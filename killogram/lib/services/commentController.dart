import 'package:http/http.dart' as http;
import 'package:killogram/config/api_config.dart';
import 'dart:convert';
import 'package:killogram/models/comment.dart';
import 'package:killogram/services/authController.dart';

class CommentService {
  final String baseUrl = '${ApiConfig.baseUrl}/comment';

  // Fetch comments based on postId
  Future<List<Comment>> fetchComments(String postId) async {
    String? token = await AuthController().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$postId'),
      headers: {
        'Authorization': 'Bearer $token'
      }, // Menggunakan token autentikasi
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Comment.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  // Add a new comment
  Future<bool> addComment(String postId, String commentContent) async {
    try {
      String? token = await AuthController()
          .getToken(); // Mendapatkan token dari AuthController
      final response = await http.post(
        Uri.parse('$baseUrl/add'), // URL untuk menambahkan komentar
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Menambahkan token ke header untuk otentikasi
        },
        body: json.encode({
          'postId': postId, // ID post yang akan dikomentari
          'comment': commentContent, // Konten komentar
          'status': 0, // Status komentar, bisa disesuaikan sesuai kebutuhan
        }),
      );

      if (response.statusCode == 201) {
        return true; // Jika berhasil menambahkan komentar, kembalikan true
      } else {
        throw Exception('Failed to add comment'); // Lempar error jika gagal
      }
    } catch (e) {
      print('Error: $e'); // Log error jika ada masalah
      return false; // Kembalikan false jika gagal
    }
  }
}
