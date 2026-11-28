
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Register pengguna baru
  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Login pengguna
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Logout pengguna
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // Mengambil pengguna yang sedang login
  User? get currentUser => _client.auth.currentUser;

  // Memeriksa status login
  bool get isLoggedIn => currentUser != null;
}
