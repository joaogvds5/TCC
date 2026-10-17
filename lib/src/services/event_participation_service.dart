// lib/src/services/event_participation_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/models/event_participant.dart';

class EventParticipationService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> isParticipating(String eventId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _client
          .from('event_participants')
          .select('id')
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Erro ao verificar participação: $e');
      return false;
    }
  }

  Future<List<EventParticipant>> getParticipants(String eventId) async {
    try {
      final response = await _client
          .from('event_participants')
          .select('*, users(name, photo_user)')
          .eq('event_id', eventId)
          .order('joined_at', ascending: true);

      return (response as List)
          .map((e) => EventParticipant.fromMap(e))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar participantes: $e');
      return [];
    }
  }

  Future<bool> joinEvent(String eventId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final alreadyJoined = await isParticipating(eventId);
      if (alreadyJoined) return true;

      await _client.from('event_participants').insert({
        'event_id': eventId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Usuário entrou no evento');
      return true;
    } catch (e) {
      debugPrint('Erro ao entrar no evento: $e');
      return false;
    }
  }

  Future<bool> leaveEvent(String eventId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _client
          .from('event_participants')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', userId);

      debugPrint('Usuário saiu do evento');
      return true;
    } catch (e) {
      debugPrint('Erro ao sair do evento: $e');
      return false;
    }
  }

  Future<int> getParticipantCount(String eventId) async {
    try {
      final response = await _client
          .from('event_participants')
          .select('id') // Apenas seleciona o id, sem FetchOptions
          .eq('event_id', eventId);

      return (response as List).length;
    } catch (e) {
      debugPrint('Erro ao contar participantes: $e');
      return 0;
    }
  }
}
