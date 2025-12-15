import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  int score = 0;
  late Future<List<dynamic>> questionsFuture;

  @override
  void initState() {
    super.initState();
    questionsFuture =
        SupabaseService.getQuestions(widget.categoryId);
  }

  void selectAnswer(int index, int correctIndex) {
    if (index == correctIndex) score++;

    if (currentIndex < questions.length - 1) {
      setState(() => currentIndex++);
    } else {
      _showResult();
    }
  }

  late List<dynamic> questions;

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Finished'),
        content: Text('Score: $score / ${questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context); // quiz
            },
            child: const Text('Back to Categories'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: FutureBuilder<List<dynamic>>(
        future: questionsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          questions = snapshot.data!;

          final q = questions[currentIndex];
          final answers = List<String>.from(q['answers']);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${currentIndex + 1}/${questions.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  q['question'],
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ...List.generate(answers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () =>
                          selectAnswer(index, q['correct_index']),
                      child: Text(answers[index]),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
