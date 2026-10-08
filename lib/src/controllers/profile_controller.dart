// lib/src/controllers/profile_controller.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/models/profile.dart';
import 'package:nearu/src/services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => Supabase.instance.client.auth.currentUser != null;

  Future<void> loadProfile() async {
    if (!isLoggedIn) {
      _error = 'Usuário não autenticado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.getMyProfile();

      if (_profile == null) {
        _error = 'Perfil não encontrado';
      }
    } catch (e) {
      _error = 'Erro ao carregar perfil';
      debugPrint('Erro ProfileController: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String userUuid,
    String? name,
    String? biography,
    DateTime? birthDate,
    String? telephone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateProfileFields(
        userUuid: userUuid,
        name: name,
        biography: biography,
        birthDate: birthDate,
        telephone: telephone,
      );

      if (_profile != null) {
        _profile = _profile!.copyWith(
          name: name,
          biography: biography,
          birthDate: birthDate,
          telephone: telephone,
        );
      }

      debugPrint('Perfil atualizado com sucesso');
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar perfil';
      debugPrint('Erro ao atualizar: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ///atualizar foto
  Future<bool> updateProfilePhoto(
    Uint8List imageBytes, {
    required String userUuid,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final photoUrl = await _service.uploadProfilePhotoBytes(
        imageBytes,
        userUuid: userUuid,
      );

      if (photoUrl != null) {
        if (_profile != null) {
          _profile = _profile!.copyWith(photoUrl: photoUrl);
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erro ao atualizar foto';
      debugPrint('Erro ao atualizar foto: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeProfilePhoto(String userUuid) async {
    try {
      await _service.removeProfilePhoto(userUuid);
      if (_profile != null) {
        _profile = _profile!.copyWith(photoUrl: null);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Erro ao remover foto';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _profile = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
