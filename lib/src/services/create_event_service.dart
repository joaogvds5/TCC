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
      if (_supabaseClient.auth.currentUser == null) {
        throw Exception("Usuário não autenticado");
      }
      return false;
    }

    try {
      await _supabaseClient.from('events').insert({
        'title': title,
        'description': description,
        'interest_category': category,
        'latitude_event': latitude.toString(),
        'longitude_event': longitude.toString(),
        'user_creator': user.id,
        'photo_event': '',
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
