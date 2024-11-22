import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:killogram/config/api_config.dart';
import 'package:killogram/models/post.dart';
import 'package:killogram/services/authController.dart';

class PostService {
  final String baseUrl = '${ApiConfig.baseUrl}/posts';

  // Mengambil semua postingan
  Future<List<Post>> fetchPosts() async {
    String? token = await AuthController().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Post.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  // Membuat postingan baru
  Future<bool> createPost(String? imageUrl, String? textContent) async {
    try {
      String? token = await AuthController().getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Gantilah dengan token yang valid
        },
        body: json.encode({
          'textContent': textContent,
          'urlMedia': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        return true; // Postingan berhasil
      } else {
        throw Exception('Failed to create post'); // Jika gagal, lempar error
      }
    } catch (e) {
      print('Error: $e'); // Log error jika ada masalah
      return false; // Kembalikan false jika gagal
    }
  }

  Future<void> likePost(String postId) async {
    String? token = await AuthController().getToken();
    
    await http.post(
      Uri.parse('$baseUrl/like/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  // Unlike a post
  Future<void> unlikePost(String postId) async {
    String? token = await AuthController().getToken();
    
    await http.delete(
      Uri.parse('$baseUrl/unlike/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<bool> checkIfPostLiked(String postId) async {
  String? token = await AuthController().getToken();

  final response = await http.get(
    Uri.parse('$baseUrl/getLikeStatus/$postId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['isLiked']; // Mengembalikan status like
  } else {
    throw Exception('Failed to check like status');
  }
}
}
