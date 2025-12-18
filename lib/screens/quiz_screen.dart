import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_helper.dart';
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

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  static const int maxTimePerQuestion = 10;
  static const int bonusTimeLimit = 3;

  int currentIndex = 0;
  int score = 0;
  late int timeLeft;
  int? selectedAnswerIndex;
  bool answered = false;

  Timer? _timer;
  late DateTime questionStartTime;

  late Future<List<dynamic>> _questionsFuture;
  List<dynamic>? _questions; // Changed to nullable
  LinearGradient? _appGradient;
  AnimationController? _timerAnimationController;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    if (widget.isRankingMode) {
      _questionsFuture = SupabaseService.getAllQuestions(limit: 10);
    } else {
      _questionsFuture = SupabaseService.getQuestions(widget.categoryId!);
    }
  }
  
  void _loadTheme() async {
    final gradient = await ThemeHelper.getCurrentGradient();
    if (mounted) {
      setState(() { _appGradient = gradient; });
    }
  }

  void _startQuiz(List<dynamic> questions) {
    // This function will now be called safely from a post-frame callback
    setState(() {
      _questions = questions;
    });
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      timeLeft = maxTimePerQuestion;
      questionStartTime = DateTime.now();
      selectedAnswerIndex = null;
      answered = false;
    });
    _timerAnimationController = AnimationController(vsync: this, duration: const Duration(seconds: maxTimePerQuestion));
    _timerAnimationController!.reverse(from: 1.0);
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => timeLeft--);
        if (timeLeft <= 0) {
          timer.cancel();
          _nextQuestion();
        }
      }
    });
  }

  void _selectAnswer(int index) {
    if (answered) return;

    _timer?.cancel();
    _timerAnimationController?.stop();
    final isCorrect = index == _questions![currentIndex]['correct_index'];
    final elapsedSeconds = DateTime.now().difference(questionStartTime).inSeconds;

    setState(() {
      answered = true;
      selectedAnswerIndex = index;
      if (isCorrect) {
        score++;
        if (elapsedSeconds <= bonusTimeLimit) score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () => _nextQuestion());
  }

  void _nextQuestion() {
    if (currentIndex < _questions!.length - 1) {
      setState(() => currentIndex++);
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();
    _timerAnimationController?.dispose();

    if (widget.isRankingMode && score > 0) {
      final prefs = await SharedPreferences.getInstance();
      final authId = prefs.getString('authId');
      if (authId != null && !authId.startsWith('guest')) {
        await SupabaseService.addScoreToUser(authId: authId, score: score);
      }
    }
    if(mounted) _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        score: score,
        totalQuestions: _questions!.length,
        onBack: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.isRankingMode ? 'Ranking Quiz' : widget.categoryName ?? 'Quiz', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _appGradient == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(gradient: _appGradient),
              child: SafeArea(
                child: FutureBuilder<List<dynamic>>(
                  future: _questionsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.data!.isEmpty) {
                      return const Center(child: Text('No questions found', style: TextStyle(color: Colors.white)));
                    }

                    // FIX: This section is changed to prevent `setState during build` error.
                    if (_questions == null) {
                      // We use a post-frame callback to ensure _startQuiz (which calls setState) 
                      // runs *after* the build is complete.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _startQuiz(snapshot.data!);
                        }
                      });
                      // Display a loading indicator for the single frame before the callback runs.
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildProgress(),
                          const SizedBox(height: 20),
                          _buildQuestionCard(),
                          const SizedBox(height: 20),
                          ..._buildAnswerOptions(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildProgress() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question ${currentIndex + 1}/${_questions!.length}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Time: $timeLeft s', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        if (_timerAnimationController != null) 
          AnimatedBuilder(
            animation: _timerAnimationController!,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _timerAnimationController!.value,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    final question = _questions![currentIndex];
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            question['question'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnswerOptions() {
    final question = _questions![currentIndex];
    final answers = List<String>.from(question['answers']);

    return List.generate(answers.length, (index) {
      Color tileColor = Colors.white.withOpacity(0.8);
      Icon? trailingIcon;

      if (answered) {
        if (index == question['correct_index']) {
          tileColor = Colors.green.shade300;
          trailingIcon = const Icon(Icons.check_circle, color: Colors.white);
        } else if (index == selectedAnswerIndex) {
          tileColor = Colors.red.shade300;
          trailingIcon = const Icon(Icons.cancel, color: Colors.white);
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Material(
          color: tileColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _selectAnswer(index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(child: Text(answers[index], style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500))),
                  if (trailingIcon != null) trailingIcon,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _ResultDialog extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onBack;

  const _ResultDialog({required this.score, required this.totalQuestions, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.red.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Center(child: Text('Quiz Finished!', style: TextStyle(fontWeight: FontWeight.bold))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Your final score is', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          Text('$score', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          Text('/ ${totalQuestions * 2}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: onBack,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          ),
          child: const Text('Trở lại chọn chủ đề'),
        ),
      ],
    );
  }
}
