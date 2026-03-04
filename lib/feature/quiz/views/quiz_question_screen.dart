import 'dart:math';

import 'package:bu9l7y/feature/quiz/views/quiz_result_screen.dart';
import 'package:bu9l7y/feature/quiz/views/review_answers_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum QuizQuestionType { singleChoice, multiChoice, typed, chooseOrder }

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.helpText,
    this.imageUrl,
    this.options = const [],
    this.optionIds = const [],
    this.maxSelections,
    this.correctIndexes = const [],
    this.correctText,
  });

  final String id;
  final String question;
  final QuizQuestionType type;
  final String? helpText;
  final String? imageUrl;
  final List<String> options;
  final List<String> optionIds;
  final int? maxSelections;
  final List<int> correctIndexes;
  final String? correctText;

  static QuizQuestion fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final String rawType = (data['questionType'] as String? ?? '')
        .trim()
        .toLowerCase();
    final QuizQuestionType type = switch (rawType) {
      'single_choice' => QuizQuestionType.singleChoice,
      'multi_choice' || 'multiple_choice' => QuizQuestionType.multiChoice,
      'typed' || 'text' || 'text_input' => QuizQuestionType.typed,
      'choose_order' => QuizQuestionType.chooseOrder,
      _ => QuizQuestionType.singleChoice,
    };

    final List<_ParsedOption> parsedOptions = _parseOptions(data['answerOptions']);
    final List<String> options = parsedOptions.map((o) => o.text).toList();
    final List<String> optionIds = parsedOptions.map((o) => o.id).toList();
    final dynamic correctAnswer = data['correctAnswer'];
    final List<int> correctIndexes = _parseCorrectIndexes(
      type: type,
      optionIds: optionIds,
      correctAnswer: correctAnswer,
    );
    final int? maxSelections = _parseMaxSelections(type, correctAnswer, correctIndexes);
    final String? helpText = _buildHelpText(type, maxSelections);
    final String? correctText = _parseCorrectText(type, correctAnswer);

    return QuizQuestion(
      id: doc.id,
      question: (data['title'] as String?)?.trim().isNotEmpty == true
          ? (data['title'] as String).trim()
          : 'Untitled question',
      type: type,
      helpText: helpText,
      imageUrl: (data['imageUrl'] as String?)?.trim(),
      options: options,
      optionIds: optionIds,
      maxSelections: maxSelections,
      correctIndexes: correctIndexes,
      correctText: correctText,
    ).withShuffledOptions();
  }

  QuizQuestion withShuffledOptions() {
    if (type != QuizQuestionType.singleChoice && type != QuizQuestionType.multiChoice) {
      return this;
    }
    if (options.length < 2 || optionIds.length != options.length) {
      return this;
    }

    final List<int> oldIndexes = List<int>.generate(options.length, (i) => i)
      ..shuffle(Random());
    final List<String> shuffledOptions = oldIndexes.map((i) => options[i]).toList();
    final List<String> shuffledOptionIds = oldIndexes.map((i) => optionIds[i]).toList();
    final Map<int, int> newIndexByOldIndex = <int, int>{
      for (int newIndex = 0; newIndex < oldIndexes.length; newIndex++)
        oldIndexes[newIndex]: newIndex,
    };
    final List<int> shuffledCorrectIndexes = correctIndexes
        .map((oldIndex) => newIndexByOldIndex[oldIndex])
        .whereType<int>()
        .toList()
      ..sort();

    return QuizQuestion(
      id: id,
      question: question,
      type: type,
      helpText: helpText,
      imageUrl: imageUrl,
      options: shuffledOptions,
      optionIds: shuffledOptionIds,
      maxSelections: maxSelections,
      correctIndexes: shuffledCorrectIndexes,
      correctText: correctText,
    );
  }

  static List<_ParsedOption> _parseOptions(dynamic raw) {
    if (raw is! List) {
      return <_ParsedOption>[];
    }
    final List<_ParsedOption> items = <_ParsedOption>[];
    for (int i = 0; i < raw.length; i++) {
      final dynamic item = raw[i];
      if (item is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        final String text = (map['text'] as String?)?.trim() ?? '';
        if (text.isEmpty) continue;
        final String id = (map['id'] as String?)?.trim().toUpperCase() ??
            String.fromCharCode(65 + i);
        final int order = _readInt(map['order'], i);
        items.add(_ParsedOption(id: id, text: text, order: order));
      }
    }
    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  static List<int> _parseCorrectIndexes({
    required QuizQuestionType type,
    required List<String> optionIds,
    required dynamic correctAnswer,
  }) {
    if (type == QuizQuestionType.typed || type == QuizQuestionType.chooseOrder) {
      return <int>[];
    }

    final List<String> tokens = <String>[];
    if (correctAnswer is String) {
      final String normalized = correctAnswer
          .replaceAll('[', '')
          .replaceAll(']', '')
          .trim();
      tokens.addAll(
        normalized
            .split(RegExp(r'[\s,;/|]+'))
            .map((e) => e.trim().toUpperCase())
            .where((e) => e.isNotEmpty),
      );
    } else if (correctAnswer is List) {
      for (final dynamic item in correctAnswer) {
        final String token = item.toString().trim().toUpperCase();
        if (token.isNotEmpty) {
          tokens.add(token);
        }
      }
    }

    final List<int> indexes = <int>[];
    for (final String token in tokens) {
      final int idx = optionIds.indexOf(token);
      if (idx >= 0 && !indexes.contains(idx)) {
        indexes.add(idx);
      }
    }
    return indexes;
  }

  static int? _parseMaxSelections(
    QuizQuestionType type,
    dynamic correctAnswer,
    List<int> correctIndexes,
  ) {
    if (type != QuizQuestionType.multiChoice) {
      return null;
    }
    if (correctIndexes.length > 1) {
      return correctIndexes.length;
    }
    if (correctAnswer is List) {
      return correctAnswer.length;
    }
    return null;
  }

  static String? _parseCorrectText(QuizQuestionType type, dynamic correctAnswer) {
    if (type != QuizQuestionType.typed && type != QuizQuestionType.chooseOrder) {
      return null;
    }
    if (correctAnswer == null) {
      return null;
    }
    if (correctAnswer is List) {
      return correctAnswer.map((e) => e.toString().trim()).join(' ').trim();
    }
    return correctAnswer.toString().trim();
  }

  static String? _buildHelpText(QuizQuestionType type, int? maxSelections) {
    return switch (type) {
      QuizQuestionType.singleChoice => 'Select one answer',
      QuizQuestionType.multiChoice => maxSelections != null && maxSelections > 1
          ? 'Select $maxSelections correct answers'
          : 'Select all that apply',
      QuizQuestionType.typed => 'Type your answer',
      QuizQuestionType.chooseOrder => 'Select all that apply',
    };
  }

  static int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }
}

