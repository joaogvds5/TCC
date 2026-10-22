import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:nearu/src/controllers/home_controller.dart';
import 'package:nearu/src/widgets/add_event_widget.dart';
import 'package:nearu/src/models/event.dart';
import 'package:nearu/src/screens/event_detail_screen.dart';
import 'package:nearu/src/screens/profile_screen.dart';
import 'package:nearu/src/screens/chats_screen.dart';
import 'package:nearu/src/widgets/map_view_widget.dart';
import 'package:nearu/src/widgets/map_markers.dart';
import 'package:nearu/src/widgets/profile_icon_widget.dart';
import 'package:nearu/src/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final HomeController controller = HomeController();
  final MapController mapController = MapController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    controller.init();
    controller.addListener(_updateUI);
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_updateUI);
    controller.dispose();
    super.dispose();
  }

  void _goToCurrentLocation() {
    if (controller.latitude != null && controller.longitude != null) {
      mapController.move(controller.currentLatLng, 15);
    }
  }

  void _openChats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatsPage()),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  Future<void> _refreshEvents() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      await Supabase.instance.client.rpc('cleanup_expired_events');
      await controller.loadEvents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eventos atualizados!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao atualizar eventos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar eventos'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  void _openEventDetail(Event event) {
    debugPrint('Abrindo modal para: ${event.title}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return EventDetailScreen(
              event: event,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  Future<void> _openCreateEvent() async {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Faça login para criar eventos'),
          backgroundColor: Colors.orange.shade700,
          action: SnackBarAction(
            label: 'Login',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddEventWidget(),
    );

    controller.loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Carregando mapa..."),
            ],
          ),
        ),
      );
    }

    final markers = MapMarkersBuilder.build(
      controller.clusters,
      onMarkerTap: _openEventDetail,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("NearU"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: ProfileIconWidget(size: 36, onTap: _openProfile),
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshEvents,
            tooltip: 'Atualizar eventos',
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: _openChats,
            tooltip: 'Chats',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          MapView(
            controller: mapController,
            center: controller.currentLatLng,
            markers: markers,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'location_mini',
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_event',
        onPressed: _openCreateEvent,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Criar Evento'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
