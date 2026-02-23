import 'package:bu9l7y/feature/auth/views/sign_in_screen.dart';
import 'package:bu9l7y/feature/auth/views/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bu9l7y/core/constants/assets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 112),
                  const Center(child: _AppIcon()),
                  const SizedBox(height: 68),
                  SizedBox(
                    width: 300,
                    height: 36,
                    child: Row(
                      children: [
                        Text(
                          'Ready to',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            height: 1.125,
                            color: const Color(0xFF294D72),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Begin?',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            height: 1.125,
                            color: const Color(0xFF294D72),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 327,
                    height: 40,
                    child: Text(
                      'Sign up now to secure your progress and credit balance.',
                      maxLines: 2,
                      style: GoogleFonts.outfit(fontSize: 14, height: 1.4, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SignUpScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF284968),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text(
                    'Sign up',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SignInScreen()));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF284968),
                    side: const BorderSide(color: Color(0xFF284968), width: 1),
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text(
                    'Log in',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      height: 1.2,
                      letterSpacing: 0,
                      color: Color(0xFF284968),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 206, height: 206, child: Image.asset(Images.appLogo, fit: BoxFit.contain));
  }
}