class QuizQuestionScreen extends StatefulWidget {
  const QuizQuestionScreen({
    super.key,
    this.modelId,
    this.modelIds,
    this.modelTitle,
  });

  final String? modelId;
  final List<String>? modelIds;
  final String? modelTitle;

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  List<QuizQuestion> _questions = <QuizQuestion>[];
  bool _isLoading = true;
  String? _errorMessage;

  int _currentIndex = 0;
  final Map<int, int> _singleSelections = {};
  final Map<int, Set<int>> _multiSelections = {};
  final Map<int, TextEditingController> _typedControllers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    for (final controller in _typedControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  QuizQuestion get _currentQuestion => _questions[_currentIndex];

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('questions');
      final String selectedModelId = (widget.modelId ?? '').trim();
      final Set<String> selectedModelIds = (widget.modelIds ?? <String>[])
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toSet();
      if (selectedModelId.isNotEmpty) {
        query = query.where('modelId', isEqualTo: selectedModelId);
      } else if (selectedModelIds.length == 1) {
        query = query.where('modelId', isEqualTo: selectedModelIds.first);
      }
      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      final Iterable<DocumentSnapshot<Map<String, dynamic>>> filteredDocs =
          selectedModelIds.isEmpty || selectedModelId.isNotEmpty
          ? snapshot.docs
          : snapshot.docs.where((doc) {
              final String modelId = (doc.data()['modelId'] as String? ?? '').trim();
              return selectedModelIds.contains(modelId);
            });
      final List<QuizQuestion> loaded = filteredDocs
          .map(QuizQuestion.fromDoc)
          .where((q) =>
              q.options.isNotEmpty ||
              q.type == QuizQuestionType.typed ||
              q.type == QuizQuestionType.chooseOrder)
          .toList();
      if (!mounted) return;
      setState(() {
        _questions = loaded;
        _currentIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load quiz questions.';
        _isLoading = false;
      });
    }
  }

  Future<void> _goNext() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex += 1;
      });
      return;
    }
    final List<ReviewAnswerItem> reviewItems = _buildReviewItems();
    final int correctCount = _calculateCorrectCount();
    await _saveAttempt(correctCount: correctCount);
    if (!mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizResultScreen(
          totalQuestions: _questions.length,
          correctAnswers: correctCount,
          topicTitle: (widget.modelTitle ?? '').trim().isNotEmpty
              ? widget.modelTitle!.trim()
              : 'Selected Model',
          reviewItems: reviewItems,
        ),
      ),
    );
  }

  Future<void> _saveAttempt({required int correctCount}) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    final int total = _questions.length;
    if (total == 0) {
      return;
    }
    final double scorePercent = (correctCount / total) * 100;

    final DocumentReference<Map<String, dynamic>> attemptRef = FirebaseFirestore
        .instance
        .collection('users')
        .doc(user.uid)
        .collection('quizAttempts')
        .doc();

    final String topicTitle = (widget.modelTitle ?? '').trim().isNotEmpty
        ? widget.modelTitle!.trim()
        : 'Selected Model';

    await attemptRef.set({
      'modelId': (widget.modelId ?? '').trim(),
      'topicTitle': topicTitle,
      'totalQuestions': total,
      'correctAnswers': correctCount,
      'scorePercent': scorePercent,
      'createdAt': FieldValue.serverTimestamp(),
    });
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

  List<int> _selectedIndexesForQuestion(int index, QuizQuestion question) {
    if (question.type == QuizQuestionType.singleChoice) {
      final int? selected = _singleSelections[index];
      return selected == null ? <int>[] : <int>[selected];
    }
    if (question.type == QuizQuestionType.multiChoice) {
      return (_multiSelections[index] ?? <int>{}).toList()..sort();
    }
    return <int>[];
  }

  bool _isQuestionCorrect(int index, QuizQuestion question) {
    if (question.type == QuizQuestionType.typed) {
      final String userText = (_typedControllers[index]?.text ?? '')
          .trim()
          .toLowerCase();
      final String correctText = (question.correctText ?? '')
          .trim()
          .toLowerCase();
      return userText.isNotEmpty && correctText.isNotEmpty && userText == correctText;
    }
    if (question.type == QuizQuestionType.chooseOrder) {
      final String userOrder = _normalizeOrderAnswer(
        (_typedControllers[index]?.text ?? ''),
      );
      final String correctOrder = _normalizeOrderAnswer(question.correctText ?? '');
      return userOrder.isNotEmpty &&
          correctOrder.isNotEmpty &&
          userOrder == correctOrder;
    }
    final List<int> selected = _selectedIndexesForQuestion(index, question);
    if (selected.length != question.correctIndexes.length) return false;
    for (final int idx in selected) {
      if (!question.correctIndexes.contains(idx)) return false;
    }
    return true;
  }

  int _calculateCorrectCount() {
    int count = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_isQuestionCorrect(i, _questions[i])) {
        count += 1;
      }
    }
    return count;
  }

  List<ReviewAnswerItem> _buildReviewItems() {
    final List<ReviewAnswerItem> items = <ReviewAnswerItem>[];
    for (int i = 0; i < _questions.length; i++) {
      final QuizQuestion q = _questions[i];
      final List<int> selected = _selectedIndexesForQuestion(i, q);
      items.add(
        ReviewAnswerItem(
          title: 'Question ${i + 1}',
          question: q.question,
          options: q.options,
          selectedIndexes: selected,
          correctIndexes: q.correctIndexes,
          freeTextAnswer:
              q.type == QuizQuestionType.typed ||
                  q.type == QuizQuestionType.chooseOrder
              ? (_typedControllers[i]?.text ?? '').trim()
              : null,
          correctTextAnswer: q.type == QuizQuestionType.chooseOrder
              ? _normalizeOrderAnswer(q.correctText ?? '')
              : q.correctText,
        ),
      );
    }
    return items;
  }

  String _normalizeOrderAnswer(String value) {
    return value
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_errorMessage!),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: _loadQuestions, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }
    if (_questions.isEmpty) {
      return const Scaffold(
        body: SafeArea(child: Center(child: Text('No questions available.'))),
      );
    }

    final question = _currentQuestion;
    final int questionNumber = _currentIndex + 1;
    final int totalQuestions = _questions.length;
    final double progress = totalQuestions == 0 ? 0 : questionNumber / totalQuestions;

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
                    'Question $questionNumber of $totalQuestions',
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
                      '$questionNumber.  ${question.question}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        height: 1.2,
                        color: Color(0xFF1F2224),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if ((question.imageUrl ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          question.imageUrl!.trim(),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ],
                    if (question.helpText != null && question.helpText!.trim().isNotEmpty) ...[
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
                              question.helpText!.trim(),
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
                    if (question.type == QuizQuestionType.singleChoice ||
                        question.type == QuizQuestionType.multiChoice)
                      ..._buildOptionCards(question),
                    if (question.type == QuizQuestionType.typed ||
                        question.type == QuizQuestionType.chooseOrder)
                      _buildTypedQuestion(question),
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
          ? _singleSelections[_currentIndex] == index
          : (_multiSelections[_currentIndex]?.contains(index) ?? false);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _OptionCard(
          text: question.options[index],
          selected: selected,
          onTap: () {
            setState(() {
              if (question.type == QuizQuestionType.singleChoice) {
                _singleSelections[_currentIndex] = index;
                return;
              }
              final selections = _multiSelections.putIfAbsent(_currentIndex, () => <int>{});
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
              child: _OptionCard(
                text: option,
                selected: false,
                onTap: () {},
                selectedStyle: false,
                showSelectionIndicator: false,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          question.type == QuizQuestionType.chooseOrder
              ? 'Type the correct answer order here'
              : (question.helpText ?? 'Type your answer here'),
          style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: Color(0xFF1F2224), fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: TextField(
            controller: _controllerFor(_currentIndex),
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
  const _OptionCard({
    required this.text,
    required this.selected,
    required this.onTap,
    required this.selectedStyle,
    this.showSelectionIndicator = true,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final bool selectedStyle;
  final bool showSelectionIndicator;

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
            if (showSelectionIndicator) ...[
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
            ],
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

class _ParsedOption {
  const _ParsedOption({
    required this.id,
    required this.text,
    required this.order,
  });

  final String id;
  final String text;
  final int order;
}
