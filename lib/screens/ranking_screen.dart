import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchRankings();
  }

  Future<List<Map<String, dynamic>>> _fetchRankings() async {
    final response = await Supabase.instance.client
        .from('user_rankings')
        .select('rank_position, name, score')
        .order('rank_position', ascending: true)
        .limit(100);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context)!;
    final isLightTheme = themeProvider.textColor == Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Leaderboard', style: TextStyle(color: themeProvider.textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: themeProvider.textColor),
            onPressed: () async {
              setState(() => _future = _fetchRankings());
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: themeProvider.gradient),
        child: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: themeProvider.textColor));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: themeProvider.textColor.withOpacity(0.7))));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No ranking data available', style: TextStyle(color: themeProvider.textColor.withOpacity(0.7))));
              }
              final rankings = snapshot.data!;

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() => _future = _fetchRankings());
                  await _future;
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: rankings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = rankings[index];
                    final rankPos = item['rank_position']?.toString() ?? '${index + 1}';
                    return Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: isLightTheme ? Colors.white : Colors.white.withOpacity(0.08),
                      elevation: isLightTheme ? 2 : 0,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isLightTheme ? Colors.blueAccent : Colors.yellowAccent,
                          child: Text(rankPos, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(item['name'] ?? '-', style: TextStyle(fontWeight: FontWeight.w600, color: isLightTheme ? Colors.black87 : Colors.white)),
                        trailing: Text(item['score']?.toString() ?? '0', style: TextStyle(fontWeight: FontWeight.bold, color: isLightTheme ? Colors.blueAccent : Colors.yellowAccent)),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopThree(List<Map<String, dynamic>> topThree, bool isLightTheme) {
    topThree.sort((a, b) => (a['rank_position'] as int).compareTo(b['rank_position'] as int));
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (topThree.any((e) => e['rank_position'] == 2)) 
             _TopRankerCard(ranker: topThree.firstWhere((e) => e['rank_position'] == 2), height: 140, medal: '🥈', isLightTheme: isLightTheme),
          const SizedBox(width: 12),
          if (topThree.any((e) => e['rank_position'] == 1)) 
            _TopRankerCard(ranker: topThree.firstWhere((e) => e['rank_position'] == 1), height: 160, medal: '🥇', isLightTheme: isLightTheme),
          const SizedBox(width: 12),
          if (topThree.any((e) => e['rank_position'] == 3))
            _TopRankerCard(ranker: topThree.firstWhere((e) => e['rank_position'] == 3), height: 120, medal: '🥉', isLightTheme: isLightTheme),
        ],
      ),
    );
  }

  Widget _buildOthersList(List<Map<String, dynamic>> others, Color textColor, bool isLightTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
            'All Rankers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: others.length,
            itemBuilder: (context, index) {
              final item = others[index];
              return Card(
                 margin: const EdgeInsets.symmetric(vertical: 6),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 color: isLightTheme ? Colors.white : Colors.white.withOpacity(0.15),
                 elevation: isLightTheme ? 2 : 0,
                 child: ListTile(
                  leading: Text(
                    '#${item['rank_position']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isLightTheme ? Colors.grey[600] : Colors.white70),
                  ),
                  title: Text(
                    item['name'],
                    style: TextStyle(fontWeight: FontWeight.w600, color: isLightTheme ? Colors.black87 : Colors.white),
                  ),
                  trailing: Text(
                    item['score'].toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isLightTheme ? Colors.blueAccent : Colors.yellowAccent),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopRankerCard extends StatelessWidget {
  final Map<String, dynamic> ranker;
  final double height;
  final String medal;
  final bool isLightTheme;

  const _TopRankerCard({required this.ranker, required this.height, required this.medal, required this.isLightTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: 100,
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.white : Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          isLightTheme
              ? BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 10)
              : BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(medal, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            ranker['name'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            ranker['score'].toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }
}
