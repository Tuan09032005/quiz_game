import 'package:flutter/material.dart';
import 'package:quiz_game/helpers/theme_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
   LinearGradient? _appGradient;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    final gradient = await ThemeHelper.getCurrentGradient();
    if (mounted) {
      setState(() {
        _appGradient = gradient;
      });
    }
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _appGradient == null 
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(gradient: _appGradient),
              child: SafeArea(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchRankings(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No ranking data available', style: TextStyle(color: Colors.white70)));
                    }

                    final rankings = snapshot.data!;
                    final topThree = rankings.where((r) => (r['rank_position'] as int) <= 3).toList();
                    final others = rankings.where((r) => (r['rank_position'] as int) > 3).toList();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          if (topThree.isNotEmpty) _buildTopThree(topThree),
                          if (others.isNotEmpty) _buildOthersList(others),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildTopThree(List<Map<String, dynamic>> topThree) {
    topThree.sort((a, b) => (a['rank_position'] as int).compareTo(b['rank_position'] as int));
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (topThree.any((e) => e['rank_position'] == 2)) 
             _TopRankerCard(ranker: topThree.firstWhere((e) => e['rank_position'] == 2), height: 140, medal: '🥈'),
          const SizedBox(width: 12),
          if (topThree.any((e) => e['rank_position'] == 1)) 
            _TopRankerCard(ranker: topThree.firstWhere((e) => e['rank_position'] == 1), height: 160, medal: '🥇'),
          const SizedBox(width: 12),
          if (topThree.any((e) => e['rank_position'] == 3))
            _TopRankerCard(ranker: topThree.firstWhere((e) => e['rank_position'] == 3), height: 120, medal: '🥉'),
        ],
      ),
    );
  }

  Widget _buildOthersList(List<Map<String, dynamic>> others) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const Text(
            'All Rankers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
                 color: Colors.white.withOpacity(0.15),
                 elevation: 0,
                 child: ListTile(
                  leading: Text(
                    '#${item['rank_position']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white70),
                  ),
                  title: Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  trailing: Text(
                    item['score'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.yellowAccent),
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

  const _TopRankerCard({required this.ranker, required this.height, required this.medal});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 8)],
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
