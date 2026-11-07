import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:nearu/src/controllers/event_controller.dart';
import 'package:nearu/src/models/interest.dart';
import 'package:nearu/src/screens/login_screen.dart';
import 'package:nearu/src/services/get_location.dart' as get_location;
import 'package:nearu/src/services/interest_service.dart';
import 'package:nearu/src/widgets/interest_selector_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEventWidget extends StatefulWidget {
  const AddEventWidget({super.key});

  @override
  State<AddEventWidget> createState() => _AddEventWidgetState();
}

class _AddEventWidgetState extends State<AddEventWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final EventController controller = EventController();
  final ImagePicker _picker = ImagePicker();
  final InterestService _interestService = InterestService();

  bool isLoading = false;
  File? _imageFile;
  Uint8List? _imageBytes;
  bool _hasImage = false;

  List<Interest> _categories = [];
  Interest? _selectedCategory;
  bool _isLoadingCategories = true;
  String? _categoriesError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    try {
      final categories = await _interestService.getAllInterests();
      if (!mounted) return;

      Interest? preselected;
      if (categories.isNotEmpty) {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          final userInterests = await _interestService.getUserInterestIds(
            userId,
          );
          preselected = categories.cast<Interest?>().firstWhere(
            (c) => userInterests.contains(c!.id),
            orElse: () => null,
          );
        }
        preselected ??= categories.first;
      }

      if (!mounted) return;
      setState(() {
        _categories = categories;
        _selectedCategory = preselected;
        _isLoadingCategories = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar interesses: $e');
      if (!mounted) return;
      setState(() {
        _categoriesError = 'Erro ao carregar categorias';
        _isLoadingCategories = false;
      });
    }
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
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile == null || !mounted) return;

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

  Future<void> _createEvent() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Digite um título')));
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione uma categoria')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final position = await get_location.currentPosition();

      final eventId = await controller.createEvent(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        categoryId: _selectedCategory!.id,
        latitude: position.latitude,
        longitude: position.longitude,
        photoBytes: _imageBytes,
      );

      if (!mounted) return;

      if (eventId != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Evento criado!')));
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

  Widget _buildCategorySection() {
    if (_isLoadingCategories) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_categoriesError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _categoriesError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: _loadCategories,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Nenhum interesse disponível no momento.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return DropdownButtonFormField<Interest>(
      value: _selectedCategory,
      isExpanded: true,
      items: _categories.map((cat) {
        return DropdownMenuItem<Interest>(
          value: cat,
          child: Row(
            children: [
              Icon(InterestSelectorWidget.iconFor(cat.icon), size: 18),
              const SizedBox(width: 8),
              Flexible(child: Text(cat.name)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCategory = value);
      },
      decoration: const InputDecoration(
        labelText: 'Categoria',
        border: OutlineInputBorder(),
      ),
    );
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Criar Evento',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.file(
                              _imageFile!,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              children: [
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

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
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

            _buildCategorySection(),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isLoading || _selectedCategory == null)
                    ? null
                    : _createEvent,
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
