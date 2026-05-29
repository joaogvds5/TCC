import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearu/src/widgets/map_marker_style.dart';

/// Widget que renderiza o mapa com tema consistente
class MapView extends StatelessWidget {
  final MapController controller;
  final LatLng center;
  final List<Marker> markers;
  final List<Polyline>? polylines;
  final List<Polygon>? polygons;

  const MapView({
    super.key,
    required this.controller,
    required this.center,
    required this.markers,
    this.polylines,
    this.polygons,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14.0,
        minZoom: 3.0,
        maxZoom: 18.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // Camada de tiles (mapa base)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.nearu.app',
          // Cache e fallback
          errorImage: const AssetImage('assets/map_error.png'),
        ),

        // Camada de marcadores
        MarkerLayer(markers: markers),

        // Camada de polylines (rotas)
        if (polylines != null && polylines!.isNotEmpty)
          PolylineLayer(polylines: polylines!),

        // Camada de polígonos (áreas)
        if (polygons != null && polygons!.isNotEmpty)
          PolygonLayer(polygons: polygons!),

        // Atribuição do OpenStreetMap
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }
}
