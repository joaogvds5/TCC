import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearu/src/models/event.dart';
import 'package:nearu/src/services/load_events_service.dart';
import 'package:nearu/src/widgets/map_marker_style.dart';
import 'package:nearu/src/widgets/map_marker_widget.dart';
import 'package:nearu/src/widgets/user_location_marker.dart';

class MapMarkersBuilder {
  const MapMarkersBuilder();

  /// Zoom de referência: neste zoom o cartão tem o tamanho "base".
  static const double _baseZoom = 14.0;

  /// Abaixo deste zoom mostramos apenas um ponto (sem cartão).
  static const double _dotOnlyZoom = 8.0;

  /// A partir deste zoom o cartão é mostrado em tamanho normal.
  static const double _fullCardZoom = 12.0;

  /// Limites da escala do cartão.
  static const double _minScale = 0.35;
  static const double _maxScale = 1.0;

  /// Tamanho do ponto (em px) mostrado em zoom baixo.
  static const double _dotSize = 18.0;

  static List<Marker> build(
    List<EventCluster> clusters, {
    required double currentZoom,
    void Function(Event event)? onMarkerTap,
  }) {
    if (clusters.isEmpty) return [];

    // Decide a representação com base no zoom.
    final bool showDotOnly = currentZoom < _dotOnlyZoom;
    final double cardScale = _computeScale(currentZoom);

    return clusters.asMap().entries.map((entry) {
      final index = entry.key;
      final cluster = entry.value;
      final event = cluster.mainEvent;
      final point = LatLng(event.latitude, event.longitude);

      if (showDotOnly) {
        return Marker(
          point: point,
          width: _dotSize,
          height: _dotSize,
          child: GestureDetector(
            onTap: () {
              debugPrint('Ponto clicado: ${event.title}');
              onMarkerTap?.call(event);
            },
            child: _CategoryDot(
              categoryId: event.categoryId,
              heat: cluster.intensity,
            ),
          ),
        );
      }

      final width = MapMarkerStyle.markerWidth * cardScale;
      final height = (MapMarkerStyle.markerHeight + 10) * cardScale;

      return Marker(
        point: point,
        width: width,
        height: height,
        child: GestureDetector(
          onTap: () {
            debugPrint('Marcador clicado: ${event.title}');
            onMarkerTap?.call(event);
          },
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: MapMarkerStyle.markerWidth,
              height: MapMarkerStyle.markerHeight + 10,
              child: MapMarkerWidget(
                key: ValueKey('marker_${event.id}_$index'),
                title: event.title,
                description: event.description,
                categoryId: event.categoryId,
                heat: cluster.intensity,
                event: event,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Escala do cartão = 2^(zoom - baseZoom), limitada entre
  /// [_minScale] e [_maxScale]. Entre [_dotOnlyZoom] e [_fullCardZoom]
  /// o cartão aparece mais pequeno (a escala mínima já cobre isso).
  static double _computeScale(double zoom) {
    final raw = math.pow(2, zoom - _baseZoom).toDouble();
    return raw.clamp(_minScale, _maxScale);
  }

  static Marker? buildUserMarker(LatLng? userLatLng) {
    if (userLatLng == null) return null;

    return Marker(
      point: userLatLng,
      width: MapMarkerStyle.userMarkerSize,
      height: MapMarkerStyle.userMarkerSize,
      alignment: Alignment.center,
      child: const UserLocationMarker(),
    );
  }
}

class _CategoryDot extends StatelessWidget {
  final int categoryId;
  final double heat;

  const _CategoryDot({required this.categoryId, required this.heat});

  @override
  Widget build(BuildContext context) {
    final color = MapMarkerStyle.getCategoryColor(categoryId);
    final opacity = MapMarkerStyle.getHeatOpacity(heat);

    return Center(
      child: Container(
        width: MapMarkersBuilder._dotSize,
        height: MapMarkersBuilder._dotSize,
        decoration: BoxDecoration(
          color: color.withValues(alpha: opacity),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
