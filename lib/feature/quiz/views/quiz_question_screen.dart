import 'package:bu9l7y/feature/quiz/views/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum QuizQuestionType { singleChoice, multiChoice, typed }

class QuizQuestion {
  const QuizQuestion({
    required this.index,
    required this.total,
    required this.question,
    required this.type,
    this.helpText,
    this.options = const [],
    this.maxSelections,
  });

  final int index;
  final int total;
  final String question;
  final QuizQuestionType type;
  final String? helpText;
  final List<String> options;
  final int? maxSelections;
}

class QuizQuestionScreen extends StatefulWidget {
  const QuizQuestionScreen({super.key});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  final List<QuizQuestion> _questions = const [
    QuizQuestion(
      index: 1,
      total: 5,
      question:
          'Angelina buys a new printer. She wants to connect it to her home computer. Which of the following parts of the computer can she use to connect the printer to the computer?',
      type: QuizQuestionType.multiChoice,
      helpText: '. Select 3 correct answers',
      options: [
        'Option A -  Graphics card',
        'Option B -  Modem  FireWire  Parallel port',
        'Option C -  Universal serial bus',
        'Option D -  port',
      ],
      maxSelections: 3,
    ),
    QuizQuestion(
      index: 2,
      total: 5,
      question:
          'Jim creates a science project on his school computer. The project includes some documents and two graphics. He wants to work on these files on his home computer. Jim wants to use a storage device to save the project files and take them home. Which of the following devices will he use to save the files?',
      type: QuizQuestionType.multiChoice,
      helpText: '. Select all that apply',
      options: [
        'Option A -  Graphics card',
        'Option B -  Modem  FireWire  Parallel port',
        'Option C -  Universal serial bus',
        'Option D -  port',
      ],
    ),
    QuizQuestion(
      index: 3,
      total: 5,
      question: 'Arrange the storage options in the correct order from fastest to slowest.',
      type: QuizQuestionType.typed,
      helpText: 'Type the correct answer order here',
      options: [
        'Option A -  Graphics card',
        'Option B -  Modem  FireWire  Parallel port',
        'Option C -  Universal serial bus',
        'Option D -  port',
      ],
    ),
    QuizQuestion(
      index: 4,
      total: 5,
      question:
          'Jim creates a science project on his school computer. The project includes some documents and two graphics. He wants to work on these files on his home computer. Jim wants to use a storage device to save the project files and take them home. Which of the following devices will he use to save the files?',
      type: QuizQuestionType.singleChoice,
      helpText: '. Select one answer',
      options: [
        'Option A -  Graphics card',
        'Option B -  Modem  FireWire  Parallel port',
        'Option C -  Universal serial bus',
        'Option D -  port',
      ],
    ),
    QuizQuestion(
      index: 5,
      total: 5,
      question:
          'Angelina buys a new printer. She wants to connect it to her home computer. Which of the following parts of the computer can she use to connect the printer to the computer?',
      type: QuizQuestionType.multiChoice,
      helpText: '. Select 3 correct answers',
      options: [
        'Option A -  Graphics card',
        'Option B -  Modem  FireWire  Parallel port',
        'Option C -  Universal serial bus',
        'Option D -  port',
      ],
      maxSelections: 3,
    ),
  ];

  int _currentIndex = 0;
  final Map<int, int> _singleSelections = {};
  final Map<int, Set<int>> _multiSelections = {};
  final Map<int, TextEditingController> _typedControllers = {};

  @override
  void dispose() {
    for (final controller in _typedControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  QuizQuestion get _currentQuestion => _questions[_currentIndex];

  void _goNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex += 1;
      });
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const QuizResultScreen()));
  }

  void _goPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex -= 1;
      });
    }
  }

  TextEditingController _controllerFor(int index) {
    return _typedControllers.putIfAbsent(index, TextEditingController.new);
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final double progress = question.total == 0 ? 0 : question.index / question.total;

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
                    'Question ${question.index} of ${question.total}',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      height: 1,
                      color: Color(0xFF1F2224),
                      fontWeight: FontWeight.w500,
                    ),
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
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE6E6E6),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF284968)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${question.index}.  ${question.question}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        height: 1.2,
                        color: Color(0xFF1F2224),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (question.helpText != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF007AFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              question.helpText!.replaceFirst('.', '').trim(),
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                height: 1.2,
                                color: Color(0xFF007AFF),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    if (question.type != QuizQuestionType.typed) ..._buildOptionCards(question),
                    if (question.type == QuizQuestionType.typed) _buildTypedQuestion(question),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _currentIndex == 0 ? null : _goPrevious,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE6E6E6),
                                foregroundColor: const Color(0xFF3C3C43),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              child: Text(
                                'Previous',
                                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _goNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF284968),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              child: Text(
                                _currentIndex == _questions.length - 1 ? 'Submit' : 'Next',
                                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  List<Widget> _buildOptionCards(QuizQuestion question) {
    return List<Widget>.generate(question.options.length, (index) {
      final bool selected = question.type == QuizQuestionType.singleChoice
          ? _singleSelections[question.index] == index
          : (_multiSelections[question.index]?.contains(index) ?? false);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _OptionCard(
          text: question.options[index],
          selected: selected,
          onTap: () {
            setState(() {
              if (question.type == QuizQuestionType.singleChoice) {
                _singleSelections[question.index] = index;
                return;
              }
              final selections = _multiSelections.putIfAbsent(question.index, () => <int>{});
              if (selections.contains(index)) {
                selections.remove(index);
              } else {
                if (question.maxSelections == null || selections.length < question.maxSelections!) {
                  selections.add(index);
                }
              }
            });
          },
          selectedStyle: question.type == QuizQuestionType.multiChoice ? true : false,
        ),
      );
    });
  }

  Widget _buildTypedQuestion(QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.options.isNotEmpty)
          ...question.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionCard(text: option, selected: false, onTap: () {}, selectedStyle: false),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          question.helpText ?? 'Type your answer here',
          style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: Color(0xFF1F2224), fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: TextField(
            controller: _controllerFor(question.index),
            style: GoogleFonts.outfit(fontSize: 14, height: 1.2, color: Color(0xFF1F2224), fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              hintText: 'A C D B...',
              hintStyle: GoogleFonts.outfit(
                fontSize: 14,
                height: 1.2,
                color: Color(0xFFB0B0B0),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: const Color(0xFFE6E6E6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.text, required this.selected, required this.onTap, required this.selectedStyle});

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final bool selectedStyle;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected ? const Color(0xFF1E8BD7) : const Color(0xFFD3D3D3);
    final Color bgColor = selected ? const Color(0xFFEAF6FF) : const Color(0xFFFFFFFF);
    final Color iconColor = selected ? const Color(0xFF1E8BD7) : const Color(0xFFCCCCCC);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 78,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 0.5),
          boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF1E8BD7) : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: iconColor, width: 2),
              ),
              child: selected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  height: 1.2,
                  color: selected ? const Color(0xFF1E8BD7) : const Color(0xFF1F2224),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
