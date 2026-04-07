class Location {
  final String idLocal;
  final String streetName;
  final String number;
  final String city;
  final double latitude;
  final double longitude;
  final String obsLocation;

  Location({
    required this.idLocal,
    required this.streetName,
    required this.number,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.obsLocation,
  });
}

/*
class Location {
  final String idLocal;
  final String streetName;
  final String number;
  final String city;
  final double latitude;
  final double longitude;
  final String obsLocation;

  Location({
    required this.idLocal,
    required this.streetName,
    required this.number,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.obsLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'idLocal': idLocal,
      'streetName': streetName,
      'number': number,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'obsLocation': obsLocation,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      idLocal: map['idLocal'],
      streetName: map['streetName'],
      number: map['number'],
      city: map['city'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      obsLocation: map['obsLocation'],
    );
  }
}
*/
