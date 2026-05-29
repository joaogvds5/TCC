import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearu/src/services/load_events_service.dart';
import 'package:nearu/src/widgets/map_marker_widget.dart';
import 'package:nearu/src/widgets/map_marker_style.dart';

/// Constrói a lista de marcadores a partir dos clusters de eventos
class MapMarkersBuilder {
  /// Callback opcional quando um marcador é tocado
  final void Function(EventCluster cluster)? onMarkerTap;

  const MapMarkersBuilder({this.onMarkerTap});

  /// Constrói a lista de marcadores para o mapa
  static List<Marker> build(
    List<EventCluster> clusters, {
    void Function(EventCluster cluster)? onMarkerTap,
  }) {
    if (clusters.isEmpty) return [];

    return clusters.asMap().entries.map((entry) {
      final index = entry.key;
      final cluster = entry.value;
      final event = cluster.mainEvent;

      return Marker(
        point: LatLng(event.latitude, event.longitude),
        width: MapMarkerStyle.markerWidth,
        height: MapMarkerStyle.markerHeight + 10, // +10 para o triângulo
        child: MapMarkerWidget(
          key: ValueKey('marker_${event.id}_$index'),
          title: event.title,
          description: event.description,
          categoryId: event.category,
          heat: cluster.intensity,
          onTap: () => onMarkerTap?.call(cluster),
        ),
      );
    }).toList();
  }
}
