import 'location.dart';
import 'interest.dart';

class People {
  final int id;
  final String name;
  final DateTime birthDate;
  final String? photoUrl;
  final Location location;
  final Interest interest;

  People({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.photoUrl,
    required this.location,
    required this.interest,
  });

  void createPeople() {
    // Lógica para criar uma pessoa
  }

  void editPeople() {
    // Lógica para editar uma pessoa
  }

  void deletePeople() {
    // Lógica para excluir uma pessoa
  }

  void viewPeople() {
    // Lógica para visualizar os detalhes de uma pessoa
  }

  void listPeople() {
    // Lógica para listar todas as pessoas
  }

  void searchPeople() {
    // Lógica para pesquisar pessoas com base em critérios específicos
  }

  void filterPeople() {
    // Lógica para filtrar pessoas com base em interesses, localização ou outros critérios
  }

  void sortPeople() {
    // Lógica para ordenar pessoas por nome, data de nascimento ou outros critérios
  }
}
