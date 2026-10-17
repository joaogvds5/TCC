// lib/src/services/load_events_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/models/event.dart';

/// Cluster de eventos próximos
class EventCluster {
  final Event mainEvent;
  final List<Event> events;

  EventCluster({required this.mainEvent, required this.events});

  int get heatScore => events.length;

  double get intensity {
    if (heatScore >= 10) return 1.0;
    return heatScore / 10.0;
  }
}

/// Serviço de carregamento e clusterização de eventos
class LoadEventsService {
  final SupabaseClient _client = Supabase.instance.client;

  static const double proximityThreshold = 0.02;

  Future<List<EventCluster>> loadEvents() async {
    try {
      final response = await _client
          .from('active_events')
          .select()
          .order('created_at', ascending: false);

      final List data = response as List;
      final events = data.map((e) => Event.fromMap(e)).toList();

      return _clusterEvents(events);
    } catch (e) {
      debugPrint('Erro ao carregar eventos: $e');
      return [];
    }
  }

  List<EventCluster> _clusterEvents(List<Event> events) {
    final List<EventCluster> clusters = [];

    for (var event in events) {
      bool added = false;

      for (int i = 0; i < clusters.length; i++) {
        if (_isClose(event, clusters[i].mainEvent)) {
          final updatedEvents = [...clusters[i].events, event];

          final newMain =
              (event.createdAt ?? DateTime.now()).isAfter(
                clusters[i].mainEvent.createdAt ?? DateTime.now(),
              )
              ? event
              : clusters[i].mainEvent;

          clusters[i] = EventCluster(mainEvent: newMain, events: updatedEvents);

          added = true;
          break;
        }
      }

      if (!added) {
        clusters.add(EventCluster(mainEvent: event, events: [event]));
      }
    }

    return clusters;
  }

  bool _isClose(Event a, Event b) {
    final latDiff = (a.latitude - b.latitude).abs();
    final lonDiff = (a.longitude - b.longitude).abs();
    return latDiff <= proximityThreshold && lonDiff <= proximityThreshold;
  }
}
