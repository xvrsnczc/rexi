import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/user_model.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  UserModel? currentUser() {
    final u = _client.auth.currentUser;
    if (u == null) return null;
    return UserModel(
      id: u.id,
      email: u.email,
      fullName: u.userMetadata?['full_name'] as String?,
    );
  }
}
