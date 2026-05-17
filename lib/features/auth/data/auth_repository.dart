import 'package:supabase_flutter/supabase_flutter.dart';

/// Autenticación Supabase (envolver signIn/signUp/recuperación).
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Future<void> signIn(String email, String password) => _client.auth
      .signInWithPassword(email: email, password: password);

  Future<void> signUp(String email, String password, String fullName) =>
      _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(email);
}
