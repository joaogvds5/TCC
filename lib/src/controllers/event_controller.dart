import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/models/event.dart';
import 'package:nearu/src/services/event_service.dart';

class UnauthenticatedException implements Exception {
  final String message;
  UnauthenticatedException([this.message = "Usuário não autenticado"]);

  @override
  String toString() => message;
}

class EventController {
  final EventService _service = EventService();

  Future<String?> createEvent({
    required String title,
    required String description,
    required int categoryId,
    required double latitude,
    required double longitude,
    Uint8List? photoBytes,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw UnauthenticatedException("Usuário não autenticado");
      }

      // cria o evento
      final event = Event(
        title: title,
        description: description,
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        userId: user.id,
        photoUrl: null,
      );

      final eventMap = event.toMap();

      //insere o evento e retorna o ID
      final response = await Supabase.instance.client
          .from('events')
          .insert(eventMap)
          .select('id')
          .maybeSingle();

      if (response == null) {
        throw Exception('Erro ao criar evento');
      }

      final eventId = response['id'].toString();

      if (photoBytes != null) {
        debugPrint('Enviando foto do evento...');
        final photoUrl = await _service.uploadEventPhoto(
          photoBytes,
          eventId: eventId,
        );
        debugPrint('Foto enviada: $photoUrl');
      }

      debugPrint('Evento criado com sucesso. ID: $eventId');
      return eventId;
    } on UnauthenticatedException {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao criar evento: $e');
      return null;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw UnauthenticatedException("Usuário não autenticado");
      }

      return await _service.deleteEvent(eventId);
    } on UnauthenticatedException {
      rethrow;
    } catch (e) {
      debugPrint('Erro ao excluir evento: $e');
      return false;
    }
  }

  bool isEventCreator(Event event) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return userId != null && userId == event.userId;
  }
}
