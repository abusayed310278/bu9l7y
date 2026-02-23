import 'package:bu9l7y/core/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ReviewQuestionState { correct, incorrect }

class ReviewAnswerItem {
  const ReviewAnswerItem({
    required this.title,
    required this.question,
    required this.options,
    required this.selectedIndexes,
    required this.correctIndexes,
    this.freeTextAnswer,
  });

  final String title;
  final String question;
  final List<String> options;
  final List<int> selectedIndexes;
  final List<int> correctIndexes;
  final String? freeTextAnswer;
}

class ReviewAnswersScreen extends StatelessWidget {
  const ReviewAnswersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ReviewAnswerItem> items = [
      const ReviewAnswerItem(
        title: 'Question 1',
        question:
            'Angelina buys a new printer. She wants to connect it to her home computer. Which of the following parts of the computer can she use to connect the printer to the computer?',
        options: [
          'Option A -  Graphics card',
          'Option B -  Modem  FireWire  Parallel port',
          'Option C -  Universal serial bus',
          'Option D -  port',
        ],
        selectedIndexes: [0, 1, 3],
        correctIndexes: [0, 1, 3],
      ),
      const ReviewAnswerItem(
        title: 'Question 2',
        question:
            'Angelina buys a new printer. She wants to connect it to her home computer. Which of the following parts of the computer can she use to connect the printer to the computer?',
        options: [
          'Option A -  Graphics card',
          'Option B -  Modem  FireWire  Parallel port',
          'Option C -  Universal serial bus',
          'Option D -  port',
        ],
        selectedIndexes: [0],
        correctIndexes: [1, 2, 3],
      ),
      const ReviewAnswerItem(
        title: 'Question 3',
        question:
            'Angelina buys a new printer. She wants to connect it to her home computer. Which of the following parts of the computer can she use to connect the printer to the computer?',
        options: [
          'Option A -  Graphics card',
          'Option B -  Modem  FireWire  Parallel port',
          'Option C -  Universal serial bus',
          'Option D -  port',
        ],
        selectedIndexes: const [],
        correctIndexes: const [],
        freeTextAnswer: 'B D C A',
      ),
    ];

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
                  Text(
                    'Review Answers',
                  style: GoogleFonts.outfit(fontSize: 16, height: 1, color: Color(0xFF1F2224), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return _ReviewQuestionCard(item: items[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF284968),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(
                        'Take Another Quiz',
                        style: GoogleFonts.outfit(fontSize: 16, height: 1.2, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                      label: Text(
                        'Back to home',
                        style: GoogleFonts.outfit(fontSize: 16, height: 1.2, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewQuestionCard extends StatelessWidget {
  const _ReviewQuestionCard({required this.item});

  final ReviewAnswerItem item;

  @override
  Widget build(BuildContext context) {
    final bool isTyped = item.freeTextAnswer != null;
    final bool isCorrect = _isAllCorrect();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(isCorrect ? Images.right : Images.cancel, width: 24, height: 24),
              const SizedBox(width: 8),
              Text(
                item.title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  height: 1.2,
                  color: Color(0xFF3C3C43),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.question,
            style: GoogleFonts.outfit(fontSize: 14, height: 1.2, color: Color(0xFF3C3C43), fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 10),
          if (!isTyped) ..._buildChoiceBlocks(isCorrect),
          if (isTyped) _buildTypedAnswer(isCorrect),
          const SizedBox(height: 8),
          Text(
            isCorrect ? 'Your answer is correct' : 'Incorrect Answer',
            style: GoogleFonts.outfit(
              fontSize: 14,
              height: 1.2,
              color: isCorrect ? const Color(0xFF00A63E) : const Color(0xFFFB2C36),
              fontWeight: FontWeight.w400,
            ),
          ),
          if (!isCorrect && !isTyped) ...[
            const SizedBox(height: 10),
            Text(
              'Correct Answers',
              style: GoogleFonts.outfit(fontSize: 14, height: 1.2, color: Color(0xFF00C950), fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8),
            ..._buildCorrectBlocks(),
          ],
        ],
      ),
    );
  }

  bool _isAllCorrect() {
    if (item.freeTextAnswer != null) {
      return true;
    }
    if (item.selectedIndexes.length != item.correctIndexes.length) {
      return false;
    }
    for (final index in item.selectedIndexes) {
      if (!item.correctIndexes.contains(index)) {
        return false;
      }
    }
    return true;
  }

  List<Widget> _buildChoiceBlocks(bool isCorrect) {
    return List<Widget>.generate(item.options.length, (index) {
      final bool isSelected = item.selectedIndexes.contains(index);
      if (!isSelected) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _AnswerPill(text: item.options[index], state: AnswerState.neutral),
        );
      }

      final bool correctChoice = item.correctIndexes.contains(index);
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _AnswerPill(text: item.options[index], state: correctChoice ? AnswerState.correct : AnswerState.incorrect),
      );
    });
  }

  Widget _buildTypedAnswer(bool isCorrect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...item.options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AnswerPill(text: option, state: AnswerState.neutral),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Correct Answer',
          style: GoogleFonts.outfit(fontSize: 14, height: 1.2, color: Color(0xFF00C950), fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 6),
        Container(
          height: 34,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8FFF0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2BB673), width: 1),
          ),
          child: Text(
            item.freeTextAnswer!,
            style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: Color(0xFF2BB673), fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCorrectBlocks() {
    return List<Widget>.generate(item.options.length, (index) {
      if (!item.correctIndexes.contains(index)) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _AnswerPill(text: item.options[index], state: AnswerState.correct),
      );
    });
  }
}

enum AnswerState { neutral, correct, incorrect }

class _AnswerPill extends StatelessWidget {
  const _AnswerPill({required this.text, required this.state});

  final String text;
  final AnswerState state;

  @override
  Widget build(BuildContext context) {
    Color border;
    Color background;
    Color textColor;
    bool showCorrectIcon = false;
    bool showIncorrectIcon = false;

    switch (state) {
      case AnswerState.correct:
        border = const Color(0xFF2BB673);
        background = const Color(0xFFE8FFF0);
        textColor = const Color(0xFF2BB673);
        showCorrectIcon = true;
        break;
      case AnswerState.incorrect:
        border = const Color(0xFFFF3B30);
        background = const Color(0xFFFFE8E8);
        textColor = const Color(0xFFFF3B30);
        showIncorrectIcon = true;
        break;
      case AnswerState.neutral:
        border = const Color(0xFFE6E6E6);
        background = Colors.white;
        textColor = const Color(0xFF1F2224);
        break;
    }

    return Container(
      height: 56,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        children: [
          if (showCorrectIcon)
            Image.asset(
              Images.right,
              width: 24,
              height: 24,
            ),
          if (showCorrectIcon) const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(fontSize: 14, height: 1.2, color: textColor, fontWeight: FontWeight.w400),
            ),
          ),
          if (showIncorrectIcon) ...[
            const SizedBox(width: 10),
            Image.asset(
              Images.cancel,
              width: 20,
              height: 20,
            ),
          ],
        ],
      ),
    );
  }
}
