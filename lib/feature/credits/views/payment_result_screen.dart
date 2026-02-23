import 'package:bu9l7y/app_ground.dart';
import 'package:bu9l7y/core/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key, required this.success});

  final bool success;

  @override
  Widget build(BuildContext context) {
    final String title = success ? 'Successfully Purchase' : 'Purchase Failed';
    final String subtitle = success ? 'You have successfully purchase\n150 credits' : 'Try again after few moments';
    final String buttonText = success ? 'Back To Home' : 'Try Again';
    final String iconAsset = success ? Images.success : Images.failed;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 24),
                    color: const Color(0xFF1F2224),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: const Color(0xFF000000), fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              width: 240,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(color: const Color(0xFF284968), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    // decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Center(child: Image.asset(iconAsset, width: 38, height: 38)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontSize: 14, height: 1.2, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const AppGround(initialIndex: 0),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF284968),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text(buttonText, style: GoogleFonts.outfit(fontSize: 16, height: 1.2, fontWeight: FontWeight.w400)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
