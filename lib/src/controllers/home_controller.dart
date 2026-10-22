// lib/src/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/services/get_location.dart' as getLocation;
import 'package:nearu/src/services/load_events_service.dart';

class HomeController extends ChangeNotifier {
  double? latitude;
  double? longitude;

  bool isLoading = true;
  String? errorMessage;

  List<EventCluster> clusters = [];

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final position = await getLocation.currentPosition();
      latitude = position.latitude;
      longitude = position.longitude;

      await _cleanupExpiredEvents();
      await loadEvents();
    } catch (e) {
      debugPrint("Erro HomeController: $e");
      errorMessage = "Erro ao carregar dados. Verifique sua conexão.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEvents() async {
    try {
      clusters = await LoadEventsService().loadEvents();
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao carregar eventos: $e");
    }
  }

  Future<void> refreshEvents() async {
    isLoading = true;
    notifyListeners();

    try {
      await _cleanupExpiredEvents();
      await loadEvents();
    } catch (e) {
      debugPrint("Erro ao atualizar eventos: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cleanupExpiredEvents() async {
    try {
      final result = await Supabase.instance.client.rpc(
        'cleanup_expired_events',
      );
      if (result != null) {
        debugPrint('Eventos expirados limpos: $result');
      }
    } catch (e) {
      debugPrint('Erro ao limpar eventos expirados: $e');
    }
  }

  LatLng get currentLatLng {
    if (latitude == null || longitude == null) {
      return const LatLng(-22.21252037, -54.8264522); //unigran
    }
    return LatLng(latitude!, longitude!);
  }

  bool get hasLocation => latitude != null && longitude != null;
}
