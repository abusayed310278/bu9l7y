import 'package:bu9l7y/feature/quiz/views/review_answers_screen.dart';
import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(Icons.arrow_back, size: 24),
                    color: const Color(0xFF1F2224),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Question 5 of 5',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 16, height: 1, color: Color(0xFF1F2224), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 1,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE6E6E6),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF284968)),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    _ScoreRing(percent: 0.6, label: 'Score', valueText: '60%'),
                    const SizedBox(height: 18),
                    const _ResultTile(
                      icon: Icons.track_changes_outlined,
                      iconBg: Color(0xFFE8F2FF),
                      iconColor: Color(0xFF1E8BD7),
                      title: 'Total Questions',
                      value: '5',
                    ),
                    const SizedBox(height: 12),
                    const _ResultTile(
                      icon: Icons.check_circle_outline_rounded,
                      iconBg: Color(0xFFE8FFF0),
                      iconColor: Color(0xFF2BB673),
                      title: 'Correct Answers',
                      value: '3',
                    ),
                    const SizedBox(height: 12),
                    const _ResultTile(
                      icon: Icons.emoji_events_outlined,
                      iconBg: Color(0xFFF2ECFF),
                      iconColor: Color(0xFF9B59FF),
                      title: 'Topics',
                      value: 'Computer System',
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ReviewAnswersScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B86CD),
                          padding: const EdgeInsets.all(10),
                          side: const BorderSide(color: Color(0xFF0B86CD), width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                        icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                        label: const Text(
                          'Review Answers',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 16, height: 1.2, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF284968),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.refresh_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Take Another Quiz',
                              style: TextStyle(fontFamily: 'Outfit', fontSize: 16, height: 1.2, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6E6E6),
                          foregroundColor: const Color(0xFF3C3C43),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                        icon: const Icon(Icons.home_outlined, size: 20),
                        label: const Text(
                          'Back to home',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 16, height: 1.2, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.icon, required this.iconBg, required this.iconColor, required this.title, required this.value});

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3D3D3), width: 0.5),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    height: 1.2,
                    color: Color(0xFF3C3C43),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    height: 1.2,
                    color: Color(0xFF1F2224),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.percent, required this.valueText, required this.label});

  final double percent;
  final String valueText;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 181,
      width: 181,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 181,
            width: 181,
            child: Transform.rotate(
              angle: -1.57079632679,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 16,
                strokeCap: StrokeCap.round,
                backgroundColor: const Color(0xFFE6E6E6),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF284968)),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                valueText,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 48,
                  height: 1.2,
                  color: Color(0xFF000000),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  height: 1.2,
                  color: Color(0xFF878787),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
