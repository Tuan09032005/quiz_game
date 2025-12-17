import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

class QuizScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final bool isRankingMode;

  const QuizScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.isRankingMode = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int maxTimePerQuestion = 10; // ⏱ 10s
  static const int bonusTimeLimit = 3;      // ⚡ 3s bonus

  int currentIndex = 0;
  int score = 0;
  int timeLeft = maxTimePerQuestion;

  Timer? _timer;
  late DateTime questionStartTime;

  late Future<List<dynamic>> questionsFuture;
  late List<dynamic> questions;

  @override
  void initState() {
    super.initState();

    if (widget.isRankingMode) {
      questionsFuture = SupabaseService.getAllQuestions(limit: 10);
    } else {
      questionsFuture =
          SupabaseService.getQuestions(widget.categoryId!);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    timeLeft = maxTimePerQuestion;
    questionStartTime = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
      });

      if (timeLeft <= 0) {
        timer.cancel();
        _nextQuestion(); // hết giờ → sang câu
      }
    });
  }

  void selectAnswer(int index, int correctIndex) {
    _timer?.cancel();

    final elapsedSeconds =
        DateTime.now().difference(questionStartTime).inSeconds;

    if (index == correctIndex) {
      score += 1;

      // ⚡ bonus nếu trả lời <= 3s
      if (elapsedSeconds <= bonusTimeLimit) {
        score += 1;
      }
    }

    _nextQuestion();
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();

    if (widget.isRankingMode && score > 0) {
      final prefs = await SharedPreferences.getInstance();
      final authId = prefs.getString('authId');

      if (authId != null && !authId.startsWith('guest')) {
        await SupabaseService.addScoreToUser(
          authId: authId,
          score: score,
        );
      }
    }

    _showResult();
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Finished'),
        content: Text(
          widget.isRankingMode
              ? 'Your score: $score'
              : 'Score: $score / ${questions.length * 2}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isRankingMode
              ? 'Ranking Quiz'
              : widget.categoryName ?? 'Quiz',
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: questionsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          questions = snapshot.data!;

          if (questions.isEmpty) {
            return const Center(child: Text('No questions found'));
          }

          final q = questions[currentIndex];
          final answers = List<String>.from(q['answers']);

          // chỉ start timer khi render câu đầu
          if (_timer == null || timeLeft == maxTimePerQuestion) {
            _startTimer();
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⏱ TIME BAR
                LinearProgressIndicator(
                  value: timeLeft / maxTimePerQuestion,
                  minHeight: 8,
                ),
                const SizedBox(height: 12),

                Text(
                  'Time left: $timeLeft s',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),

                Text(
                  'Question ${currentIndex + 1}/${questions.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),

                Text(
                  q['question'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
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
