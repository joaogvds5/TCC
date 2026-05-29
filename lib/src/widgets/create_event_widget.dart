import 'package:flutter/material.dart';
import 'package:nearu/src/controllers/event_controller.dart';
import 'package:nearu/src/screens/login_screen.dart';
import 'package:nearu/src/services/get_location.dart' as get_location;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/controllers/event_controller.dart';
// UnauthenticatedException já vem junto com esse import

class AddEventWidget extends StatefulWidget {
  const AddEventWidget({super.key});

  @override
  State<AddEventWidget> createState() => _AddEventWidgetState();
}

class Category {
  final int id;
  final String name;

  Category(this.id, this.name);
}

class _AddEventWidgetState extends State<AddEventWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final EventController controller = EventController();

  bool isLoading = false;

  final List<Category> categories = [
    Category(1, 'Evento'),
    Category(2, 'Música'),
    Category(3, 'Esporte'),
    Category(4, 'Feira'),
    Category(5, 'Tecnologia'),
  ];

  late Category selectedCategory = categories.first;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    if (titleController.text.isEmpty) {
      _showMessage('Digite um título');
      return;
    }

    setState(() => isLoading = true);

    try {
      final position = await get_location.currentPosition();

      final success = await controller.createEvent(
        title: titleController.text,
        description: descriptionController.text,
        categoryId: selectedCategory.id,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      if (success) {
        _showMessage('Evento criado com sucesso!');
        Navigator.pop(context);
      } else {
        _showMessage('Erro ao criar evento');
      }
    } on UnauthenticatedException {
      // Captura específica para não autenticado
      if (!mounted) return;

      _showMessage('Faça login para continuar');

      // Fecha o modal primeiro
      Navigator.pop(context);

      // Depois abre a tela de login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Erro inesperado: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

            DropdownButtonFormField<Category>(
              value: selectedCategory,
              items: categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat.name));
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
                onPressed: isLoading ? null : _createEvent,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Criar Evento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
