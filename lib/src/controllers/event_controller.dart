import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/models/event.dart';
import 'package:nearu/src/services/create_event_service.dart';

// Exceção personalizada
class UnauthenticatedException implements Exception {
  final String message;
  UnauthenticatedException([this.message = "Usuário não autenticado"]);

  @override
  String toString() => message;
}

class EventController {
  final EventService _service = EventService();

  Future<bool> createEvent({
    required String title,
    required String description,
    required int categoryId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw UnauthenticatedException("Usuário não autenticado");
      }

      final event = Event(
        title: title,
        description: description,
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        userId: user.id,
        photoUrl: '',
      );

      await _service.createEvent(event);
      return true;
    } on UnauthenticatedException {
      // REPROPAGA a exceção para o widget tratar
      rethrow;
    } catch (e) {
      // Outros erros retornam false
      debugPrint('Erro ao criar evento: $e');
      return false;
    }
  }
}
