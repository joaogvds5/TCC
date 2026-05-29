import 'package:flutter/material.dart';

class EventFilterWidget extends StatelessWidget {
  final Function(String category) onSelected;

  const EventFilterWidget({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final categories = ['Todos', 'Música', 'Esporte', 'Feira', 'Tecnologia'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];

          return GestureDetector(
            onTap: () => onSelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              alignment: Alignment.center,
              child: Text(category, style: const TextStyle(fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}
