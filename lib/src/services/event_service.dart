// lib/src/services/event_service.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/models/event.dart';

class EventService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createEvent(Event event) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado");
    }

    await _client.from('events').insert(event.toMap());
  }

  Future<List<Event>> getEvents() async {
    final response = await _client.from('active_events').select();

    return (response as List).map((e) => Event.fromMap(e)).toList();
  }

  /// Busca um evento específico
  Future<Event?> getEventById(String eventId) async {
    final response = await _client
        .from('events')
        .select('*')
        .eq('id', eventId)
        .maybeSingle();

    if (response == null) return null;
    return Event.fromMap(response);
  }

  Future<bool> isEventActive(String eventId) async {
    try {
      final result = await _client.rpc(
        'is_event_active',
        params: {'event_id_param': eventId},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Erro ao verificar evento ativo: $e');
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      await _client.from('events').delete().eq('id', eventId);
      return true;
    } catch (e) {
      debugPrint('Erro ao excluir evento: $e');
      return false;
    }
  }

  Future<String?> uploadEventPhoto(
    Uint8List bytes, {
    required String eventId,
  }) async {
    try {
      final fileName =
          'event_${eventId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _client.storage
          .from('events')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final photoUrl = _client.storage.from('events').getPublicUrl(fileName);

      await _client
          .from('events')
          .update({'photo_event': photoUrl})
          .eq('id', eventId);

      return photoUrl;
    } catch (e) {
      debugPrint('Erro ao fazer upload da foto do evento: $e');
      return null;
    }
  }
}
