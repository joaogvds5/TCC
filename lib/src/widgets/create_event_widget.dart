import 'package:flutter/material.dart';
import 'package:nearu/src/services/create_event_service.dart';
import 'package:nearu/src/services/get_location.dart' as getLocation;

class AddEventWidget extends StatefulWidget {
  const AddEventWidget({super.key});

  @override
  State<AddEventWidget> createState() => _AddEventWidgetState();
}

class _AddEventWidgetState extends State<AddEventWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCategory = 'Evento';

  final List<String> categories = [
    'Evento',
    'Música',
    'Esporte',
    'Feira',
    'Tecnologia',
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Criar Evento',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              items: categories.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  print('Título: ${titleController.text}');
                  print('Descrição: ${descriptionController.text}');
                  print('Categoria: $selectedCategory');

                  // Call the service to create the event
                  final createEventService = CreateEventService();
                  createEventService
                      .createEvent(
                        title: titleController.text,
                        description: descriptionController.text,
                        category: selectedCategory,
                        latitude: await getLocation.currentPosition().then(
                          (position) => position.latitude,
                        ),
                        longitude: await getLocation.currentPosition().then(
                          (position) => position.longitude,
                        ),
                      )
                      .then((success) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Evento criado com sucesso!'),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      })
                      .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erro ao criar evento.'),
                          ),
                        );
                      });
                },
                child: const Text('Criar Evento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
