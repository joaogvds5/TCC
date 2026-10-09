import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearu/src/models/event.dart';
import 'package:nearu/src/services/load_events_service.dart';
import 'package:nearu/src/widgets/map_marker_widget.dart';
import 'package:nearu/src/widgets/map_marker_style.dart';

class MapMarkersBuilder {
  const MapMarkersBuilder();

  static List<Marker> build(
    List<EventCluster> clusters, {
    void Function(Event event)? onMarkerTap,
  }) {
    if (clusters.isEmpty) return [];

    return clusters.asMap().entries.map((entry) {
      final index = entry.key;
      final cluster = entry.value;
      final event = cluster.mainEvent;

      return Marker(
        point: LatLng(event.latitude, event.longitude),
        width: MapMarkerStyle.markerWidth,
        height: MapMarkerStyle.markerHeight + 10,
        child: GestureDetector(
          onTap: () {
            debugPrint('Marcador clicado: ${event.title}');
            onMarkerTap?.call(event);
          },
          child: MapMarkerWidget(
            key: ValueKey('marker_${event.id}_$index'),
            title: event.title,
            description: event.description,
            categoryId: event.categoryId,
            heat: cluster.intensity,
            event: event,
          ),
        ),
      );
    }).toList();
  }
}
