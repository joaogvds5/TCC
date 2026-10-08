// lib/src/controllers/event_detail_controller.dart
import 'package:flutter/foundation.dart';
import 'package:nearu/src/models/event_participant.dart';
import 'package:nearu/src/services/event_participation_service.dart';

class EventDetailController extends ChangeNotifier {
  final EventParticipationService _service = EventParticipationService();

  bool _isLoading = false;
  bool _isParticipating = false;
  List<EventParticipant> _participants = [];
  int _participantCount = 0;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isParticipating => _isParticipating;
  List<EventParticipant> get participants => _participants;
  int get participantCount => _participantCount;
  String? get error => _error;

  Future<void> loadEventDetails(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.isParticipating(eventId),
        _service.getParticipants(eventId),
        _service.getParticipantCount(eventId),
      ]);

      _isParticipating = results[0] as bool;
      _participants = results[1] as List<EventParticipant>;
      _participantCount = results[2] as int;
    } catch (e) {
      _error = 'Erro ao carregar detalhes';
      debugPrint('Erro EventDetailController: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinEvent(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _service.joinEvent(eventId);
      if (success) {
        _isParticipating = true;
        await loadEventDetails(eventId);
      }
      return success;
    } catch (e) {
      _error = 'Erro ao entrar no evento';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> leaveEvent(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _service.leaveEvent(eventId);
      if (success) {
        _isParticipating = false;
        await loadEventDetails(eventId);
      }
      return success;
    } catch (e) {
      _error = 'Erro ao sair do evento';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
