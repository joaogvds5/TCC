import 'package:flutter/material.dart';

class MapMarkerWidget extends StatelessWidget {
  final String title;
  final String description;
  final String category;

  const MapMarkerWidget({
    super.key,
    required this.title,
    required this.description,
    required this.category,
  });

  IconData _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'música':
        return Icons.music_note;

      case 'esporte':
        return Icons.sports_soccer;

      case 'feira':
        return Icons.storefront;

      case 'tecnologia':
        return Icons.computer;

      case 'evento':
      default:
        return Icons.location_pin;
    }
  }

  Color _getCategoryColor() {
    switch (category.toLowerCase()) {
      case 'música':
        return Colors.purple;

      case 'esporte':
        return Colors.green;

      case 'feira':
        return Colors.orange;

      case 'tecnologia':
        return Colors.blue;

      case 'evento':
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_getCategoryIcon(), color: _getCategoryColor(), size: 40),

        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Colors.black26,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description),
            ],
          ),
        ),
      ],
    );
  }
}
