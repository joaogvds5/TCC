import 'dart:typed_data';
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

  /// Carrega o perfil do usuário logado
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
        _error = 'Perfil não encontrado. Complete seu cadastro.';
      }
    } catch (e) {
      _error = 'Erro ao carregar perfil';
      debugPrint('Erro ProfileController: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza o perfil
  Future<bool> updateProfile({
    String? name,
    String? biography,
    DateTime? birthDate,
    String? telephone,
  }) async {
    if (_profile == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProfile = _profile!.copyWith(
        name: name,
        biography: biography,
        birthDate: birthDate,
        telephone: telephone,
      );

      await _service.updateProfile(updatedProfile);
      _profile = updatedProfile;
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar perfil';
      debugPrint('Erro ProfileController: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza foto de perfil
  Future<bool> updateProfilePhoto(Uint8List imageBytes) async {
    _isLoading = true;
    notifyListeners();

    try {
      final photoUrl = await _service.uploadProfilePhotoBytes(imageBytes);
      if (photoUrl != null && _profile != null) {
        _profile = _profile!.copyWith(photoUrl: photoUrl);
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erro ao atualizar foto';
      debugPrint('Erro ProfileController: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove foto de perfil
  Future<bool> removeProfilePhoto() async {
    try {
      await _service.removeProfilePhoto();
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

  /// Logout
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _profile = null;
    _error = null;
    notifyListeners();
  }

  /// Deleta conta
  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteAccount();
      await Supabase.instance.client.auth.signOut();
      _profile = null;
      return true;
    } catch (e) {
      _error = 'Erro ao deletar conta';
      debugPrint('Erro ProfileController: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
