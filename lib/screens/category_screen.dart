import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'quiz_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<dynamic>> categoriesFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = SupabaseService.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Category')),
      body: FutureBuilder<List<dynamic>>(
        future: categoriesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!;

          return ListView(
            children: [
              // 🔥 RANKING QUIZ CARD
              Card(
                margin: const EdgeInsets.all(12),
                color: Colors.orange.shade100,
                child: ListTile(
                  leading: const Icon(Icons.flash_on, color: Colors.orange),
                  title: const Text(
                    '🔥 Ranking Quiz',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle:
                      const Text('All categories • Competitive mode'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuizScreen(
                          isRankingMode: true,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 📚 CATEGORY LIST
              ...categories.map((cat) {
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(cat['name']),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            categoryId: cat['id'],
                            categoryName: cat['name'],
                            isRankingMode: false,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
