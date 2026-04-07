import 'location.dart';

class Place {
  final String idPlace;
  final String namePlace;
  final String descriptionPlace;
  final Location location;

  Place({
    required this.idPlace,
    required this.namePlace,
    required this.descriptionPlace,
    required this.location,
  });
}
