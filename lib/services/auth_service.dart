import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

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

    // Tạo profile
    await _client.from('users').insert({
      'auth_id': user.id,
      'email': email,
      'name': name,
      'total_score': 0,
      'is_guest': false,
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
    // 🔥 BẮT BUỘC clear session cũ
    await _client.auth.signOut();

    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // =====================
  // PROFILE
  // =====================
  static Future<Map<String, dynamic>?> getProfileByAuthId(String authId) async {
    return await _client
        .from('users')
        .select()
        .eq('auth_id', authId)
        .maybeSingle();
  }

  // =====================
  // CURRENT USER
  // =====================
  static User? currentUser() {
    return _client.auth.currentUser;
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
