import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:killogram/services/authController.dart';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _nickname = '';
  String _location = '';
  List<String> _interests = [];
  String _profilePict = ''; // URL atau path gambar profil

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data dari profil yang ada
    _username = widget.userData['username'] ?? '';
    _nickname = widget.userData['nickname'] ?? '';
    _location = widget.userData['location'] ?? '';
    _interests = List<String>.from(widget.userData['interest'] ?? []);
    _profilePict = widget.userData['profilePict'] ?? '';
  }

  final ImagePicker _picker = ImagePicker();

  // Fungsi untuk memilih gambar profil
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePict = image.path; // Simpan path gambar yang dipilih
      });
    }
  }

  // Fungsi untuk mengunggah gambar ke Cloudinary
  Future<String?> _uploadImageToCloudinary(String imagePath) async {
    try {
      // Menyiapkan instance Cloudinary dengan kredensial
      final cloudinary=Cloudinary.fromStringUrl('cloudinary://432144392712252:voJkHj_fOMQCrGkMPDmtdTD4mtQ@dyxiixski');

      final result = await cloudinary.uploader().upload(
        File(imagePath),
        params: UploadParams(
          publicId: _nickname,
          uniqueFilename: true,
          overwrite: true
        )
      );

      if (result?.data?.publicId != null) {
        return result?.data?.secureUrl;  // Mendapatkan URL gambar yang diunggah
      } else {
        print('Error uploading image: ${result?.error?.message}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Fungsi untuk memperbarui profil
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? uploadedImageUrl = '';
      if (_profilePict.isNotEmpty) {
        uploadedImageUrl = await _uploadImageToCloudinary(_profilePict);
      }

      final result = await AuthController().updateUserProfile(
        _username,
        _nickname,
        _location,
        _interests,
        uploadedImageUrl ?? '', // Kirim URL gambar jika berhasil diunggah
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Profile updated!')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to update profile : ${uploadedImageUrl}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _profilePict.isNotEmpty
                            ? FileImage(File(_profilePict)) as ImageProvider
                            : AssetImage(
                                'assets/images/default/default-profile.png'),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      initialValue: _username,
                      decoration: InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _username = value;
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: _nickname,
                      enabled: false,
                      decoration: InputDecoration(labelText: 'Nickname'),
                      onChanged: (value) {
                        setState(() {
                          _nickname = value;
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: _location,
                      decoration: InputDecoration(labelText: 'Location'),
                      onChanged: (value) {
                        setState(() {
                          _location = value;
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: _interests.join(', '),
                      decoration: InputDecoration(labelText: 'Interests'),
                      onChanged: (value) {
                        setState(() {
                          _interests =
                              value.split(',').map((e) => e.trim()).toList();
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text("Save Changes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
