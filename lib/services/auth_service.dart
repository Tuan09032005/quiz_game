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

    // Tạo profile gắn với auth_id
    await _client.from('users').insert({
      'auth_id': user.id, // 🔥 QUAN TRỌNG
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
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // =====================
  // PROFILE HELPERS
  // =====================
  static Future<Map<String, dynamic>?> getProfileByAuthId(String authId) async {
    final res = await _client
        .from('users')
        .select()
        .eq('auth_id', authId)
        .maybeSingle();

    return res;
  }

  static Future<void> createProfile({
    required String authId,
    required String email,
    required String name,
    bool isGuest = false,
  }) async {
    await _client.from('users').insert({
      'auth_id': authId,
      'email': email,
      'name': name,
      'total_score': 0,
      'is_guest': isGuest,
    });
  }

  // =====================
  // LOGOUT
  // =====================
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // =====================
  // CURRENT USER
  // =====================
  static User? currentUser() {
    return _client.auth.currentUser;
  }
}
