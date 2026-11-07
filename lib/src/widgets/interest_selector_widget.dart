import 'package:flutter/material.dart';
import 'package:nearu/src/controllers/interest_controller.dart';

class InterestSelectorWidget extends StatelessWidget {
  final InterestController controller;
  final Set<int>? overrideSelection;
  final ValueChanged<int>? onToggle;

  const InterestSelectorWidget({
    super.key,
    required this.controller,
    this.overrideSelection,
    this.onToggle,
  });

  static IconData iconFor(String? iconName) {
    switch (iconName) {
      case 'music_note':
        return Icons.music_note;
      case 'computer':
        return Icons.computer;
      case 'restaurant':
        return Icons.restaurant;
      case 'park':
        return Icons.park;
      case 'theater_comedy':
        return Icons.theater_comedy;
      case 'flight':
        return Icons.flight;
      case 'school':
        return Icons.school;
      case 'category':
        return Icons.category;
      case 'event':
        return Icons.event;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'store':
        return Icons.store;
      default:
        return Icons.local_offer;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.allInterests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null && controller.allInterests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          controller.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final selection = overrideSelection ?? controller.selectedIds;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.allInterests.map((interest) {
        final selected = selection.contains(interest.id);
        return FilterChip(
          avatar: Icon(
            iconFor(interest.icon),
            size: 18,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
          label: Text(interest.name),
          selected: selected,
          onSelected: (_) {
            if (onToggle != null) {
              onToggle!(interest.id);
            } else {
              controller.toggle(interest.id);
            }
          },
          selectedColor: Theme.of(context).primaryColor,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(color: Colors.grey.shade300),
        );
      }).toList(),
    );
  }
}
