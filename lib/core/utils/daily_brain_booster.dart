class BrainBoosterQuestion {
  final String question;
  final String answer;
  final String explanation;

  const BrainBoosterQuestion({
    required this.question,
    required this.answer,
    required this.explanation,
  });
}

class DailyBrainBooster {
  // 🔹 Add as many questions as you want here
  static const List<BrainBoosterQuestion> _questions = [
    BrainBoosterQuestion(
      question: "What is the time complexity of binary search?",
      answer: "O(log n)",
      explanation:
          "Binary search halves the search space each time, leading to logarithmic time complexity.",
    ),
    BrainBoosterQuestion(
      question: "Which data structure follows FIFO?",
      answer: "Queue",
      explanation:
          "FIFO means First In First Out, which is the defining behavior of a queue.",
    ),
    BrainBoosterQuestion(
      question: "What does the keyword 'final' mean in Dart?",
      answer: "Value cannot be reassigned",
      explanation:
          "A final variable can be set only once, but its value may still be mutable if it's an object.",
    ),
    BrainBoosterQuestion(
      question: "Which algorithm is used to find the shortest path in a graph?",
      answer: "Dijkstra’s Algorithm",
      explanation:
          "Dijkstra’s algorithm finds the shortest path from a source node to all other nodes with non-negative weights.",
    ),
    BrainBoosterQuestion(
      question: "What is the output of: print(2 + 3 * 4);",
      answer: "14",
      explanation:
          "Multiplication has higher precedence than addition, so 3 * 4 is evaluated first.",
    ),
    BrainBoosterQuestion(
      question: "What does API stand for?",
      answer: "Application Programming Interface",
      explanation:
          "An API allows different software applications to communicate with each other.",
    ),
    BrainBoosterQuestion(
      question: "Which traversal is used in BFS?",
      answer: "Level-order traversal",
      explanation:
          "Breadth First Search explores nodes level by level using a queue.",
    ),
    BrainBoosterQuestion(
      question: "What is the main purpose of normalization in databases?",
      answer: "Reduce data redundancy",
      explanation:
          "Normalization organizes data to minimize duplication and improve integrity.",
    ),
  ];

  /// Returns today's brain booster question
  /// Same question for everyone on the same day
  static BrainBoosterQuestion getTodayQuestion() {
    final today = DateTime.now();

    // Create a stable index based on date
    final index =
        (today.year + today.month + today.day) % _questions.length;

    return _questions[index];
  }
}
