import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 28,
            color: Color(0xFF30343A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
