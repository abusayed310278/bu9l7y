import 'package:bu9l7y/app_ground.dart';
import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/feature/quiz/views/select_quiz_topics_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showAllRecentActivity = false;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: user == null
                        ? null
                        : FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .snapshots(),
                    builder: (context, snapshot) {
                      final Map<String, dynamic>? data = snapshot.data?.data();
                      final String name = _readName(data, user);
                      final String imageUrl = _readImageUrl(data, user);

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFD1C4B9),
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl.isEmpty
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 18,
                                    color: Color(0xFF6A5A4C),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  height: 22 / 16,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                name,
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  height: 22 / 20,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 84),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: user == null
                          ? null
                          : FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .snapshots(),
                      builder: (context, snapshot) {
                        final int credits = _readCredits(snapshot.data?.data());
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
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
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    credits.toString(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 40,
                                      height: 1.2,
                                      color: const Color(0xFF3C3C43),
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                  if (credits <= 50) ...[
                                    const Icon(
                                      Icons.error_rounded,
                                      color: Color(0xFFFF1E1E),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    credits <= 50
                                        ? 'Low Credit Balance'
                                        : 'Credits available',
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
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _ActionButton(
                      iconPath: Images.play,
                      text: 'Start New Quiz',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SelectQuizTopicsScreen(),
                          ),
                        );
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
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: user == null
                          ? null
                          : FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('quizAttempts')
                                .orderBy('createdAt', descending: true)
                                .limit(30)
                                .snapshots(),
                      builder: (context, snapshot) {
                        final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                            docs = snapshot.data?.docs ?? const [];
                        final int totalQuizzes = docs.length;
                        double average = 0;
                        if (docs.isNotEmpty) {
                          double sum = 0;
                          for (final doc in docs) {
                            sum += _readDouble(doc.data()['scorePercent']);
                          }
                          average = sum / docs.length;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Progress',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                height: 22 / 20,
                                color: const Color(0xFF3C3C43),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _ProgressCard(
                                    iconPath: Images.quizz,
                                    value: '$totalQuizzes',
                                    label: 'Quizzes Taken',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ProgressCard(
                                    iconPath: Images.avg,
                                    value: '${average.round()}%',
                                    label: 'Avg. Accuracy',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Recent Activity',
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      height: 22 / 20,
                                      color: const Color(0xFF3C3C43),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showAllRecentActivity = true;
                                    });
                                  },
                                  child: Text(
                                    _showAllRecentActivity
                                        ? 'Showing all'
                                        : 'View All',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      height: 1,
                                      color: const Color(0xFF3C3C43),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (docs.isEmpty)
                              Text(
                                'No quiz activity yet.',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ...docs
                                .take(_showAllRecentActivity ? docs.length : 2)
                                .map((doc) {
                              final Map<String, dynamic> data = doc.data();
                              final int correct = _readInt(data['correctAnswers']);
                              final int total = _readInt(data['totalQuestions']);
                              final String title =
                                  (data['topicTitle'] as String?)?.trim().isNotEmpty ==
                                          true
                                      ? (data['topicTitle'] as String).trim()
                                      : 'Quiz Attempt';
                              final Timestamp? ts = data['createdAt'] as Timestamp?;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ActivityTile(
                                  icon: _iconForTitle(title),
                                  title: title,
                                  subtitle: _timeAgo(ts),
                                  score: '$correct/$total',
                                ),
                              );
                            }),
                          ],
                        );
                      },
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

  String _readName(Map<String, dynamic>? data, User? user) {
    final String firestoreName = (data?['fullName'] as String?)?.trim() ?? '';
    final String authName = (user?.displayName ?? '').trim();
    if (firestoreName.isNotEmpty) {
      return firestoreName;
    }
    if (authName.isNotEmpty) {
      return authName;
    }
    return 'User';
  }

  String _readImageUrl(Map<String, dynamic>? data, User? user) {
    final List<String> keys = <String>[
      'image',
      'avatarUrl',
      'photoURL',
      'photoUrl',
      'imageUrl',
    ];
    for (final String key in keys) {
      final String value = (data?[key] as String?)?.trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }
    return (user?.photoURL ?? '').trim();
  }

  int _readCredits(Map<String, dynamic>? data) {
    final dynamic value = data?['credits'] ?? data?['creditBalance'];
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  double _readDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value.trim()) ?? 0;
    return 0;
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  IconData _iconForTitle(String title) {
    final String t = title.toLowerCase();
    if (t.contains('math')) return Icons.calculate_outlined;
    if (t.contains('science')) return Icons.science_outlined;
    if (t.contains('security')) return Icons.security_outlined;
    if (t.contains('internet')) return Icons.public_outlined;
    return Icons.quiz_outlined;
  }

  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'just now';
    final DateTime now = DateTime.now();
    final DateTime then = timestamp.toDate();
    final Duration diff = now.difference(then);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${then.month}/${then.day}/${then.year}';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.iconPath,
    required this.text,
    this.onPressed,
  });

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 32, height: 32, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.iconPath,
    required this.value,
    required this.label,
  });

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
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(iconPath, width: 48, height: 48),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 32,
              height: 1.2,
              color: Color(0xFF3C3C43),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 16,
              height: 1.2,
              color: Color(0xFF3C3C43),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.score,
  });

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
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF284968),
              borderRadius: BorderRadius.circular(8),
            ),
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
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    height: 1.2,
                    color: Color(0xFF3C3C43),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    height: 1.2,
                    color: Color(0xFF3C3C43),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            score,
            style: GoogleFonts.outfit(
              fontSize: 16,
              height: 1.2,
              color: Color(0xFF3C3C43),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
