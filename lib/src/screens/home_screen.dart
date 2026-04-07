import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearu/src/services/get_location.dart' as getLocation;
import 'package:nearu/src/widgets/search_bar_widget.dart';
import 'package:nearu/src/widgets/create_event_widget.dart';
import 'package:nearu/src/widgets/map_marker_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double? latitude;
  double? longitude;

  final MapController _mapController = MapController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await getLocation.currentPosition();
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        print(
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}",
        );
      });
    } catch (e) {
      debugPrint("Erro localização: $e");
    }
  }

  void _goToCurrentLocation() {
    if (latitude != null && longitude != null) {
      _mapController.move(LatLng(latitude!, longitude!), 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (latitude == null || longitude == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Mapa"), centerTitle: true),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(latitude!, longitude!),
              initialZoom: 15,
              onMapReady: _goToCurrentLocation,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.nearu',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(latitude!, longitude!),
                    width: 120,
                    height: 100,
                    child: const MapMarkerWidget(
                      title: 'Show ao vivo',
                      description: 'Hoje às 20h',
                      category: 'Música',

                      /*
                      MapMarkerWidget(
                      title: event.title,
                      description: event.description,
                      category: event.category,
                    )
                      */
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {
                      launchUrl(
                        Uri.parse('https://openstreetmap.org/copyright'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: SearchBarWidget(
              hintText: "Pesquisar localização/evento/interesse",
              controller: searchController,
            ),
          ),
        ],
      ),

      //botão para criar evento, que abre um modal com campos para título, descrição (opcinal), local(getlocation), imagem(opcional), ícone da categoria do evento
      // e por fim botão de confirmação
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_event',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const AddEventWidget(),
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'my_location',
            onPressed: _goToCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
