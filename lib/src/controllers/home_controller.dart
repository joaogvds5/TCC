import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearu/src/services/get_location.dart' as getLocation;
import 'package:nearu/src/services/load_events_service.dart';

class HomeController extends ChangeNotifier {
  double? latitude;
  double? longitude;

  bool isLoading = true;

  List<EventCluster> clusters = [];

  Future<void> init() async {
    try {
      final position = await getLocation.currentPosition();

      latitude = position.latitude;
      longitude = position.longitude;

      await loadEvents();
    } catch (e) {
      debugPrint("Erro HomeController: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEvents() async {
    clusters = await LoadEventsService().loadEvents();
    notifyListeners();
  }

  LatLng get currentLatLng => LatLng(latitude!, longitude!);
}



/*
String selectedCategory = 'Todos';
List<EventCluster> allClusters = [];

Future<void> loadEvents() async {
  allClusters = await LoadEventsService().loadEvents();
  clusters = allClusters;
  notifyListeners();
}

void filterByCategory(String category) {
  selectedCategory = category;

  if (category == 'Todos') {
    clusters = allClusters;
  } else {
    clusters = allClusters.where((cluster) {
      return cluster.mainEvent.category == category;
    }).toList();
  }

  notifyListeners();
}
*/