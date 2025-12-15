import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RankingScreen extends StatelessWidget {
  // Supabase client
  final SupabaseClient supabase = Supabase.instance.client;

  // Lấy danh sách ranking từ Supabase
  Future<List<Map<String, dynamic>>> fetchRankings() async {
    final response = await supabase
      .from('user_rankings') // tên view/table
      .select('rank_position, name, score')
      .order('rank_position', ascending: true);

    final data = response as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ranking")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRankings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Khi đang load dữ liệu
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Khi có lỗi
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Khi không có dữ liệu
            return const Center(child: Text('No ranking data available'));
          }

          final rankings = snapshot.data!;

          return ListView.separated(
            itemCount: rankings.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = rankings[index];
              return ListTile(
                leading: Text(
                  '#${item['rank_position']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                title: Text(
                  item['name'],
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  item['score'].toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
