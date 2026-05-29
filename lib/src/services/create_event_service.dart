import 'package:supabase_flutter/supabase_flutter.dart ';
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
    final response = await _client.from('events').select();

    return (response as List).map((e) => Event.fromMap(e)).toList();
  }

  // deletar evento na verdade será uma função de "cancelar" evento, ou seja, marcar como inativo no banco. eventualmente implementar
  Future<void> deleteEvent(String eventId) async {
    await _client.from('events').delete().eq('id', eventId);
  }
}
