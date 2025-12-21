import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_manager.dart';
import 'package:quiz_game/services/audio_service.dart';
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

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
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
  List<dynamic>? _questions;
  AnimationController? _timerAnimationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioService.playBgm();

    if (widget.isRankingMode) {
      _questionsFuture = SupabaseService.getAllQuestions(limit: 10);
    } else {
      _questionsFuture = SupabaseService.getQuestions(widget.categoryId!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnimationController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    AudioService.stopBgm();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioService.pauseBgm();
    } else if (state == AppLifecycleState.resumed) {
      AudioService.resumeBgm();
    }
  }

  void _startQuiz(List<dynamic> questions) {
    setState(() => _questions = questions);
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      timeLeft = maxTimePerQuestion;
      questionStartTime = DateTime.now();
      selectedAnswerIndex = null;
      answered = false;
    });

    _timerAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: maxTimePerQuestion));
    _timerAnimationController!.reverse(from: 1.0);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => timeLeft--);
      if (timeLeft <= 0) {
        timer.cancel();
        _nextQuestion();
      }
    });
  }

  void _selectAnswer(int index) {
    if (answered) return;

    AudioService.playButtonSound();
    _timer?.cancel();
    _timerAnimationController?.stop();

    final isCorrect = index == _questions![currentIndex]['correct_index'];
    final elapsedSeconds =
        DateTime.now().difference(questionStartTime).inSeconds;

    setState(() {
      answered = true;
      selectedAnswerIndex = index;

      if (isCorrect) {
        score++;
        if (elapsedSeconds <= bonusTimeLimit) score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), _nextQuestion);
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
    bool wasScoreSubmitted = false;

    if (widget.isRankingMode && score > 0) {
      final prefs = await SharedPreferences.getInstance();
      final authId = prefs.getString('authId');
      final isGuest = prefs.getBool('isGuest') ?? true;

      if (authId != null && !isGuest) {
        await SupabaseService.addScoreToUser(authId: authId, score: score);
        wasScoreSubmitted = true;
      }
    }

    if (!mounted) return;
    _showResultDialog(wasScoreSubmitted);
  }

  void _showResultDialog(bool wasScoreSubmitted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        score: score,
        totalQuestions: _questions!.length,
        isRankingMode: widget.isRankingMode,
        wasScoreSubmitted: wasScoreSubmitted,
        onBack: () async {
          await AudioService.playButtonSound();
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.isRankingMode
              ? 'Ranking Quiz'
              : widget.categoryName ?? 'Quiz',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeProvider.gradient),
        child: SafeArea(
          child: FutureBuilder<List<dynamic>>(
            future: _questionsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              if (snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No questions found',
                        style: TextStyle(color: Colors.white)));
              }

              if (_questions == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _startQuiz(snapshot.data!);
                });
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
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
            Text(
              'Question ${currentIndex + 1}/${_questions!.length}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              'Time: $timeLeft s',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
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
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
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
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
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
          trailingIcon =
              const Icon(Icons.check_circle, color: Colors.white);
        } else if (index == selectedAnswerIndex) {
          tileColor = Colors.red.shade300;
          trailingIcon =
              const Icon(Icons.cancel, color: Colors.white);
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      answers[index],
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
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
  final bool isRankingMode;
  final bool wasScoreSubmitted;

  const _ResultDialog({
    required this.score,
    required this.totalQuestions,
    required this.onBack,
    required this.isRankingMode,
    required this.wasScoreSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    String title = 'Quiz Finished!';
    List<Widget> contentChildren = [
      Text('Your score is',
          style: TextStyle(fontSize: 18, color: Colors.grey[800])),
      const SizedBox(height: 16),
      Text('$score',
          style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent)),
    ];

    if (isRankingMode) {
      title = 'Ranking Quiz Finished!';
      if (wasScoreSubmitted) {
        contentChildren.addAll([
          const SizedBox(height: 8),
          const Text(
            'Your score has been submitted to the leaderboard!',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w600),
          ),
        ]);
      } else if (score <= 0) {
        contentChildren.addAll([
          const SizedBox(height: 8),
          Text(
            'You need a score greater than 0 to be ranked.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: Colors.orange,
                fontWeight: FontWeight.w600),
          ),
        ]);
      } else {
        contentChildren.addAll([
          const SizedBox(height: 8),
          const Text(
            'Sign in to submit your score to the leaderboard.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: Colors.orange,
                fontWeight: FontWeight.w600),
          ),
        ]);
      }
    } else {
      contentChildren.add(Text(
        '/ ${totalQuestions * 2}',
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ));
    }

    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Center(
          child: Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: contentChildren,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: onBack,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          ),
          child: const Text('Trở lại chọn chủ đề'),
        ),
      ],
    );
  }
}
