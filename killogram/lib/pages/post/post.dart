import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:killogram/layout.dart';
import 'package:killogram/services/postController.dart';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _textController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Fungsi untuk memilih gambar dari kamera
  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk memilih gambar dengan opsi kamera atau galeri
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi untuk mengunggah gambar ke Cloudinary
  Future<String?> _uploadImageToCloudinary(String imagePath) async {
    final timestamp = DateTime.now();
    final publicId = 'post_media_$timestamp';
    try {
      final cloudinary = Cloudinary.fromStringUrl(
        'cloudinary://432144392712252:voJkHj_fOMQCrGkMPDmtdTD4mtQ@dyxiixski',
      );

      final result = await cloudinary.uploader().upload(
            File(imagePath),
            params: UploadParams(
              publicId: publicId,
              uniqueFilename: true,
              overwrite: true,
            ),
          );

      if (result?.data?.publicId != null) {
        return result?.data?.secureUrl;
      } else {
        print('Error uploading image: ${result?.error?.message}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Fungsi untuk mengupload postingan baru
  Future<void> _createPost() async {
    setState(() {
      _isLoading = true;
    });

    String? textContent = _textController.text;
    String? imageUrl;

    if (_image != null) {
      imageUrl = await _uploadImageToCloudinary(_image!.path);
    }

    try {
      bool success = await PostService().createPost(imageUrl, textContent);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Layout()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create post')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      print('Error creating post: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter text content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: _image == null
                  ? Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Text('Tap to select image')),
                    )
                  : Image.file(
                      _image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _createPost,
                    child: const Text('Post'),
                  ),
          ],
        ),
      ),
    );
  }
}
