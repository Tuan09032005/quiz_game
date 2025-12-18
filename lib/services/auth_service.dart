import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // =====================
  // REGISTER
  // =====================
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign up failed');
    }

    // Tạo user trong bảng users
    await _client.from('users').insert({
      'auth_id': user.id,
      'email': email,
      'name': name,
      'total_score': 0,
      'is_guest': false,
      'created_at': DateTime.now().toIso8601String(),
    });

    return response;
  }

  // =====================
  // LOGIN
  // =====================
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    // Bắt buộc sign out session cũ
    await _client.auth.signOut();

    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // =====================
  // CURRENT USER
  // =====================
  static User? currentUser() {
    return _client.auth.currentUser;
  }

  // =====================
  // LOGOUT
  // =====================
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // =====================
  // GET PROFILE BY AUTH ID
  // =====================
  static Future<Map<String, dynamic>?> getProfileByAuthId(
      String authId,
      ) async {
    return await _client
        .from('users')
        .select()
        .eq('auth_id', authId)
        .maybeSingle();
  }

  // =====================
  // UPDATE USER NAME  🔥 FIX LỖI
  // =====================
  static Future<void> updateUserName(
      String authId,
      String newName,
      ) async {
    await _client
        .from('users')
        .update({'name': newName})
        .eq('auth_id', authId);
  }
}
