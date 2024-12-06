import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool isPassword;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.placeholder,
    this.isPassword = false, // Default tidak menggunakan mode password
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.white), // Text color to match dark theme
      decoration: InputDecoration(
        labelText: placeholder,
        labelStyle: TextStyle(color: Colors.white70), // Placeholder label style
        filled: true,
        fillColor: Color(0xFF0E0D19), // Light background for the text field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.white24), // Lighter border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.white24), // Lighter border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide:
              BorderSide(color: Color(0xFFFE8E06)), // Accent color when focused
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }
}
