import 'package:bu9l7y/app_ground.dart';
import 'package:bu9l7y/core/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InsufficientCreditsScreen extends StatelessWidget {
  const InsufficientCreditsScreen({super.key, required this.requiredCredits, required this.currentCredits});

  final int requiredCredits;
  final int currentCredits;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 12),
                    color: const Color(0xFF000000),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Insufficient Credits',
                    style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: const Color(0xFF1F2224), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(color: const Color(0xFF284968), borderRadius: BorderRadius.circular(18)),
                child: Column(
                  children: [
                    Image.asset(Images.warning, width: 40, height: 40),
                    const SizedBox(height: 18),
                    Text(
                      'Insufficient Credits',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 16, height: 1, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'For continue you need to \npurchase credits',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: Colors.white, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 14),
                    // Text(
                    //   'Current: $currentCredits CR  •  Required: $requiredCredits CR\nNeed +$missingCredits CR',
                    //   textAlign: TextAlign.center,
                    //   style: GoogleFonts.outfit(
                    //     fontSize: 14,
                    //     height: 1.3,
                    //     color: const Color(0xFFE6EDF3),
                    //     fontWeight: FontWeight.w400,
                    //   ),
                    // ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(builder: (_) => const AppGround(initialIndex: 1)),
                      (route) => route.isFirst,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF284968),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text('Get Credits', style: GoogleFonts.outfit(fontSize: 16, height: 1.2, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
