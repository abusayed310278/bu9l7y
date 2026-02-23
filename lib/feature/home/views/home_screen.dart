import 'package:bu9l7y/app_ground.dart';
import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/feature/quiz/views/select_quiz_topics_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 84),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFD1C4B9),
                  child: Icon(Icons.person_rounded, size: 18, color: Color(0xFF6A5A4C)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: GoogleFonts.outfit(fontSize: 16, height: 22 / 16, color: const Color(0xFF000000), fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bu Ahmed',
                      style: GoogleFonts.outfit(fontSize: 20, height: 22 / 20, color: const Color(0xFF000000), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'CREDIT BALANCE',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          height: 22 / 14,
                          color: const Color(0xFF3C3C43),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.account_balance_wallet_rounded, size: 22, color: Color(0xFF284968)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '50.00',
                        style: GoogleFonts.outfit(fontSize: 40, height: 1.2, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'CR',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            height: 22 / 20,
                            color: const Color(0xFF3C3C43),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.error_rounded, color: Color(0xFFFF1E1E), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Low Credit Balance',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          height: 22 / 12,
                          color: const Color(0xFF3C3C43),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _ActionButton(
              iconPath: Images.play,
              text: 'Start New Quiz',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SelectQuizTopicsScreen()));
              },
            ),
            const SizedBox(height: 10),
            _ActionButton(
              iconPath: Images.cart,
              text: 'Get More Credits',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AppGround(initialIndex: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Your Progress',
              style: GoogleFonts.outfit(fontSize: 20, height: 22 / 20, color: Color(0xFF3C3C43), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(
                  child: _ProgressCard(iconPath: Images.quizz, value: '24', label: 'Quizzes Taken'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ProgressCard(iconPath: Images.avg, value: '88%', label: 'Avg. Accuracy'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Activity',
                    style: GoogleFonts.outfit(fontSize: 20, height: 22 / 20, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  'View All',
                  style: GoogleFonts.outfit(fontSize: 12, height: 1, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _ActivityTile(icon: Icons.science_outlined, title: 'General Science Quiz', subtitle: '2 hours ago', score: '9/10'),
            const SizedBox(height: 10),
            const _ActivityTile(icon: Icons.calculate_outlined, title: 'Mathematics', subtitle: 'Yesterday', score: '10/10'),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.iconPath, required this.text, this.onPressed});

  final String iconPath;
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF284968),
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 32, height: 32, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.outfit(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.iconPath, required this.value, required this.label});

  final String iconPath;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 144,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(iconPath, width: 48, height: 48),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 32, height: 1.2, color: Color(0xFF3C3C43), fontWeight: FontWeight.w500),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: Color(0xFF3C3C43), fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.icon, required this.title, required this.subtitle, required this.score});

  final IconData icon;
  final String title;
  final String subtitle;
  final String score;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF284968), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: Color(0xFF3C3C43), fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: Color(0xFF3C3C43), fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Text(
            score,
            style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: Color(0xFF3C3C43), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
