import 'package:nearu/src/models/people.dart';
import 'package:nearu/src/services/people_service.dart';
import 'package:nearu/src/models/interest.dart';

class PeopleController {
  final PeopleService _service = PeopleService();

  Future<bool> createPeople({
    required String name,
    required DateTime birthDate,
    required String biography,
    required Interest interest,
  }) async {
    try {
      final person = People(
        name: name,
        biography: "Biografia padrão", // Placeholder, pode ser editado depois
        birthDate: birthDate,
        photoUrl: null,
        interest: interest,
      );

      await _service.createPeople(person);
      return true;
    } catch (e) {
      return false;
    }
  }
}
