import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_manager.dart';
import '../services/supabase_service.dart';
import 'quiz_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<dynamic>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = SupabaseService.getCategories();
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
    final themeProvider = ThemeProvider.of(context)!;
    final isLightTheme = themeProvider.textColor == Colors.black87;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Categories', style: TextStyle(color: themeProvider.textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textColor),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: themeProvider.gradient),
        child: FutureBuilder<List<dynamic>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: themeProvider.textColor));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: themeProvider.textColor.withOpacity(0.7))));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No categories found', style: TextStyle(color: themeProvider.textColor.withOpacity(0.7))));
            }

            final categories = snapshot.data!;
            
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, topPadding + kToolbarHeight + 20, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _buildRankingCard(context, isLightTheme),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cat = categories[index];
                        final categoryName = cat['name'] ?? 'Unknown';
                        final icon = _getCategoryIcon(categoryName);
                        final color = _getCategoryColor(index);
                        return _buildCategoryCard(context, cat, categoryName, icon, color, isLightTheme);
                      },
                      childCount: categories.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildRankingCard(BuildContext context, bool isLightTheme) {
    final cardColor = isLightTheme ? Colors.white : Colors.white.withOpacity(0.95);
    final textColor = isLightTheme ? Colors.black87 : Colors.black87;
    final subtextColor = isLightTheme ? Colors.black54 : Colors.black54;

    return Card(
      elevation: isLightTheme ? 4 : 2,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const QuizScreen(isRankingMode: true),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orangeAccent.withOpacity(0.15)
                ),
                child: const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ranking Quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    Text('Compete with everyone!', style: TextStyle(color: subtextColor)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: subtextColor)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, dynamic cat, String name, IconData icon, Color color, bool isLightTheme) {
     final cardColor = isLightTheme ? Colors.white : Colors.white.withOpacity(0.9);
     final textColor = isLightTheme ? Colors.black87 : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          isLightTheme
              ? BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10)
              : BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 8),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
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
