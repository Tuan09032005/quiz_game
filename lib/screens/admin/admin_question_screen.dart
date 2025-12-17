import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class AdminQuestionScreen extends StatefulWidget {
  const AdminQuestionScreen({super.key});

  @override
  State<AdminQuestionScreen> createState() => _AdminQuestionScreenState();
}

class _AdminQuestionScreenState extends State<AdminQuestionScreen> {
  late Future<List<dynamic>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = SupabaseService.getCategories();
  }
  void _showAddQuestionDialog(String categoryId) {
    final questionCtrl = TextEditingController();
    final answerCtrls = List.generate(4, (_) => TextEditingController());
    int correctIndex = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Add Question'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: questionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                  ),
                ),
                const SizedBox(height: 12),

                ...List.generate(4, (i) {
                  return Row(
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: correctIndex,
                        onChanged: (v) {
                          correctIndex = v!;
                          setStateDialog(() {});
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: answerCtrls[i],
                          decoration: InputDecoration(
                            labelText: 'Answer ${i + 1}',
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final question = questionCtrl.text.trim();
                final answers =
                    answerCtrls.map((e) => e.text.trim()).toList();

                if (question.isEmpty || answers.any((a) => a.isEmpty)) {
                  return;
                }

                await SupabaseService.addQuestion(
                  categoryId: categoryId,
                  question: question,
                  answers: answers,
                  correctIndex: correctIndex,
                );

                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditQuestionDialog(Map<String, dynamic> q) {
    final questionCtrl = TextEditingController(text: q['question'] ?? '');
    final answersList = List<String>.from(q['answers'] ?? []);
    final answerCtrls = List.generate(4, (i) {
      return TextEditingController(text: i < answersList.length ? answersList[i] : '');
    });
    int correctIndex = q['correct_index'] ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Edit Question'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: questionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(4, (i) {
                  return Row(
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: correctIndex,
                        onChanged: (v) {
                          correctIndex = v!;
                          setStateDialog(() {});
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: answerCtrls[i],
                          decoration: InputDecoration(
                            labelText: 'Answer ${i + 1}',
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final question = questionCtrl.text.trim();
                final answers =
                    answerCtrls.map((e) => e.text.trim()).toList();

                if (question.isEmpty || answers.any((a) => a.isEmpty)) {
                  return;
                }

                await SupabaseService.updateQuestion(
                  questionId: q['id'].toString(),
                  question: question,
                  answers: answers,
                  correctIndex: correctIndex,
                );

                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteQuestion(String questionId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok == true) {
      await SupabaseService.deleteQuestion(questionId: questionId);
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Questions')),
      body: FutureBuilder<List<dynamic>>(
        future: _categories,
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cats = snapshot.data!;
          return ListView.builder(
            itemCount: cats.length,
            itemBuilder: (_, i) {
              final c = cats[i];
              return ExpansionTile(
                key: ValueKey(c['id']),
                title: Text(c['name'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddQuestionDialog(c['id'].toString()),
                ),
                children: [
                  FutureBuilder<List<dynamic>>(
                    future: SupabaseService.getQuestions(c['id'].toString()),
                    builder: (_, qsnap) {
                      if (!qsnap.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final questions = qsnap.data!;
                      if (questions.isEmpty) {
                        return const ListTile(
                          title: Text('No questions'),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: questions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, qi) {
                          final q = Map<String, dynamic>.from(questions[qi]);
                          final answers = List<String>.from(q['answers'] ?? []);
                          final correct = q['correct_index'] ?? 0;

                          return ListTile(
                            title: Text(q['question'] ?? ''),
                            subtitle: Text(
                              answers.asMap().entries.map((e) {
                                final idx = e.key;
                                final text = e.value;
                                return '${idx + 1}. ${text}${idx == correct ? " (✓)" : ""}';
                              }).join('\n'),
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditQuestionDialog(q),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _confirmDeleteQuestion(q['id'].toString()),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
