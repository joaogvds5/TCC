// lib/src/models/profile.dart
import 'package:nearu/src/models/interest.dart';

class Profile {
  final int? id;
  final String userUuid;
  final String name;
  final String? biography;
  final DateTime? birthDate;
  final String? photoUrl;
  final String? telephone;
  final String? email;
  final DateTime? createdAt;
  final List<Interest>? interests;

  Profile({
    this.id,
    required this.userUuid,
    required this.name,
    this.biography,
    this.birthDate,
    this.photoUrl,
    this.telephone,
    this.email,
    this.createdAt,
    this.interests,
  });

  /// 🔽 Banco → Objeto
  factory Profile.fromMap(Map<String, dynamic> map) {
    // Converte interests de forma segura
    List<Interest>? interestsList;

    if (map['user_interest'] != null && map['user_interest'] is List) {
      interestsList = (map['user_interest'] as List)
          .map((ui) {
            if (ui is Map<String, dynamic>) {
              final interestData = ui['interest'] ?? ui;
              if (interestData is Map<String, dynamic>) {
                return Interest.fromMap(interestData);
              }
            }
            return null;
          })
          .whereType<Interest>()
          .toList();
    }

    return Profile(
      id: map['id'],
      userUuid: map['user_id']?.toString() ?? '',
      name: map['name'] ?? '',
      biography: map['biography'],
      birthDate: map['birth_date'] != null
          ? (map['birth_date'] is String
                ? DateTime.tryParse(map['birth_date'] as String)
                : null)
          : null,
      photoUrl: map['photo_user'],
      telephone: map['telephone'],
      email: map['email'],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      interests: interestsList,
    );
  }

  /// 🔼 Objeto → Banco
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'biography': biography,
      'birth_date': birthDate?.toIso8601String(),
      'photo_user': photoUrl,
      'telephone': telephone,
    };
    map.removeWhere((key, value) => value == null);
    return map;
  }

  Profile copyWith({
    String? name,
    String? biography,
    DateTime? birthDate,
    String? photoUrl,
    String? telephone,
    List<Interest>? interests,
  }) {
    return Profile(
      id: id,
      userUuid: userUuid,
      name: name ?? this.name,
      biography: biography ?? this.biography,
      birthDate: birthDate ?? this.birthDate,
      photoUrl: photoUrl ?? this.photoUrl,
      telephone: telephone ?? this.telephone,
      email: email,
      createdAt: createdAt,
      interests: interests ?? this.interests,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts.last.isNotEmpty) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  @override
  String toString() => 'Profile(name: $name, email: $email)';
}
