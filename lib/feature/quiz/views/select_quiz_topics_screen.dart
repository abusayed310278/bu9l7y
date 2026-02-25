import 'package:bu9l7y/feature/credits/views/insufficient_credits_screen.dart';
import 'package:bu9l7y/feature/quiz/views/quiz_question_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectQuizTopicsScreen extends StatefulWidget {
  const SelectQuizTopicsScreen({super.key});

  @override
  State<SelectQuizTopicsScreen> createState() => _SelectQuizTopicsScreenState();
}

class _SelectQuizTopicsScreenState extends State<SelectQuizTopicsScreen> {
  final Set<int> _selectedIndexes = <int>{};
  bool _showAllTopics = false;

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
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select Quiz Topics',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      height: 1,
                      color: Color(0xFF1F2224),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllTopics = true;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: const Color(0xFF1E8BD7),
                    ),
                    child: Text(
                      _showAllTopics ? 'Showing all' : 'See all',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('models')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, modelSnapshot) {
                  if (modelSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final List<_TopicItem> topics = modelSnapshot.data?.docs
                          .map(_TopicItem.fromDoc)
                          .toList() ??
                      <_TopicItem>[];
                  if (topics.isEmpty) {
                    return const Center(child: Text('No quiz models found.'));
                  }
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('questions')
                        .snapshots(),
                    builder: (context, questionSnapshot) {
                      final Map<String, int> countsByModel = <String, int>{};
                      if (questionSnapshot.hasData) {
                        for (final doc in questionSnapshot.data!.docs) {
                          final String modelId =
                              (doc.data()['modelId'] as String? ?? '').trim();
                          if (modelId.isEmpty) continue;
                          countsByModel[modelId] =
                              (countsByModel[modelId] ?? 0) + 1;
                        }
                      }

                      return ListView.separated(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _showAllTopics
                            ? topics.length
                            : (topics.length > 5 ? 5 : topics.length),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final _TopicItem base = topics[index];
                          final int questions = countsByModel[base.id] ?? 0;
                          final _TopicItem topic = base.copyWith(
                            questions: questions,
                            credits: questions * 2,
                          );
                          final bool selected = _selectedIndexes.contains(index);
                          return _TopicCard(
                            topic: topic,
                            selected: selected,
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selectedIndexes.remove(index);
                                } else {
                                  _selectedIndexes.add(index);
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('models')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  final List<_TopicItem> topics = snapshot.data?.docs
                          .map(_TopicItem.fromDoc)
                          .toList() ??
                      <_TopicItem>[];
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('questions').snapshots(),
                    builder: (context, questionSnapshot) {
                      final Map<String, int> countsByModel = <String, int>{};
                      if (questionSnapshot.hasData) {
                        for (final doc in questionSnapshot.data!.docs) {
                          final String modelId = (doc.data()['modelId'] as String? ?? '').trim();
                          if (modelId.isEmpty) continue;
                          countsByModel[modelId] = (countsByModel[modelId] ?? 0) + 1;
                        }
                      }

                      final Set<int> validIndexes = _selectedIndexes
                          .where((index) => index >= 0 && index < topics.length)
                          .toSet();
                      final List<_TopicItem> selectedTopics = validIndexes
                          .map((index) => topics[index])
                          .map((topic) {
                            final int questions = countsByModel[topic.id] ?? 0;
                            return topic.copyWith(
                              questions: questions,
                              credits: questions * 2,
                            );
                          })
                          .toList();
                      final int selectedCredits = selectedTopics.fold<int>(
                        0,
                        (totalCredits, topic) => totalCredits + topic.credits,
                      );
                      final bool canContinue = selectedTopics.isNotEmpty;

                      final User? user = FirebaseAuth.instance.currentUser;
                      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: user == null
                            ? null
                            : FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                        builder: (context, userSnapshot) {
                          final int currentCredits = _readCredits(userSnapshot.data?.data());
                          return SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: !canContinue
                                  ? null
                                  : () {
                                      if (currentCredits < selectedCredits) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => InsufficientCreditsScreen(
                                              requiredCredits: selectedCredits,
                                              currentCredits: currentCredits,
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final List<String> selectedModelIds = selectedTopics
                                          .map((topic) => topic.id)
                                          .toList();
                                      final String title = selectedTopics.length == 1
                                          ? selectedTopics.first.title
                                          : 'Selected Topics';
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => QuizQuestionScreen(
                                            modelId: selectedTopics.length == 1
                                                ? selectedTopics.first.id
                                                : null,
                                            modelIds: selectedModelIds,
                                            modelTitle: title,
                                          ),
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF284968),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                'Continue',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  height: 1.2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicItem {
  const _TopicItem({
    required this.id,
    required this.title,
    required this.questions,
    required this.credits,
  });

  final String id;
  final String title;
  final int questions;
  final int credits;

  _TopicItem copyWith({
    int? questions,
    int? credits,
  }) {
    return _TopicItem(
      id: id,
      title: title,
      questions: questions ?? this.questions,
      credits: credits ?? this.credits,
    );
  }

  static _TopicItem fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final String? title = (data['title'] as String?)?.trim();
    return _TopicItem(
      id: doc.id,
      title: (title == null || title.isEmpty) ? 'Untitled Model' : title,
      questions: 0,
      credits: 0,
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.selected,
    required this.onTap,
  });

  final _TopicItem topic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = selected
        ? const Color(0xFF284968)
        : const Color(0xFFFFFFFF);
    final Color titleColor = selected ? Colors.white : const Color(0xFF1F2224);
    final Color subtitleColor = selected
        ? const Color(0xFFE6EDF3)
        : const Color(0xFF6B7280);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      height: 1.2,
                      color: titleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${topic.questions} Questions  •  ${topic.credits} credits',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      height: 1.2,
                      color: subtitleColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            _SelectionIndicator(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 14,
          color: Color(0xFF284968),
        ),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF284968), width: 1.6),
      ),
    );
  }
}

int _readCredits(Map<String, dynamic>? data) {
  final dynamic value = data?['credits'] ?? data?['creditBalance'];
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}
