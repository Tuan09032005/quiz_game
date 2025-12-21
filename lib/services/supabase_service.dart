import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  // =========================
  // CATEGORY
  // =========================
  static Future<List<dynamic>> getCategories() async {
    return await client
        .from('categories')
        .select()
        .order('order_index');
  }

  static Future<void> addCategory({required String name}) async {
    await client.from('categories').insert({
      'name': name,
    });
  }

  static Future<void> deleteCategoryAndQuestions({required String categoryId}) async {
    // delete questions belonging to category first
    await client.from('questions').delete().eq('category_id', categoryId);
    // then delete the category
    await client.from('categories').delete().eq('id', categoryId);
  }

  // =========================
  // QUESTIONS BY CATEGORY
  // =========================
  static Future<List<dynamic>> getQuestions(String categoryId) async {
    return await client
        .from('questions')
        .select()
        .eq('category_id', categoryId);
  }

  // =========================
  // QUESTIONS CRUD (ADMIN)
  // =========================
  static Future<void> addQuestion({
    required String categoryId,
    required String question,
    required List<String> answers,
    required int correctIndex,
  }) async {
    await client.from('questions').insert({
      'category_id': categoryId,
      'question': question,
      'answers': answers,
      'correct_index': correctIndex,
    });
  }

  static Future<void> updateQuestion({
    required String questionId,
    required String question,
    required List<String> answers,
    required int correctIndex,
  }) async {
    await client
        .from('questions')
        .update({
          'question': question,
          'answers': answers,
          'correct_index': correctIndex,
        })
        .eq('id', questionId);
  }

  static Future<void> deleteQuestion({
    required String questionId,
  }) async {
    await client.from('questions').delete().eq('id', questionId);
  }

  // =========================
  // 🔥 ALL QUESTIONS (RANKING)
  // =========================
  static Future<List<dynamic>> getAllQuestions({
    int limit = 10,
  }) async {
    final res = await client
        .from('questions')
        .select()
        .limit(limit);

    res.shuffle(); // trộn ngẫu nhiên
    return res;
  }

  // =========================
  // 🔥 ADD SCORE TO USER
  // =========================
  static Future<void> addScoreToUser({
    required String authId,
    required int score,
  }) async {
      await client.rpc(
      'update_best_score',
      params: {
        'p_auth_id': authId,
        'p_score': score,
      },
    );
  }
}
