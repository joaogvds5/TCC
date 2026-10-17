import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:nearu/src/controllers/event_controller.dart';
import 'package:nearu/src/screens/login_screen.dart';
import 'package:nearu/src/services/get_location.dart' as get_location;

class AddEventWidget extends StatefulWidget {
  const AddEventWidget({super.key});

  @override
  State<AddEventWidget> createState() => _AddEventWidgetState();
}

class Category {
  final int id;
  final String name;
  final IconData icon;

  Category(this.id, this.name, this.icon);
}

class _AddEventWidgetState extends State<AddEventWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final EventController controller = EventController();
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;
  File? _imageFile;
  Uint8List? _imageBytes;
  bool _hasImage = false;

  final List<Category> categories = [
    Category(1, 'Evento', Icons.event),
    Category(2, 'Música', Icons.music_note),
    Category(3, 'Esporte', Icons.sports_soccer),
    Category(4, 'Feira', Icons.store),
    Category(5, 'Tecnologia', Icons.computer),
  ];

  late Category selectedCategory = categories.first;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Foto do Evento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Você poderá recortar a imagem depois',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF0A0A23)),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF0A0A23),
                ),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              if (_hasImage)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remover foto',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    setState(() {
                      _imageFile = null;
                      _imageBytes = null;
                      _hasImage = false;
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      // 1. Pega a imagem
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile == null || !mounted) return;

      // 2. Abre o cropper para recortar
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        compressQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar Foto',
            toolbarColor: const Color(0xFF0A0A23),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false,
            hideBottomControls: false,
            statusBarColor: const Color(0xFF0A0A23),
            activeControlsWidgetColor: const Color(0xFF0A0A23),
            cropStyle: CropStyle.rectangle,
            showCropGrid: true,
            backgroundColor: Colors.black,
          ),
          IOSUiSettings(
            title: 'Recortar Foto',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            minimumAspectRatio: 1.0,
            aspectRatioPickerButtonHidden: false,
            cancelButtonTitle: 'Cancelar',
            doneButtonTitle: 'Concluir',
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        final bytes = await croppedFile.readAsBytes();
        setState(() {
          _imageFile = File(croppedFile.path);
          _imageBytes = Uint8List.fromList(bytes);
          _hasImage = true;
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar/recortar imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao processar imagem')),
        );
      }
    }
  }

  /// recortar imagem
  Future<void> _reCropImage() async {
    if (_imageFile == null) return;

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _imageFile!.path,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar Foto',
            toolbarColor: const Color(0xFF0A0A23),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false,
            hideBottomControls: false,
            activeControlsWidgetColor: const Color(0xFF0A0A23),
            cropStyle: CropStyle.rectangle,
            showCropGrid: true,
            backgroundColor: Colors.black,
          ),
          IOSUiSettings(
            title: 'Recortar Foto',
            cancelButtonTitle: 'Cancelar',
            doneButtonTitle: 'Concluir',
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        final bytes = await croppedFile.readAsBytes();
        setState(() {
          _imageFile = File(croppedFile.path);
          _imageBytes = Uint8List.fromList(bytes);
        });
      }
    } catch (e) {
      debugPrint('Erro ao recortar imagem: $e');
    }
  }

  // ============================================
  // CRIAÇÃO DO EVENTO
  // ============================================

  Future<void> _createEvent() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Digite um título')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final position = await get_location.currentPosition();

      final eventId = await controller.createEvent(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        categoryId: selectedCategory.id,
        latitude: position.latitude,
        longitude: position.longitude,
        photoBytes: _imageBytes,
      );

      if (!mounted) return;

      if (eventId != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Evento criado! 🎉')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro ao criar evento')));
      }
    } on UnauthenticatedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para continuar')),
      );
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      debugPrint('Erro: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro inesperado')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ============================================
  // BUILD
  // ============================================

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Criar Evento',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // ============================================
            // 📸 FOTO DO EVENTO (COM RECORTE)
            // ============================================
            const Text(
              'Foto do Evento (opcional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasImage ? Colors.green : Colors.grey.shade400,
                    width: _hasImage ? 2 : 1,
                  ),
                ),
                child: _hasImage
                    ? Stack(
                        children: [
                          // Imagem
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.file(
                              _imageFile!,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Botões sobre a imagem
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              children: [
                                // Botão recortar
                                GestureDetector(
                                  onTap: _reCropImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.crop,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Botão remover
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _imageFile = null;
                                      _imageBytes = null;
                                      _hasImage = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Label "Toque para trocar"
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Toque para trocar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 48,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Clique para adicionar foto',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Você poderá recortar a imagem',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ============================================
            // TÍTULO
            // ============================================
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // ============================================
            // DESCRIÇÃO
            // ============================================
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // ============================================
            // CATEGORIA
            // ============================================
            DropdownButtonFormField<Category>(
              value: selectedCategory,
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 18),
                      const SizedBox(width: 8),
                      Text(cat.name),
                    ],
                  ),
                );
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

            // ============================================
            // BOTÃO CRIAR
            // ============================================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A0A23),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Criar Evento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
