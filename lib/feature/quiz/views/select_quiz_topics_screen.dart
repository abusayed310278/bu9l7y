import 'package:flutter/material.dart';

class SelectQuizTopicsScreen extends StatefulWidget {
  const SelectQuizTopicsScreen({super.key});

  @override
  State<SelectQuizTopicsScreen> createState() => _SelectQuizTopicsScreenState();
}

class _SelectQuizTopicsScreenState extends State<SelectQuizTopicsScreen> {
  int _selectedIndex = 0;

  final List<_TopicItem> _topics = const [
    _TopicItem(title: 'Computer Basics', questions: 60, credits: 120),
    _TopicItem(title: 'Security and Privacy', questions: 40, credits: 80),
    _TopicItem(title: 'Digital Lifestyles', questions: 30, credits: 60),
    _TopicItem(title: 'Productivity Software', questions: 40, credits: 80),
    _TopicItem(title: 'The Internet', questions: 60, credits: 120),
  ];

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
                    'Select Quiz Topics',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 16, height: 1, color: Color(0xFF1F2224), fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: const Color(0xFF1E8BD7)),
                    child: const Text(
                      'See all',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 12, height: 1, fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _topics.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final topic = _topics[index];
                  final bool selected = index == _selectedIndex;
                  return _TopicCard(
                    topic: topic,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
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
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 16, height: 1.2, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicItem {
  const _TopicItem({required this.title, required this.questions, required this.credits});

  final String title;
  final int questions;
  final int credits;
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.selected, required this.onTap});

  final _TopicItem topic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = selected ? const Color(0xFF284968) : const Color(0xFFFFFFFF);
    final Color titleColor = selected ? Colors.white : const Color(0xFF1F2224);
    final Color subtitleColor = selected ? const Color(0xFFE6EDF3) : const Color(0xFF6B7280);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 16, height: 1.2, color: titleColor, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${topic.questions} Questions  •  ${topic.credits} credits',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 12, height: 1.2, color: subtitleColor, fontWeight: FontWeight.w400),
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
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, size: 14, color: Color(0xFF284968)),
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
