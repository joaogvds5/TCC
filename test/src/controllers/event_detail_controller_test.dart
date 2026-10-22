import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/models/event_participant.dart';

///simula   sem considerar supabase
class FakeEventDetailController {
  bool isLoading = false;
  bool isParticipating = false;
  List<EventParticipant> participants = [];
  int participantCount = 0;

  Future<void> loadEventDetails() async {
    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 10));

    participants = [
      EventParticipant(
        userId: 'uuid-1',
        userName: 'João',
        joinedAt: DateTime(2024, 1, 1),
      ),
      EventParticipant(
        userId: 'uuid-2',
        userName: 'Maria',
        joinedAt: DateTime(2024, 1, 2),
      ),
    ];
    participantCount = participants.length;
    isParticipating = true;
    isLoading = false;
  }

  Future<bool> joinEvent() async {
    isParticipating = true;
    await loadEventDetails();
    return true;
  }

  Future<bool> leaveEvent() async {
    isParticipating = false;
    participantCount = 0;
    participants = [];
    return true;
  }
}

void main() {
  late FakeEventDetailController controller;

  setUp(() {
    controller = FakeEventDetailController();
  });

  group('EventDetailController - Carregamento', () {
    test('Carrega participantes e define isParticipating', () async {
      await controller.loadEventDetails();

      expect(controller.isLoading, isFalse);
      expect(controller.participants.length, equals(2));
      expect(controller.participantCount, equals(2));
      expect(controller.isParticipating, isTrue);
    });
  });

  group('EventDetailController - Join/Leave', () {
    test('Entrar no evento define isParticipating = true', () async {
      await controller.joinEvent();
      expect(controller.isParticipating, isTrue);
    });

    test('Sair do evento define isParticipating = false', () async {
      await controller.joinEvent();
      await controller.leaveEvent();
      expect(controller.isParticipating, isFalse);
    });

    test('Sair do evento limpa lista de participantes', () async {
      await controller.joinEvent();
      await controller.leaveEvent();
      expect(controller.participants, isEmpty);
      expect(controller.participantCount, equals(0));
    });
  });
}
