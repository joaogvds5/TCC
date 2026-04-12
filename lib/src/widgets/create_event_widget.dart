import 'package:flutter/material.dart';
import 'package:nearu/src/screens/login_screen.dart';
import 'package:nearu/src/services/create_event_service.dart';
import 'package:nearu/src/services/get_location.dart' as get_location;

class AddEventWidget extends StatefulWidget {
  const AddEventWidget({super.key});

  @override
  State<AddEventWidget> createState() => _AddEventWidgetState();
}

class _AddEventWidgetState extends State<AddEventWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCategory = 'Evento';
  bool isLoading = false;

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

  Future<void> _createEvent() async {
    // 🔴 Validação
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Digite um título')));
      return;
    }

    setState(() => isLoading = true);

    try {
      // 📍 Localização
      final position = await get_location.currentPosition();

      final success = await CreateEventService().createEvent(
        title: titleController.text,
        description: descriptionController.text,
        category: selectedCategory,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento criado com sucesso!')),
        );

        Navigator.pop(context);
      } else {
        // Aqui pode ser erro de auth OU outro erro
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao criar evento')));
      }
    } catch (e) {
      if (!mounted) return;

      // 🔐 Erro de autenticação
      if (e.toString().contains("Usuário não autenticado")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faça login para criar eventos')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        // 🌍 erro geral (ex: localização, rede, etc)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro inesperado ao criar evento')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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

            // 📌 Título
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 📌 Descrição
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 📌 Categoria
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

            // 🔘 Botão
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
