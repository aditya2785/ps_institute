import 'package:flutter/material.dart';
import 'package:ps_institute/config/palette.dart';

class MiniQuizScreen extends StatefulWidget {
  const MiniQuizScreen({super.key});

  @override
  State<MiniQuizScreen> createState() => _MiniQuizScreenState();
}

class _MiniQuizScreenState extends State<MiniQuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "Which helps your brain remember better?",
      "options": ["Studying non-stop for hours", "Short breaks between study", "Reading very fast", "Studying while sleepy"],
      "answer": "Short breaks between study",
    },
    {
      "question": "What happens to your brain when you sleep well?",
      "options": ["It forgets everything", "It stores memories better", "It becomes slower", "Nothing changes"],
      "answer": "It stores memories better",
    },
    {
      "question": "Which study habit is scientifically proven to work best?",
      "options": [
        "Highlighting everything",
        "Re-reading notes again & again",
        "Testing yourself (practice)",
        "Studying only once"
      ],
      "answer": "Testing yourself (practice)",
    },
    {
      "question": "Why does teaching someone else help you learn?",
      "options": ["It looks cool", "Brain gets confused", "You organize ideas better", "You speak more"],
      "answer": "You organize ideas better",
    },
    {
      "question": "What is the best time for difficult learning (for most people)?",
      "options": ["Late night 🌙", "Early morning 🌅", "Right after eating 🍔", "When very tired 😴"],
      "answer": "Early morning 🌅",
    },
  ];

  void _selectAnswer(String option) {
    if (_answered) return;

    setState(() {
      _answered = true;
      if (option == _questions[_currentIndex]["answer"]) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Completed 🎉"),
        content: Text(
          "You scored $_score / ${_questions.length}\n\n"
          "${_score >= 4 ? "Excellent work! 🔥" : "Keep practicing 💪"}",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Back to Dashboard"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mini Quiz"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Progress
            Text(
              "Question ${_currentIndex + 1} of ${_questions.length}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // Question
            Text(
              current["question"],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // Options
            ...current["options"].map<Widget>((option) {
              final bool isCorrect =
                  option == current["answer"];
              final Color bgColor = !_answered
                  ? Palette.primary.withOpacity(0.08)
                  : isCorrect
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.15);

              return GestureDetector(
                onTap: () => _selectAnswer(option),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }).toList(),

            const Spacer(),

            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _answered ? _nextQuestion : null,
                child: Text(
                  _currentIndex == _questions.length - 1
                      ? "Finish Quiz"
                      : "Next Question",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
