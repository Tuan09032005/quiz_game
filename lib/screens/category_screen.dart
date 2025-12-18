
import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_helper.dart';
import '../services/supabase_service.dart';
import 'quiz_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<dynamic>> _categoriesFuture;
  LinearGradient? _headerGradient;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = SupabaseService.getCategories();
    _loadTheme();
  }

  void _loadTheme() async {
    final gradient = await ThemeHelper.getCurrentGradient();
    if (mounted) {
      setState(() {
        _headerGradient = gradient;
      });
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('science')) return Icons.science_rounded;
    if (name.contains('history')) return Icons.history_edu_rounded;
    if (name.contains('geography')) return Icons.public_rounded;
    if (name.contains('sport')) return Icons.sports_soccer_rounded;
    if (name.contains('music')) return Icons.music_note_rounded;
    if (name.contains('movie') || name.contains('film')) return Icons.movie_rounded;
    if (name.contains('tech')) return Icons.computer_rounded;
    if (name.contains('math')) return Icons.calculate_rounded;
    if (name.contains('art')) return Icons.palette_rounded;
    if (name.contains('animal')) return Icons.pets_rounded;
    if (name.contains('general')) return Icons.lightbulb_rounded;
    return Icons.category_rounded;
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.pinkAccent,
      Colors.indigoAccent,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _headerGradient == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: _headerGradient,
              ),
              child: FutureBuilder<List<dynamic>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No categories found', style: const TextStyle(color: Colors.white70)));
                  }

                  final categories = snapshot.data!;
                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(20, topPadding + kToolbarHeight + 20, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final categoryName = cat['name'] ?? 'Unknown';
                      final icon = _getCategoryIcon(categoryName);
                      final color = _getCategoryColor(index);
                      return _buildCategoryCard(context, cat, categoryName, icon, color);
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, dynamic cat, String name, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizScreen(
                  categoryId: cat['id'],
                  categoryName: name,
                  isRankingMode: false,
                ),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
