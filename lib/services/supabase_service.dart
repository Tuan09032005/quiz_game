import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  // Lấy category
  static Future<List<dynamic>> getCategories() async {
    return await client.from('categories').select().order('order_index');
  }

  // Lấy câu hỏi theo category
  static Future<List<dynamic>> getQuestions(String categoryId) async {
    return await client
        .from('questions')
        .select()
        .eq('category_id', categoryId);
  }
}
