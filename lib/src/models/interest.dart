import 'package:flutter/material.dart';

class Interest {
  final String nameInterest;
  final String typeInterest;
  final IconData iconInterest;

  Interest({
    required this.nameInterest,
    required this.typeInterest,
    required this.iconInterest,
  });

  static final List<Interest> predefined = [
    Interest(
      nameInterest: 'Música',
      typeInterest: 'Música',
      iconInterest: Icons.music_note,
    ),
    Interest(
      nameInterest: 'Esporte',
      typeInterest: 'Esporte',
      iconInterest: Icons.sports_soccer,
    ),
    Interest(
      nameInterest: 'Tecnologia',
      typeInterest: 'Tecnologia',
      iconInterest: Icons.computer,
    ),
  ];
}
