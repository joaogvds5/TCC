import 'package:supabase_flutter/supabase_flutter.dart';

class CreateEventService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<bool> createEvent({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
  }) async {
    final session = _supabaseClient.auth.currentSession;
    final user = _supabaseClient.auth.currentUser;

    if (session == null || user == null) {
      throw Exception('Usuário não autenticado');
    }

    await _supabaseClient.from('events').insert({
      'title': title,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': user.id,
      'created_at': DateTime.now().toIso8601String(),
    });

    return true;
  }
}
