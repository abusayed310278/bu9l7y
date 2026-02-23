import 'dart:io';

import 'package:bu9l7y/core/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _avatarFile;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Bu Ahmed');
    _emailController = TextEditingController(text: 'Email');
    _phoneController = TextEditingController(text: '(217) 555-0113');
    _bioController = TextEditingController(text: 'Write A Description About You');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      _avatarFile = File(picked.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 14),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 24),
                    color: const Color(0xFF1F2224),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Personal Details',
                    style: GoogleFonts.outfit(fontSize: 16, height: 1, color: Color(0xFF1F2224), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD4C8BE)),
                      child: _avatarFile == null
                          ? const Icon(Icons.person_rounded, size: 42, color: Color(0xFF6E5F55))
                          : ClipOval(child: Image.file(_avatarFile!, fit: BoxFit.cover)),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(4),
                          // decoration: BoxDecoration(
                          //   color: const Color(0xFF284968),
                          //   borderRadius: BorderRadius.circular(16),
                          //   border: Border.all(
                          //     color: const Color(0xFFFFFFFF),
                          //     width: 2.3,
                          //   ),
                          // ),
                          child: Image.asset(Images.edit),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Full name'),
              const SizedBox(height: 6),
              _FieldInput(controller: _nameController),
              const SizedBox(height: 12),
              const _FieldLabel('Email address'),
              const SizedBox(height: 6),
              _FieldInput(controller: _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              const _FieldLabel('Phone Number'),
              const SizedBox(height: 6),
              _FieldInput(controller: _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _FieldInput(controller: _bioController, height: 112, topAlign: true, maxLines: 5),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF284968),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: Color(0xFF2C313A), fontWeight: FontWeight.w400),
    );
  }
}

class _FieldInput extends StatelessWidget {
  const _FieldInput({required this.controller, this.height = 40, this.topAlign = false, this.maxLines = 1, this.keyboardType});

  final TextEditingController controller;
  final double height;
  final bool topAlign;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textAlignVertical: topAlign ? TextAlignVertical.top : TextAlignVertical.center,
        style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: Color(0xFF1F2224), fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFEBEBEB),
          contentPadding: EdgeInsets.fromLTRB(12, topAlign ? 10 : 0, 12, 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
