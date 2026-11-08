import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearu/src/controllers/interest_controller.dart';
import 'package:nearu/src/controllers/profile_controller.dart';
import 'package:nearu/src/models/profile.dart';
import 'package:nearu/src/widgets/interest_selector_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const int minAge = 18;

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  DateTime? _birthDate;
  File? _imageFile;
  bool _isLoading = false;
  bool _hasChanges = false;

  final ProfileController _controller = ProfileController();
  final ImagePicker _picker = ImagePicker();
  late final InterestController _interestController;

  Set<int> _initialInterestIds = {};
  bool _interestsLoaded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(
      text: widget.profile.biography ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.profile.telephone ?? '',
    );
    _birthDate = widget.profile.birthDate;

    _nameController.addListener(_checkChanges);
    _bioController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);

    _interestController = InterestController();
    _interestController.addListener(_onInterestChanged);
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    try {
      await _interestController.load(userUuid: widget.profile.userUuid);
      _initialInterestIds = Set<int>.from(_interestController.selectedIds);
    } catch (e) {
      debugPrint('Erro ao carregar interesses: $e');
      _initialInterestIds = {};
    } finally {
      if (!mounted) return;
      setState(() => _interestsLoaded = true);
      _checkChanges();
    }
  }

  void _onInterestChanged() {
    if (!mounted) return;
    setState(() {});
    _checkChanges();
  }

  bool _setEquals(Set<int> a, Set<int> b) =>
      a.length == b.length && a.containsAll(b);

  bool _hasOtherChanges() =>
      _nameController.text != widget.profile.name ||
      _bioController.text != (widget.profile.biography ?? '') ||
      _phoneController.text != (widget.profile.telephone ?? '') ||
      _birthDate != widget.profile.birthDate ||
      _imageFile != null;

  void _checkChanges() {
    final hasChanges =
        _hasOtherChanges() ||
        (_interestsLoaded &&
            !_setEquals(_initialInterestIds, _interestController.selectedIds));

    if (_hasChanges != hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkChanges);
    _bioController.removeListener(_checkChanges);
    _phoneController.removeListener(_checkChanges);
    _interestController.removeListener(_onInterestChanged);
    _interestController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _controller.dispose();
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
                'Foto de perfil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              if (_imageFile != null || widget.profile.photoUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remover foto',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    setState(() {
                      _imageFile = null;
                      _hasChanges = true;
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
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final lastAllowed = DateTime(now.year - minAge, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: lastAllowed,
      helpText: 'Você precisa ter pelo menos $minAge anos',
    );

    if (date != null && mounted) {
      setState(() {
        _birthDate = date;
        _hasChanges = true;
      });
    }
  }

  int _ageFromBirthDate(DateTime birth) {
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnack('Nome é obrigatório', isError: true);
      return;
    }

    if (_birthDate == null) {
      _showSnack('Data de nascimento é obrigatória', isError: true);
      return;
    }

    if (_birthDate!.isAfter(DateTime.now())) {
      _showSnack('Data de nascimento não pode ser no futuro', isError: true);
      return;
    }

    final age = _ageFromBirthDate(_birthDate!);
    if (age < minAge) {
      _showSnack(
        'É necessário ter pelo menos $minAge anos. '
        'Idade informada: $age ${age == 1 ? "ano" : "anos"}.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userUuid = widget.profile.userUuid;

      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final uint8List = Uint8List.fromList(bytes);

        try {
          final photoUpdated = await _controller.updateProfilePhoto(
            uint8List,
            userUuid: userUuid,
          );
          if (!photoUpdated) {
            throw Exception('Erro ao fazer upload da foto');
          }
        } on StorageException catch (e) {
          debugPrint('StorageException: ${e.message}');
          throw Exception(
            'Erro de permissão ao enviar foto. Verifique as políticas do bucket.',
          );
        } catch (e) {
          debugPrint('Erro de upload: $e');
          throw Exception('Erro ao fazer upload da foto');
        }
      }
      if (_interestsLoaded &&
          !_setEquals(_initialInterestIds, _interestController.selectedIds)) {
        final okInterests = await _interestController.save(userUuid: userUuid);
        if (!okInterests) {
          throw Exception(
            _interestController.error ?? 'Erro ao salvar interesses',
          );
        }
        _initialInterestIds = Set<int>.from(_interestController.selectedIds);
      }
      final success = await _controller.updateProfile(
        userUuid: userUuid,
        name: _nameController.text.trim(),
        biography: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        birthDate: _birthDate,
        telephone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        _showSnack('Perfil atualizado!', isError: false);
        Navigator.pop(context, true);
      } else {
        _showSnack(_controller.error ?? 'Erro ao salvar', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Erro: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          TextButton(
            onPressed: _hasChanges && !_isLoading ? _saveProfile : null,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Foto
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (widget.profile.photoUrl != null &&
                                    widget.profile.photoUrl!.isNotEmpty
                                ? NetworkImage(widget.profile.photoUrl!)
                                : null),
                      child:
                          _imageFile == null &&
                              (widget.profile.photoUrl == null ||
                                  widget.profile.photoUrl!.isEmpty)
                          ? Text(
                              widget.profile.initials,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nome',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Biografia',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
                counterText: '',
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: _birthDate != null
                        ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                        : '',
                  ),
                  decoration: InputDecoration(
                    labelText: 'Data de nascimento',
                    prefixIcon: const Icon(Icons.cake),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Selecione a data',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'É necessário ter pelo menos $minAge anos.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Telefone',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: '(11) 99999-9999',
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Icon(
                  Icons.interests,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Interesses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Escolha os temas que te interessam.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            if (!_interestsLoaded)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              InterestSelectorWidget(controller: _interestController),

            const SizedBox(height: 32),

            if (widget.profile.email != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'E-mail',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.profile.email!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.lock, size: 16, color: Colors.grey.shade400),
                  ],
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
