import 'package:nearu/src/models/interest.dart';

class People {
  final String name;
  final String biography;
  final DateTime birthDate;
  final String? photoUrl;
  final Interest interest;

  People({
    required this.name,
    required this.biography,
    required this.birthDate,
    this.photoUrl,
    required this.interest,
  });

  /// 🔽 Banco → Objeto
  factory People.fromMap(Map<String, dynamic> map) {
    return People(
      name: map['name'],
      biography: map['biography'],
      birthDate: DateTime.parse(map['birth_date']),
      photoUrl: map['photo_url'],
      interest: Interest.fromMap(map['interest']),
    );
  }

  /// 🔼 Objeto → Banco
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'biography': biography,
      'birth_date': birthDate.toIso8601String(),
      'photo_url': photoUrl,
      'interest_id': interest.id,
    };
  }
}
