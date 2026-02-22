import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Credits',
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
