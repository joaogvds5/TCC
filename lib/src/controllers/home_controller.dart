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

  // Cache para filtro por categoria
  String selectedCategory = 'Todos';
  List<EventCluster> allClusters = [];

  /// Inicializa o controller: pega localização, limpa eventos expirados e carrega eventos
  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1. Obtém a localização atual
      final position = await getLocation.currentPosition();
      latitude = position.latitude;
      longitude = position.longitude;

      // 2. Limpa eventos expirados (chama a função RPC no Supabase)
      await _cleanupExpiredEvents();

      // 3. Carrega os eventos ativos
      await loadEvents();
    } catch (e) {
      debugPrint("Erro HomeController: $e");
      errorMessage = "Erro ao carregar dados. Verifique sua conexão.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega os eventos do banco e aplica o filtro atual
  Future<void> loadEvents() async {
    try {
      allClusters = await LoadEventsService().loadEvents();
      _applyFilter();
    } catch (e) {
      debugPrint("Erro ao carregar eventos: $e");
    }
  }

  /// Atualiza eventos (chamado após criar um evento)
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

  /// Chama a função RPC que desativa eventos com mais de 24h
  Future<void> _cleanupExpiredEvents() async {
    try {
      final result = await Supabase.instance.client.rpc(
        'cleanup_expired_events',
      );

      if (result != null) {
        debugPrint('Eventos expirados limpos: $result');
      }
    } catch (e) {
      // Não lança erro, apenas loga
      debugPrint('Erro ao limpar eventos expirados: $e');
    }
  }

  /// Filtra eventos por categoria
  void filterByCategory(String category) {
    selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  /// Aplica o filtro de categoria nos clusters
  void _applyFilter() {
    if (selectedCategory == 'Todos') {
      clusters = List.from(allClusters);
    } else {
      clusters = allClusters.where((cluster) {
        return cluster.mainEvent.category == selectedCategory;
      }).toList();
    }
  }

  /// Retorna a localização atual como LatLng
  LatLng get currentLatLng {
    if (latitude == null || longitude == null) {
      // Fallback: São Paulo
      return const LatLng(-23.5505, -46.6333);
    }
    return LatLng(latitude!, longitude!);
  }

  /// Verifica se a localização foi obtida com sucesso
  bool get hasLocation => latitude != null && longitude != null;

  /// Número total de eventos carregados
  int get totalEvents {
    int count = 0;
    for (var cluster in clusters) {
      count += cluster.events.length;
    }
    return count;
  }

  /// Número de clusters no mapa
  int get totalClusters => clusters.length;
}
