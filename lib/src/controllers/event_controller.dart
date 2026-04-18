import 'package:supabase_flutter/supabase_flutter.dart ';
import 'package:nearu/src/models/event.dart';
import 'package:nearu/src/services/create_event_service.dart';

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
        throw Exception("Usuário não autenticado");
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
    } catch (e) {
      return false;
    }
  }
}
